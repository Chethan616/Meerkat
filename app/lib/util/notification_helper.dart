import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localsend_app/util/native/platform_check.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize the notification system - MUST be called at app startup
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open notification');

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
      linux: linuxSettings,
    );

    try {
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          // Handle notification tap
        },
      );

      if (initialized == false) {
        print('Notification initialization failed');
        return;
      }

      // Request permissions for iOS/macOS
      if (checkPlatform([TargetPlatform.iOS, TargetPlatform.macOS])) {
        await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );

        await _notifications
            .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      // Request permissions for Android 13+
      if (checkPlatform([TargetPlatform.android])) {
        final granted = await _notifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        print('Android notification permission granted: $granted');
      }

      _initialized = true;
      print('Notification system initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  /// Show notification when someone is trying to send files
  static Future<void> showIncomingFileNotification({
    required String senderName,
    required String fileName,
    required int fileCount,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final String title = 'Incoming file${fileCount > 1 ? 's' : ''} from $senderName';
    final String body = fileCount > 1 ? '$fileCount files including "$fileName"' : fileName;

    try {
      // Windows doesn't have direct notification support in flutter_local_notifications
      // But we still show notifications on other platforms
      if (checkPlatform([TargetPlatform.windows])) {
        // For Windows, we'll rely on the app showing up and the system tray
        // You could optionally show a dialog here or use a Windows-specific package
        print('Windows notification (tray): $title - $body');
        // The app will show from tray when files arrive (handled in receive_controller)
        return;
      }

      // Android notification
      const androidDetails = AndroidNotificationDetails(
        'incoming_files',
        'Incoming Files',
        channelDescription: 'Notifications for incoming file transfers',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        ongoing: false,
        autoCancel: true,
        visibility: NotificationVisibility.public,
      );

      // iOS/macOS notification
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      // Linux notification
      const linuxDetails = LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.critical,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
        linux: linuxDetails,
      );

      await _notifications.show(
        0, // notification id
        title,
        body,
        notificationDetails,
      );
      
      print('Incoming file notification shown: $title - $body');
    } catch (e) {
      print('Error showing incoming file notification: $e');
    }
  }

  /// Show notification for file transfer completion
  static Future<void> showTransferCompleteNotification({
    required int fileCount,
    required String senderName,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Skip Windows notifications (no support in flutter_local_notifications)
      if (checkPlatform([TargetPlatform.windows])) {
        print('Windows: Transfer complete - $fileCount files from $senderName');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'transfer_complete',
        'Transfer Complete',
        channelDescription: 'Notifications for completed file transfers',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        autoCancel: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const linuxDetails = LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.normal,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
        linux: linuxDetails,
      );

      await _notifications.show(
        1, // notification id
        'Transfer Complete',
        'Received ${fileCount > 1 ? '$fileCount files' : '1 file'} from $senderName',
        notificationDetails,
      );
      
      print('Transfer complete notification shown');
    } catch (e) {
      print('Error showing transfer complete notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
