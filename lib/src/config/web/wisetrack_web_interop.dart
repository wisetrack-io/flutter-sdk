@JS('WiseTrackSDK')
library;

import 'dart:js_interop';

/// JavaScript interop for Wisetrack Web SDK
@JS('WiseTrack')
extension type WiseTrackJS._(JSObject _) implements JSObject {
  external static WiseTrackJS get instance;

  external JSPromise<JSAny?> init(JSAny config);
  external JSPromise<JSAny?> startTracking();
  external JSPromise<JSAny?> stopTracking();
  external JSPromise<JSAny?> trackEvent(WTEventJS event);
  external JSPromise<JSAny?> trackScreen(JSAny screen);
  external void setEnabled(bool enabled);
  external bool isEnabled();
  external void setLogLevel(String level);
  external JSPromise<JSAny?> setFCMToken(String token);
  external void flush();
  external String? getLastDeeplink();
  external String? getDeferredDeeplink();
  external void setOnDeeplinkListener(JSFunction callback);
}

@JS('WTEvent')
extension type WTEventJS._(JSObject _) implements JSObject {
  external static WTEventJS defaultEvent(String name, [JSAny? params]);

  external static WTEventJS revenueEvent(
    String name,
    num amount,
    String currency, [
    JSAny? params,
  ]);
}

@JS('ResourceWrapper')
extension type ResourceWrapperJS._(JSObject _) implements JSObject {
  external static void sdkVersion(String version);
}

@JS('WTLogger')
extension type WTLoggerJS._(JSObject _) implements JSObject {
  external static void addOutputEngine(JSFunction callback);
}
