import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:wisetrack/src/entity/entity.dart';
import 'package:wisetrack/src/entity/sdk_environment.dart';

import '../../resources/resources.dart';
import '../wisetrack_platform_interface.dart';
import 'wisetrack_web.dart';
import 'wisetrack_web_interop.dart';

class WisetrackWebImpl extends WisetrackPlatform {
  WisetrackWebImpl();

  static void registerWith(Registrar registrar) {
    WisetrackPlatform.instance = WisetrackWebImpl();
  }

  @override
  Future<void> listenOnLogs(Function(String message) listener) async {
    try {
      await WisetrackPlugin.ensureSDKLoaded();
      final logCallback = (String level, String prefix, JSArray args) {
        listener('$prefix ${args.toDart.join(', ')}');
      }.toJS;
      WTLoggerJS.addOutputEngine(logCallback);
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to register log listener: $e');
    }
  }

  @override
  Future<void> init(WTInitialConfig initConfig) async {
    try {
      await WisetrackPlugin.ensureSDKLoaded();
      await Future.delayed(Duration(milliseconds: 100));

      ResourceWrapperJS.sdkEnvironment(WTResources.defaultSdkEnvironment.label);
      ResourceWrapperJS.sdkVersion(WTResources.sdkVersion);

      final config = <String, dynamic>{
        'appToken': initConfig.appToken,
        'appVersion': initConfig.webAppVersion,
        'appFrameWork': 'flutter',
        'userEnvironment': initConfig.userEnvironment.label.toUpperCase(),
        'logLevel': initConfig.logLevel.webLabel,
        'trackingWaitingTime': initConfig.trackingWaitingTime,
        'startTrackerAutomatically': initConfig.startTrackerAutomatically,
        'customDeviceId': initConfig.customDeviceId,
        'defaultTracker': initConfig.defaultTracker,
      };
      await WiseTrackJS.instance.init(config.jsify() as JSObject).toDart;
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to initialize: $e');
    }
  }

  @override
  Future<void> clearAndStop() async {
    try {
      WiseTrackJS.instance.flush();
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to flush SDK: $e');
    }
  }

  @override
  Future<bool> iOSRequestForATT() async {
    // Not applicable for web platform
    return false;
  }

  @override
  Future<void> logEvent(WTEvent event) async {
    try {
      await WisetrackPlugin.ensureSDKLoaded();

      late WTEventJS eventJS;

      JSObject? paramsJS;
      if (event.params != null && event.params!.isNotEmpty) {
        final paramsMap = <String, dynamic>{};
        for (final entry in event.params!.entries) {
          paramsMap[entry.key] = _mapEventParameter(entry.value);
        }
        paramsJS = paramsMap.jsify() as JSObject;
      }

      eventJS = event.type == WTEventType.defaultEvent
          ? WTEventJS.defaultEvent(event.name, paramsJS)
          : WTEventJS.revenueEvent(
              event.name,
              event.revenueAmount!.toJS,
              event.revenueCurrency!.label,
              paramsJS,
            );

      await WiseTrackJS.instance.trackEvent(eventJS).toDart;

      if (kDebugMode) {
        print('WisetrackWeb: Event logged: ${event.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('WisetrackWeb: Failed to log event: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> setAPNSToken(String apnsToken) async {
    // Not applicable for web platform
    debugPrint('WisetrackWeb: setAPNSToken not supported on web platform');
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      WiseTrackJS.instance.setEnabled(enabled);
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to set enabled: $e');
    }
  }

  @override
  Future<void> setFCMToken(String fcmToken) async {
    try {
      await WisetrackPlugin.ensureSDKLoaded();

      await WiseTrackJS.instance.setFCMToken(fcmToken).toDart;
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to set fcm token: $e');
    }
  }

  @override
  Future<void> setLogLevel(WTLogLevel level) async {
    try {
      WiseTrackJS.instance.setLogLevel(level.webLabel);
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to set log level: $e');
    }
  }

  @override
  Future<void> startTracking() async {
    try {
      await WiseTrackJS.instance.startTracking().toDart;
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to start tracking: $e');
    }
  }

  @override
  Future<void> stopTracking() async {
    try {
      await WiseTrackJS.instance.stopTracking().toDart;
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to stop tracking: $e');
    }
  }

  @override
  Future<bool> isEnabled() async {
    try {
      final result = WiseTrackJS.instance.isEnabled();
      return result.toDart;
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to get enabled status: $e');
      return false;
    }
  }

  @override
  Future<String?> getAdId() async {
    // Not applicable for web platform
    debugPrint('WisetrackWeb: getAdId not supported on web platform');
    return null;
  }

  @override
  Future<String?> getIdfa() async {
    // Not applicable for web platform
    debugPrint('WisetrackWeb: getIdfa not supported on web platform');
    return null;
  }

  @override
  Future<void> setPackagesInfo() async {
    // Not applicable for web platform
    debugPrint('WisetrackWeb: setPackagesInfo not supported on web platform');
  }

  @override
  Future<String?> getReferrer() async {
    // Not applicable for web platform
    debugPrint('WisetrackWeb: getReferrer not supported on web platform');
    return null;
  }

  @override
  Future<bool> isWiseTrackNotification(Map<String, dynamic> payload) async {
    // Not applicable for web platform
    debugPrint(
        'WisetrackWeb: isWiseTrackNotification not supported on web platform');
    return false;
  }

  JSAny? _mapEventParameter(EventParameter param) {
    final value = param.value;
    if (value is String) {
      return value.toJS;
    } else if (value is num) {
      return value.toJS;
    } else if (value is bool) {
      return value.toJS;
    } else {
      return value.toString().toJS;
    }
  }
}
