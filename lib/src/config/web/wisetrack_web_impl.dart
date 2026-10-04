import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:wisetrack/src/entity/entity.dart';

import '../../resources/resources.dart';
import '../wisetrack_platform_interface.dart';
import 'wisetrack_web.dart';
import 'wisetrack_web_interop.dart';

class WisetrackWebImpl extends WisetrackPlatform {
  WisetrackWebImpl();

  static void registerWith(Registrar registrar) {
    WisetrackPlatform.instance = WisetrackWebImpl();
  }

  Future<T> _run<T>(
    String action,
    T fallback,
    FutureOr<T> Function(WiseTrackJS sdk) body,
  ) async {
    try {
      await WisetrackPlugin.ensureSDKLoaded();
      return await body(WiseTrackJS.instance);
    } catch (e) {
      debugPrint('WisetrackWeb: Failed to $action: $e');
      return fallback;
    }
  }

  @override
  void registerMethodCallbacks() {}

  @override
  Future<void> listenOnLogs(void Function(String message) listener) {
    return _run<void>('register log listener', null, (_) {
      WTLoggerJS.addOutputEngine(
        ((JSString level, JSString prefix, JSArray<JSAny?> args) {
          final message = args.toDart.map((a) => a.dartify()).join(', ');
          listener('${prefix.toDart} $message');
        }).toJS,
      );
    });
  }

  @override
  Future<void> init(WTInitialConfig initConfig) {
    return _run<void>('initialize', null, (sdk) async {
      ResourceWrapperJS.sdkVersion(WTResources.sdkVersion);

      final config = <String, Object?>{
        'appToken': initConfig.appToken,
        'clientSecret': initConfig.clientSecret,
        'appVersion': initConfig.webAppVersion,
        'appFrameWork': 'flutter',
        'userEnvironment': initConfig.userEnvironment.label.toUpperCase(),
        'logLevel': initConfig.logLevel.webLabel,
        'trackingWaitingTime': initConfig.trackingWaitingTime,
        'startTrackerAutomatically': initConfig.startTrackerAutomatically,
        'customDeviceId': initConfig.customDeviceId,
        'defaultTracker': initConfig.defaultTracker,
        'deeplinkEnabled': initConfig.deeplinkEnabled ?? true,
        // Screens are tracked from Dart (WTNavigatorObserver / WTScreenTrackMixin).
        'screenTrackingConfig': {
          'autoTrackScreens': false,
          'autoTrackDialogs': false,
        },
      };
      await sdk.init(config.jsify()!).toDart;
    });
  }

  @override
  Future<void> clearAndStop() {
    return _run<void>('flush SDK', null, (sdk) => sdk.flush());
  }

  @override
  Future<bool> iOSRequestForATT() async {
    // Not applicable for web platform
    return false;
  }

  @override
  Future<void> trackEvent(WTEvent event) {
    return _run<void>('track event', null, (sdk) async {
      final params = _paramsToJS(event.params);
      final eventJS = event.type == WTEventType.defaultEvent
          ? WTEventJS.defaultEvent(event.name, params)
          : WTEventJS.revenueEvent(
              event.name,
              event.revenueAmount!,
              event.revenueCurrency!.label,
              params,
            );

      await sdk.trackEvent(eventJS).toDart;
      if (kDebugMode) {
        debugPrint('WisetrackWeb: Event logged: ${event.name}');
      }
    });
  }

  @override
  Future<void> trackScreen(WTScreen screen) {
    return _run<void>('track screen', null, (sdk) async {
      final screenData = <String, Object?>{
        'name': screen.name,
        'type': screen.type.label,
        'displayName': screen.displayName,
        'params': _paramsToMap(screen.params),
        'isAuto': screen.isAuto,
        'trigger': screen.trigger,
      };

      await sdk.trackScreen(screenData.jsify()!).toDart;
      if (kDebugMode) {
        debugPrint('WisetrackWeb: Screen tracked: ${screen.name}');
      }
    });
  }

  @override
  Future<void> setAPNSToken(String apnsToken) async {
    // Not applicable for web platform
    debugPrint('WisetrackWeb: setAPNSToken not supported on web platform');
  }

  @override
  Future<void> setEnabled(bool enabled) {
    return _run<void>('set enabled', null, (sdk) => sdk.setEnabled(enabled));
  }

  @override
  Future<void> setFCMToken(String fcmToken) {
    return _run<void>(
        'set fcm token', null, (sdk) => sdk.setFCMToken(fcmToken).toDart);
  }

  @override
  Future<void> setLogLevel(WTLogLevel level) {
    return _run<void>(
        'set log level', null, (sdk) => sdk.setLogLevel(level.webLabel));
  }

  @override
  Future<void> startTracking() {
    return _run<void>(
        'start tracking', null, (sdk) => sdk.startTracking().toDart);
  }

  @override
  Future<void> stopTracking() {
    return _run<void>(
        'stop tracking', null, (sdk) => sdk.stopTracking().toDart);
  }

  @override
  Future<bool> isEnabled() {
    return _run<bool>('get enabled status', false, (sdk) => sdk.isEnabled());
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

  @override
  Future<String?> getDeferredDeeplink() {
    return _run<String?>(
        'get deferred deeplink', null, (sdk) => sdk.getDeferredDeeplink());
  }

  @override
  Future<String?> getLastDeeplink() {
    return _run<String?>(
        'get last deeplink', null, (sdk) => sdk.getLastDeeplink());
  }

  @override
  void onDeeplinkReceived(DeeplinkCallback callback) {
    _run<void>('register deeplink listener', null, (sdk) {
      sdk.setOnDeeplinkListener(
        ((JSString? uri, JSBoolean? isDeferred) {
          if (uri == null) return;
          callback(uri.toDart, isDeferred?.toDart ?? false);
        }).toJS,
      );
    });
  }

  Map<String, Object?>? _paramsToMap(Map<String, WTParam>? params) {
    if (params == null || params.isEmpty) return null;
    return params.map((key, param) => MapEntry(key, _mapWTParam(param)));
  }

  JSAny? _paramsToJS(Map<String, WTParam>? params) =>
      _paramsToMap(params)?.jsify();

  Object _mapWTParam(WTParam param) {
    final value = param.value;
    if (value is String || value is num || value is bool) return value;
    return value.toString();
  }
}
