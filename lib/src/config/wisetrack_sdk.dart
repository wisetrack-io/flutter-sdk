import 'package:wisetrack/src/entity/entity.dart';

import 'wisetrack_platform_interface.dart';

class WiseTrack {
  WiseTrack._() {
    _init();
  }
  static final WiseTrack _instance = WiseTrack._();
  static WiseTrack get instance => _instance;

  _init() {
    // WisetrackPlatform.instance.listenOnLogs((message) {
    //   // log(message);
    // });
  }

  /// Listens for log messages from the SDK.
  ///
  /// This method should be called to receive logs from the SDK.
  /// - [listener]: A callback function that will be called with log messages.
  void listenOnLogs(Function(String message) listener) {
    WisetrackPlatform.instance.listenOnLogs(listener);
  }

  /// Enables test mode for debugging purposes.
  ///
  /// When enabled, the SDK operates in a test environment, preventing real data tracking.
  /// Note: Enabling test mode will `delete all previously collected data`.
  Future<void> enableTestMode() {
    return WisetrackPlatform.instance.enableTestMode();
  }

  /// Requests App Tracking Transparency (ATT) permission on iOS.
  ///
  /// Before calling this method, ensure that you have added the necessary
  /// permissions in your iOS project's `Info.plist` file. Specifically, you must
  /// include the `NSUserTrackingUsageDescription` key with a proper description
  /// explaining why your app needs tracking access.
  ///
  /// Example:
  /// ```xml
  /// <key>NSUserTrackingUsageDescription</key>
  /// <string>We use this data to provide a better user experience and personalized ads.</string>
  /// ```
  ///
  /// - Returns: A boolean indicating whether permission was granted (`true`) or denied (`false`).
  Future<bool> iOSRequestForATT() {
    return WisetrackPlatform.instance.iOSRequestForATT();
  }

  /// Initializes the tracking system with the given configuration.
  ///
  /// - [initConfig]: The initial configuration settings.
  /// - [extraConfig]: Optional extra configuration settings.
  /// - Returns: A `Future` that completes when the initialization is done.
  /// - Note: This method should be called before any tracking events are logged.
  Future<void> init(WTInitialConfig initConfig) {
    return WisetrackPlatform.instance.init(initConfig);
  }

  /// Create events to the tracking system.
  ///
  /// - [event]: The event data to be logged.
  Future<void> logEvent(WTEvent event) {
    return WisetrackPlatform.instance.logEvent(event);
  }

  /// Sets the Apple Push Notification Service (APNS) token for push notification tracking.
  ///
  /// - [apnsToken]: The APNS token received from Apple's push notification service.
  Future<void> setAPNSToken(String apnsToken) {
    return WisetrackPlatform.instance.setAPNSToken(apnsToken);
  }

  /// Enables or disables tracking based on the given value.
  ///
  /// - [enabled]: `true` to enable tracking, `false` to disable it.
  Future<void> setEnabled(bool enabled) {
    return WisetrackPlatform.instance.setEnabled(enabled);
  }

  /// Sets the Firebase Cloud Messaging (FCM) token for push notification tracking.
  ///
  /// - [fcmToken]: The FCM token received from Firebase.
  Future<void> setFCMToken(String fcmToken) {
    return WisetrackPlatform.instance.setFCMToken(fcmToken);
  }

  /// Sets the logging level for debugging and diagnostics.
  ///
  /// - [level]: The desired logging level.
  Future<void> setLogLevel(WTLogLevel level) {
    return WisetrackPlatform.instance.setLogLevel(level);
  }

  /// Starts the tracking process.
  ///
  /// This method should be called when tracking should begin, such as on app launch.
  Future<void> startTracking() {
    return WisetrackPlatform.instance.startTracking();
  }

  /// Stops the tracking process.
  ///
  /// This method should be called when tracking should be paused or stopped completely.
  Future<void> stopTracking() {
    return WisetrackPlatform.instance.stopTracking();
  }

  /// Checks if the tracking system is enabled.
  Future<bool> isEnabled() {
    return WisetrackPlatform.instance.isEnabled();
  }

  /// Retrieves the Advertising ID (Ad ID) for the device.
  /// This function is intended for Android platform only.
  /// For other platforms, it returns null.
  Future<String?> getAdId() {
    return WisetrackPlatform.instance.getAdId();
  }

  /// Sets the package information for the tracking system.
  Future<void> setPackgesInfo() {
    return WisetrackPlatform.instance.setPackagesInfo();
  }

  /// Retrieves the Identifier For Advertising (IDFA) for the device.
  /// This function is intended for iOS platform only.
  /// For other platforms, it returns null.
  /// Before calling this method, check `iOSRequestForATT` method and the documentation for adding permissions.
  Future<String?> getIdfa() {
    return WisetrackPlatform.instance.getIdfa();
  }
}
