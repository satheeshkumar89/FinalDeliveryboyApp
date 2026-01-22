import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal() {
    _setupInternalListeners();
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get onMessage => _messageStreamController.stream;

  void _setupInternalListeners() {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
      }

      _messageStreamController.add(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _messageStreamController.add(message);
    });
  }

  Future<void> initialize() async {
    print('🚀 Initializing PushNotificationService...');
    // Request permission for iOS/Web
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 Notification permission status: ${settings.authorizationStatus}');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Check if the app was opened by a notification (Terminated state)
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      print('📱 App opened from terminated state via notification');
      _messageStreamController.add(initialMessage);
    }

    // Get the token
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('🔑 FCM Token: $token');
      } else {
        print('⚠️ FCM Token is null');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print("Handling a background message: ${message.messageId}");
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  // No longer needed to call manually
  void listenForegroundMessages() {}

  void dispose() {
    _messageStreamController.close();
  }
}
