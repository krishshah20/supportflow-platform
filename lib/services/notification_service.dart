import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();

      const AndroidInitializationSettings
          androidSettings =
          AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidSettings,
        ),
      );

      final AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'inquiry_channel_new',
        'Inquiry Notifications',
        description: 'Notifications for new inquiries',
        importance: Importance.max,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      String? token;
      try {
        token = await messaging.getToken();
      } catch (e) {
        log('FCM getToken failed: $e, attempting to clear cache and retry...');
        try {
          await messaging.deleteToken();
          token = await messaging.getToken();
        } catch (retryError) {
          log('FCM retry failed: $retryError');
        }
      }

      log('======================');
      log('FCM TOKEN');
      log(token ?? 'Token is null (FCM Registration failed)');
      log('======================');

      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          _localNotifications.show(
            0,
            message.notification?.title,
            message.notification?.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'inquiry_channel_new',
                'Inquiry Notifications',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
              ),
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      log(
        'Notification initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
