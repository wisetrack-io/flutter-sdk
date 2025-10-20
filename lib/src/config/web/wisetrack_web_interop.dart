import 'dart:js_interop';

import 'package:js/js.dart';

/// JavaScript interop for Wisetrack Web SDK
@JS('WiseTrackSDK.WiseTrack')
@anonymous
class WiseTrackJS {
  external static WiseTrackJS get instance;

  external JSPromise<JSAny?> init(JSObject config);
  external JSPromise<JSAny?> startTracking();
  external JSPromise<JSAny?> stopTracking();
  external JSPromise<JSAny?> trackEvent(WTEventJS event);
  external void setEnabled(bool enabled);
  external JSBoolean isEnabled();
  external void setLogLevel(String level);
  external JSPromise<JSAny?> setFCMToken(String token);
  external void flush();
}

@JS('WiseTrackSDK.WTEvent')
@anonymous
class WTEventJS {
  external static WTEventJS defaultEvent(String name, [JSObject? params]);

  external static WTEventJS revenueEvent(
      String name, JSNumber amount, String currency,
      [JSObject? params]);
}

@JS('WiseTrackSDK.ResourceWrapper')
@anonymous
class ResourceWrapperJS {
  external static void sdkEnvironment(String environment);
  external static void sdkVersion(String version);
}

@JS('WiseTrackSDK.WTLogger')
@anonymous
class WTLoggerJS {
  external static void addOutputEngine(JSFunction callback);
}
