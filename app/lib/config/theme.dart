import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';
import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/util/ui/dynamic_colors.dart';
import 'package:refena_flutter/refena_flutter.dart';

final _borderRadius = BorderRadius.circular(5);

/// On desktop, we need to add additional padding to achieve the same visual appearance as on mobile
double get desktopPaddingFix => checkPlatformIsDesktop() ? 8 : 0;

ThemeData getTheme(ColorMode colorMode, Brightness brightness, DynamicColors? dynamicColors) {
  if (colorMode == ColorMode.oni) {
    return _getOniTheme(brightness);
  }

  if (colorMode == ColorMode.dune) {
    return _getDuneTheme(brightness);
  }

  final colorScheme = _determineColorScheme(colorMode, brightness, dynamicColors);

  final lightInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: colorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  final darkInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: colorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  // Use default system font for the app
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    navigationBarTheme: colorScheme.brightness == Brightness.dark
        ? NavigationBarThemeData(
            iconTheme: WidgetStateProperty.all(const IconThemeData(color: Colors.white)),
          )
        : null,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.secondaryContainer,
      border: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      focusedBorder: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      enabledBorder: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.brightness == Brightness.dark ? Colors.white : null,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8 + desktopPaddingFix),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8 + desktopPaddingFix),
      ),
    ),
  );
}

Future<void> updateSystemOverlayStyle(BuildContext context) async {
  final brightness = Theme.of(context).brightness;
  await updateSystemOverlayStyleWithBrightness(brightness);
}

Future<void> updateSystemOverlayStyleWithBrightness(Brightness brightness) async {
  if (checkPlatform([TargetPlatform.android])) {
    // See https://github.com/flutter/flutter/issues/90098
    final darkMode = brightness == Brightness.dark;
    final androidSdkInt = RefenaScope.defaultRef.read(deviceInfoProvider).androidSdkInt ?? 0;
    final bool edgeToEdge = androidSdkInt >= 29;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // ignore: unawaited_futures

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: edgeToEdge ? Colors.transparent : (darkMode ? Colors.black : Colors.white),
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      ),
    );
  } else {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: brightness, // iOS
        statusBarColor: Colors.transparent, // Not relevant to this issue
      ),
    );
  }
}

extension ThemeDataExt on ThemeData {
  /// This is the actual [cardColor] being used.
  Color get cardColorWithElevation {
    return ElevationOverlay.applySurfaceTint(cardColor, colorScheme.surfaceTint, 1);
  }
}

extension ColorSchemeExt on ColorScheme {
  Color get warning {
    return Colors.orange;
  }

  Color? get secondaryContainerIfDark {
    return brightness == Brightness.dark ? secondaryContainer : null;
  }

  Color? get onSecondaryContainerIfDark {
    return brightness == Brightness.dark ? onSecondaryContainer : null;
  }
}

extension InputDecorationThemeExt on InputDecorationThemeData {
  BorderRadius get borderRadius => _borderRadius;
}

ColorScheme _determineColorScheme(ColorMode mode, Brightness brightness, DynamicColors? dynamicColors) {
  final defaultColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: brightness,
  );

  final colorScheme = switch (mode) {
    ColorMode.system => brightness == Brightness.light ? dynamicColors?.light : dynamicColors?.dark,
    ColorMode.dune => null,
    ColorMode.oled => (dynamicColors?.dark ?? defaultColorScheme).copyWith(
      surface: Colors.black,
    ),
    ColorMode.oni => throw 'Should not reach here',
  };

  return colorScheme ?? defaultColorScheme;
}

ThemeData _getOniTheme(Brightness brightness) {
  // Custom Oni color scheme - vibrant and modern with excellent contrast
  final ColorScheme oniColorScheme;

  if (brightness == Brightness.light) {
    // Oni Light Theme - bright and energetic with purple/red accents
    oniColorScheme = ColorScheme.light(
      primary: const Color(0xFFD32F2F), // Vibrant red
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFCDD2),
      onPrimaryContainer: const Color(0xFF5F0000),
      secondary: const Color(0xFF7B1FA2), // Deep purple
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE1BEE7),
      onSecondaryContainer: const Color(0xFF4A0072),
      tertiary: const Color(0xFF0288D1), // Blue accent
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFB3E5FC),
      onTertiaryContainer: const Color(0xFF01579B),
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: const Color(0xFFFFFBFF),
      onSurface: const Color(0xFF1C1B1E),
      surfaceContainerHighest: const Color(0xFFE7E0EB),
      outline: const Color(0xFF79747E),
      outlineVariant: const Color(0xFFCAC4CF),
    );
  } else {
    // Oni Dark Theme (Abyss) - deep black with vibrant red and pink accents
    oniColorScheme = ColorScheme.dark(
      primary: const Color(0xFFFF5252), // Bright red
      onPrimary: const Color(0xFF5F0000),
      primaryContainer: const Color(0xFFB71C1C),
      onPrimaryContainer: const Color(0xFFFFCDD2),
      secondary: const Color(0xFFFF4081), // Pink accent (Material Pink A200)
      onSecondary: const Color(0xFF4A0027),
      secondaryContainer: const Color(0xFF7B0038),
      onSecondaryContainer: const Color(0xFFFFCDD2),
      tertiary: const Color(0xFFFF6E40), // Orange-red accent
      onTertiary: const Color(0xFF5F0000),
      tertiaryContainer: const Color(0xFFD84315),
      onTertiaryContainer: const Color(0xFFFFCCBC),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: const Color(0xFF000000), // True black (Abyss)
      onSurface: const Color(0xFFE6E1E5),
      surfaceContainerHighest: const Color(0xFF2B2930),
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF49454F),
    );
  }

  final lightInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: oniColorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  final darkInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: oniColorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  return ThemeData(
    colorScheme: oniColorScheme,
    useMaterial3: true,
    navigationBarTheme: oniColorScheme.brightness == Brightness.dark
        ? NavigationBarThemeData(
            iconTheme: WidgetStateProperty.all(const IconThemeData(color: Colors.white)),
          )
        : null,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: oniColorScheme.secondaryContainer,
      border: oniColorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      focusedBorder: oniColorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      enabledBorder: oniColorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: oniColorScheme.brightness == Brightness.dark ? Colors.white : null,
        padding: checkPlatformIsDesktop() ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: checkPlatformIsDesktop() ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
  );
}

ThemeData _getDuneTheme(Brightness brightness) {
  // Dune theme - desert-inspired colors with warm sandy tones
  final ColorScheme duneColorScheme;

  if (brightness == Brightness.light) {
    // Dune Light Theme - warm sandy desert colors
    duneColorScheme = ColorScheme.light(
      primary: const Color(0xFFD4A574), // Sandy gold
      onPrimary: const Color(0xFF3E2723),
      primaryContainer: const Color(0xFFEDD5B3),
      onPrimaryContainer: const Color(0xFF5D4037),
      secondary: const Color(0xFFCD853F), // Peru/bronze
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFE4B5), // Moccasin
      onSecondaryContainer: const Color(0xFF6D4C41),
      tertiary: const Color(0xFF8B7355), // Desert brown
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFD7CCC8),
      onTertiaryContainer: const Color(0xFF4E342E),
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: const Color(0xFFFFF8F0), // Warm off-white
      onSurface: const Color(0xFF3E2723),
      surfaceContainerHighest: const Color(0xFFEFEBE5),
      outline: const Color(0xFF8D6E63),
      outlineVariant: const Color(0xFFD7CCC8),
    );
  } else {
    // Dune Dark Theme - deep desert night with warm accents
    duneColorScheme = ColorScheme.dark(
      primary: const Color(0xFFDEB887), // Burlywood
      onPrimary: const Color(0xFF3E2723),
      primaryContainer: const Color(0xFF8B7355),
      onPrimaryContainer: const Color(0xFFFFE4B5),
      secondary: const Color(0xFFD2691E), // Chocolate
      onSecondary: const Color(0xFF1A1410),
      secondaryContainer: const Color(0xFF8B4513), // Saddle brown
      onSecondaryContainer: const Color(0xFFFFDDB3),
      tertiary: const Color(0xFFBC8F8F), // Rosy brown
      onTertiary: const Color(0xFF1A1410),
      tertiaryContainer: const Color(0xFF6D4C41),
      onTertiaryContainer: const Color(0xFFEFEBE5),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: const Color(0xFF1A1410), // Deep warm brown-black
      onSurface: const Color(0xFFEFEBE5),
      surfaceContainerHighest: const Color(0xFF2E2419),
      outline: const Color(0xFF9E9189),
      outlineVariant: const Color(0xFF4E4539),
    );
  }

  final lightInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: duneColorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  final darkInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: duneColorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  return ThemeData(
    colorScheme: duneColorScheme,
    useMaterial3: true,
    navigationBarTheme: duneColorScheme.brightness == Brightness.dark
        ? NavigationBarThemeData(
            iconTheme: WidgetStateProperty.all(const IconThemeData(color: Color(0xFFEFEBE5))),
          )
        : null,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: duneColorScheme.secondaryContainer,
      border: duneColorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      focusedBorder: duneColorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      enabledBorder: duneColorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: duneColorScheme.brightness == Brightness.dark ? const Color(0xFFEFEBE5) : null,
        padding: checkPlatformIsDesktop() ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: checkPlatformIsDesktop() ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
  );
}
