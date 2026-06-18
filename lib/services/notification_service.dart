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

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final token = await messaging.getToken();
      await messaging.subscribeToTopic('all_users');

      log('======================');
      log('FCM TOKEN');
      log(token ?? 'Token is null');
      log('Subscribed to all_users topic');
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
