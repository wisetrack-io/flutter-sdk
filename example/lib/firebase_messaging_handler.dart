import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:wisetrack/wisetrack.dart';
import 'package:wisetrack_example/app_platform.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (await WiseTrack.instance.isWiseTrackNotification(message.data)) {
    return;
  }
}

class FirebaseMessagingHandler {
  static final _messaging = FirebaseMessaging.instance;

  static void init() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
        'new notification, title: ${message.notification?.title}, body: ${message.notification?.body}',
      );
      debugPrint('onMessage: ${message.data}');
      if (await WiseTrack.instance.isWiseTrackNotification(message.data)) {
        return;
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _getToken();
  }

  static _getToken() async {
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey:
          AppPlatform.isWeb
              ? '<Your VAPID Key here>'
              : null,
    );
    if (token != null) {
      WiseTrack.instance.setFCMToken(token);
    }

    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) WiseTrack.instance.setAPNSToken(apnsToken);

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      WiseTrack.instance.setFCMToken(token);
    });
  }
}
