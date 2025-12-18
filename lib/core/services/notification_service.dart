import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// It's recommended to handle background messages.
// This needs to be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint("Handling a background message: \${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _requestPermissions();
    await _initFirebaseMessaging();
    await _initLocalNotifications();
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: \${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // We can add iOS settings here if needed.
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _localNotificationsPlugin.initialize(settings);
  }

  Future<void> _initFirebaseMessaging() async {
    // Handler for messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: \${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: \${message.notification}');
        showLocalNotification(message);
      }
    });

    // Handler for when a message is opened and the app is launched from it (terminated state)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      // Here you can navigate to a specific screen based on message data
    });
  }

  void showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'futsal_channel_id', // This should be a unique channel ID
            'Futsal App Notifications', // This is the channel name
            channelDescription:
                'Channel for Futsal App booking and other notifications.',
            icon: android.smallIcon, // e.g. '@mipmap/ic_launcher'
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }
}
