import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wisetrack/src/config/channel_names.dart';
import 'package:wisetrack/src/entity/entity.dart';
import 'package:wisetrack/src/entity/sdk_environment.dart';
import 'package:wisetrack/src/resources/resources.dart';

import 'wisetrack_platform_interface.dart';

/// An implementation of [WisetrackPlatform] that communicates with the native platform via method channels.
class MethodChannelWisetrack extends WisetrackPlatform {
  /// The method channel used for communication with the native side.
  static const MethodChannel _channel = MethodChannel('io.wisetrack.flutter');

  @override
  void listenOnLogs(Function(String message) listener) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == MethodChannelNames.methodLog) {
        listener(call.arguments["message"]);
      }
    });
  }

  @override
  Future<void> init(WTInitialConfig initConfig) async {
    try {
      await _channel.invokeMethod(MethodChannelNames.methodInit, {
        'sdk_env': WTResources.defaultSdkEnvironment.label,
        'sdk_version': WTResources.sdkVersion,
        ...initConfig.toMap(),
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to initialize sdk: ${e.message}");
    }
  }

  @override
  Future<void> enableTestMode() async {
    try {
      await _channel.invokeMethod(MethodChannelNames.methodEnableTestMode);
    } on PlatformException catch (e) {
      debugPrint("Failed to enable test mode: ${e.message}");
    }
  }

  @override
  Future<void> setLogLevel(WTLogLevel level) async {
    try {
      await _channel.invokeMethod(MethodChannelNames.methodSetLogLevel, {
        "level": level.level,
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to set log level: ${e.message}");
    }
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod(MethodChannelNames.methodSetEnabled, {
        "enabled": enabled,
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to set tracking enabled: ${e.message}");
    }
  }

  @override
  Future<bool> iOSRequestForATT() async {
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;

      final result = await _channel.invokeMethod<bool>(
        MethodChannelNames.methodIOSRequestForATT,
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to request ATT on iOS: ${e.message}");
      return false;
    }
  }

  @override
  Future<void> startTracking() async {
    try {
      await _channel.invokeMethod(MethodChannelNames.methodStartTracking);
    } on PlatformException catch (e) {
      debugPrint("Failed to start tracking: ${e.message}");
    }
  }

  @override
  Future<void> stopTracking() async {
    try {
      await _channel.invokeMethod(MethodChannelNames.methodStopTracking);
    } on PlatformException catch (e) {
      debugPrint("Failed to stop tracking: ${e.message}");
    }
  }

  @override
  Future<void> setAPNSToken(String apnsToken) async {
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

      await _channel.invokeMethod(MethodChannelNames.methodSetAPNSToken, {
        "token": apnsToken,
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to set APNS token: ${e.message}");
    }
  }

  @override
  Future<void> setFCMToken(String fcmToken) async {
    try {
      await _channel.invokeMethod(MethodChannelNames.methodSetFCMToken, {
        "token": fcmToken,
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to set FCM token: ${e.message}");
    }
  }

  @override
  Future<void> logEvent(WTEvent event) async {
    try {
      await _channel.invokeMethod(
        MethodChannelNames.methodLogEvent,
        event.toMap(),
      );
    } on PlatformException catch (e) {
      debugPrint("Failed to log event: ${e.message}");
    }
  }

  @override
  Future<bool> isEnabled() async {
    try {
      final result = await _channel.invokeMethod(
        MethodChannelNames.methodIsEnabled,
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed get isEnabled: ${e.message}");
      return false;
    }
  }

  @override
  Future<String?> getAdId() async {
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
        return null;
      }

      return _channel.invokeMethod(MethodChannelNames.methodGetAdId);
    } on PlatformException catch (e) {
      debugPrint("Failed to log event: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getIdfa() async {
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return null;

      return _channel.invokeMethod(MethodChannelNames.methodGetIdFA);
    } on PlatformException catch (e) {
      debugPrint("Failed to log event: ${e.message}");
      return null;
    }
  }

  @override
  Future<void> setPackagesInfo() async {
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

      return _channel.invokeMethod(MethodChannelNames.methodSetPackagesInfo);
    } on PlatformException catch (e) {
      debugPrint("Failed to set packages info: ${e.message}");
      return;
    }
  }
}
