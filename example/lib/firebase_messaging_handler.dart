import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wisetrack/wisetrack.dart';

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
      if (await WiseTrack.instance.isWiseTrackNotification(message.data)) {
        return;
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _getToken();
  }

  static _getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
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
