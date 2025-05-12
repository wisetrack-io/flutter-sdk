// ignore_for_file: unused_field

import '../../resources/resources.dart';
import '../environments.dart';
import '../log_level.dart';
import '../store_name.dart';

/// Configuration class for initializing the WiseTrack SDK.
///
/// This class provides essential parameters required for initializing the SDK,
/// including authentication tokens, environment settings, and store preferences.
///
/// Example usage:
/// ```dart
/// final config = WTInitialConfig(
///   appToken: "your_app_token",
///   userEnvironment: WTUserEnvironment.production,
///   androidStoreName: WTAndroidStoreName.googlePlay,
///   iOSStoreName: WTIOSStoreName.appStore,
///   trackingWattingTime: 5000,
///   startTrackerAutomatically: true,
/// );
/// ```
class WTInitialConfig {
  /// Creates a new instance of [WTInitialConfig] with required and optional parameters.
  ///
  /// - [appToken] is required for authentication.
  /// - [userEnvironment] defines the deployment environment (default: `production`).
  /// - [androidStore] specifies the app store for Android (default: `other`).
  /// - [iOSStore] specifies the app store for iOS (default: `other`).
  /// - [trackingWattingTime] sets a delay before tracking starts (default: `0` milliseconds).
  /// - [startTrackerAutomatically] determines if tracking starts automatically (default: `true`).
  WTInitialConfig({
    required this.appToken,
    this.userEnvironment = WTUserEnvironment.sandbox,
    this.androidStore = WTAndroidStore.other,
    this.iOSStore = WTIOSStore.other,
    this.trackingWattingTime = 0,
    this.startTrackerAutomatically = true,
    this.customDeviceId,
    this.defaultTracker,
    this.appSecret,
    this.secretId,
    this.attributionDeeplink,
    this.eventBuffering,
    this.oaidEnabled = false,
    this.referrerEnabled = true,
    this.logLevel = WTResources.defaultLogLevel,
  });

  /// The user environment defining the deployment setting.
  ///
  /// Possible values:
  /// - `WTUserEnvironment.production` (default)
  /// - `WTUserEnvironment.sandbox`
  final WTUserEnvironment userEnvironment;

  /// Specifies the app store for Android.
  ///
  /// Possible values:
  /// - `WTAndroidStore.googlePlay`
  /// - `WTAndroidStore.huaweiAppGallery`
  /// - `WTAndroidStore.other` (default)
  final WTAndroidStore androidStore;

  /// Specifies the app store for iOS.
  ///
  /// Possible values:
  /// - `WTIOSStore.appStore`
  /// - `WTIOSStore.testFlight`
  /// - `WTIOSStore.other` (default)
  final WTIOSStore iOSStore;

  /// The delay time (in seconds) before tracking starts.
  ///
  /// Defaults to `0`, meaning tracking starts immediately unless configured otherwise.
  final int trackingWattingTime;

  /// Determines whether tracking starts automatically upon initialization.
  ///
  /// Defaults to `false`, meaning tracking must be started manually.
  final bool startTrackerAutomatically;

  /// The authentication token required to initialize the SDK.
  ///
  /// This token is provided by the WiseTrack platform.
  final String appToken;

  /// A custom device identifier that can be used instead of the default one.
  final String? customDeviceId;

  /// The default tracker identifier for event attribution.
  final String? defaultTracker;

  /// The secret key used for authentication or encryption purposes.
  final String? appSecret;

  /// A unique secret identifier linked to the app's credentials.
  final String? secretId;

  /// Indicates whether attribution via deep links is enabled.
  final bool? attributionDeeplink;

  /// Enables event buffering to optimize data transmission.
  final bool? eventBuffering;

  /// The log level used for printing logs, you can change it after by:
  /// ```dart
  /// WTLogLevel.setLogLevel(WTLogLevel.debug);
  /// ```
  /// The default log level is set to debug.
  final WTLogLevel logLevel;

  /// Indicates whether the Open Advertising ID (OAID) is enabled.
  /// The default value is `false`.
  final bool oaidEnabled;

  /// Indicates whether the Referrer ID is enabled.
  /// The default value is `true`.
  final bool referrerEnabled;

  /// Creates an instance of [WTInitialConfig] from a map.
  ///
  /// This method is useful when deserializing configuration data from a JSON object or storage.
  factory WTInitialConfig.fromMap(Map<String, dynamic> map) {
    return WTInitialConfig(
      appToken: map['app_token'],
      userEnvironment: WTUserEnvironment.values.firstWhere(
        (e) => e.name == map['user_environment'],
        orElse: () => WTUserEnvironment.production,
      ),
      androidStore: WTAndroidStore.fromString(map['android_store_name']),
      iOSStore: WTIOSStore.fromString(map['ios_store_name']),
      trackingWattingTime: map['tracking_waiting_time'] as int? ?? 0,
      startTrackerAutomatically:
          map['start_tracker_automatically'] as bool? ?? false,
      customDeviceId: map['custom_device_id'],
      defaultTracker: map['default_tracker'],
      secretId: map['secret_id'],
      appSecret: map['app_secret'],
      attributionDeeplink: map['attribution_deeplink'],
      eventBuffering: map['event_buffering_enabled'],
      logLevel: WTLogLevel.values.firstWhere(
        (l) => l.level == map['log_level'],
        orElse: () => WTResources.defaultLogLevel,
      ),
      oaidEnabled: map['oaid_enabled'] as bool? ?? false,
      referrerEnabled: map['referrer_enabled'] as bool? ?? true,
    );
  }

  /// Converts the configuration object to a map.
  ///
  /// This is useful for serialization or sending configuration data to an external service.
  Map<String, dynamic> toMap() {
    return {
      'app_token': appToken,
      'user_environment': userEnvironment.name,
      'android_store_name': androidStore.name,
      'ios_store_name': iOSStore.name,
      'tracking_waiting_time': trackingWattingTime,
      'start_tracker_automatically': startTrackerAutomatically,
      'custom_device_id': customDeviceId,
      'default_tracker': defaultTracker,
      'app_secret': appSecret,
      'secret_id': secretId,
      'attribution_deeplink': attributionDeeplink,
      'event_buffering_enabled': eventBuffering,
      'log_level': logLevel.level,
      'oaid_enabled': oaidEnabled,
      'referrer_enabled': referrerEnabled,
    };
  }
}
