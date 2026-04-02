@JS('WiseTrackSDK')
library wisetrack_web_interop;

import 'package:js/js.dart';

/// JavaScript interop for Wisetrack Web SDK
@JS('WiseTrack')
class WiseTrackJS {
  external static WiseTrackJS get instance;

  external Object init(Object config);
  external Object startTracking();
  external Object stopTracking();
  external Object trackEvent(WTEventJS event);
  external void setEnabled(bool enabled);
  external bool isEnabled();
  external void setLogLevel(String level);
  external Object setFCMToken(String token);
  external void flush();
  external String? getLastDeeplink();
  external String? getDeferredDeeplink();
  external void setOnDeeplinkListener(Function callback);
}

@JS('WTEvent')
class WTEventJS {
  external static WTEventJS defaultEvent(String name, [Object? params]);

  external static WTEventJS revenueEvent(
      String name, num amount, String currency,
      [Object? params]);
}

@JS('ResourceWrapper')
class ResourceWrapperJS {
  external static void sdkEnvironment(String environment);
  external static void sdkVersion(String version);
}

@JS('WTLogger')
class WTLoggerJS {
  external static void addOutputEngine(Function callback);
}
