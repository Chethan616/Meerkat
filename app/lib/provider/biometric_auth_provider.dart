import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BiometricAuthState {
  available,
  unavailable,
  disabled,
}

class BiometricAuthNotifier extends Notifier<BiometricAuthState> {
  static const String _biometricEnabledKey = 'biometric_enabled';
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  BiometricAuthState init() => BiometricAuthState.disabled;

  /// Check if biometric authentication is available on this device
  Future<void> checkBiometricAvailability() async {
    try {
      // Check if device supports authentication (including PIN/password)
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (isDeviceSupported) {
        // Check if user has enabled it in settings
        final prefs = await SharedPreferences.getInstance();
        final isEnabled = prefs.getBool(_biometricEnabledKey) ?? false;

        if (isEnabled) {
          state = BiometricAuthState.available;
        } else {
          state = BiometricAuthState.unavailable;
        }
      } else {
        state = BiometricAuthState.unavailable;
      }
    } catch (e) {
      // If we can't check, assume device is supported and let the authentication attempt handle it
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
      state = isEnabled ? BiometricAuthState.available : BiometricAuthState.unavailable;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Enable biometric authentication
  Future<({bool success, String? error})> enableBiometric() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable security for Meerkat',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/password as fallback
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_biometricEnabledKey, true);
        state = BiometricAuthState.available;
        return (success: true, error: null);
      }
      return (success: false, error: 'Authentication was cancelled or failed. Please try again');
    } on PlatformException catch (e) {
      // Handle specific error codes
      String errorMessage;
      switch (e.code) {
        case 'NotAvailable':
        case 'NoHardware':
          // If no biometric hardware, we should still allow PIN/password
          errorMessage = 'Authentication is available but no biometric hardware found. Using device PIN/password instead';
          break;
        case 'NotEnrolled':
          errorMessage = 'No authentication method set up. Please set up fingerprint, face unlock, or PIN in device settings';
          break;
        case 'LockedOut':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'Authentication is locked. Please unlock your device first';
          break;
        case 'PasscodeNotSet':
          errorMessage = 'Device security not set up. Please set up a PIN, pattern, or password in device settings';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed: ${e.code}';
      }
      print('Biometric error [${e.code}]: $errorMessage');
      return (success: false, error: errorMessage);
    } catch (e) {
      print('Unexpected error: $e');
      return (success: false, error: 'Unexpected error: $e');
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
    state = BiometricAuthState.disabled;
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate({required String reason}) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow fallback to PIN/password on some platforms
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Authentication error: ${e.message}');
      return false;
    }
  }

  /// Check if biometric is enabled in settings
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Get biometric type name for display
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.isEmpty) return 'Biometric';

    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric (Strong)';
    } else if (types.contains(BiometricType.weak)) {
      return 'Biometric (Weak)';
    }
    return 'Device Credentials';
  }
}

final biometricAuthProvider = NotifierProvider<BiometricAuthNotifier, BiometricAuthState>(
  (ref) => BiometricAuthNotifier(),
);
