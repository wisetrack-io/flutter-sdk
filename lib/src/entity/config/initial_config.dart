// ignore_for_file: unused_field

import '../../resources/resources.dart';
import '../../resources/running_platform.dart';
import '../environments.dart';
import '../log_level.dart';
import '../store_name.dart';

part 'ios_config.dart';
part 'android_config.dart';

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
///   trackingWaitingTime: 3,
///   startTrackerAutomatically: true,
/// );
/// ```
class WTInitialConfig {
  /// Creates a new instance of [WTInitialConfig] with required and optional parameters.
  ///
  /// - [appToken] is required for authentication.
  /// - [clientSecret] is required for authentication.
  /// - [userEnvironment] defines the deployment environment (default: `production`).
  /// - [androidStore] specifies the app store for Android (default: `other`).
  /// - [iOSStore] specifies the app store for iOS (default: `other`).
  /// - [trackingWaitingTime] sets a delay before tracking starts (default: `0` seconds).
  /// - [startTrackerAutomatically] determines if tracking starts automatically (default: `true`).
  /// - [customDeviceId] allows specifying a custom device identifier (optional).
  /// - [defaultTracker] sets the default tracker identifier for event attribution (optional).
  /// - [logLevel] sets the log level for SDK logging (default: `debug`).
  /// - [oaidEnabled] enables or disables Open Advertising ID support (default: `false`).
  /// - [deeplinkEnabled] enables or disables Deeplink handling support (default: `true`).
  /// - [webAppVersion] the app version for web.
  WTInitialConfig({
    required this.appToken,
    required this.clientSecret,
    this.userEnvironment = WTUserEnvironment.production,
    this.androidConfig = const WTAndroidConfig(),
    this.iOSConfig = const WTIOSConfig(),
    this.trackingWaitingTime = 0,
    this.startTrackerAutomatically = true,
    this.customDeviceId,
    this.defaultTracker,
    this.deeplinkEnabled = true,
    this.logLevel = WTResources.defaultLogLevel,
    this.webAppVersion,
  }) : assert(!RunningPlatform.isWeb || webAppVersion != null,
            'webAppVersion is required when using web');

  /// The user environment defining the deployment setting.
  ///
  /// Possible values:
  /// - `WTUserEnvironment.production` (default)
  /// - `WTUserEnvironment.sandbox`
  final WTUserEnvironment userEnvironment;

  final WTAndroidConfig androidConfig;

  final WTIOSConfig iOSConfig;

  /// The delay time (in seconds) before tracking starts.
  ///
  /// Defaults to `0`, meaning tracking starts immediately unless configured otherwise.
  final int trackingWaitingTime;

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

  /// The secret key used for authentication.
  final String clientSecret;

  /// Indicates whether deep links handling is enabled.
  final bool? deeplinkEnabled;

  /// The log level used for printing logs, you can change it after by:
  /// ```dart
  /// WTLogLevel.setLogLevel(WTLogLevel.debug);
  /// ```
  /// The default log level is set to debug.
  final WTLogLevel logLevel;

  /// The app version for web.
  /// just fill it when you are using web.
  final String? webAppVersion;

  /// Creates an instance of [WTInitialConfig] from a map.
  ///
  /// This method is useful when deserializing configuration data from a JSON object or storage.
  factory WTInitialConfig.fromMap(Map<String, dynamic> map) {
    return WTInitialConfig(
      appToken: map['app_token'],
      clientSecret: map['client_secret'],
      userEnvironment: WTUserEnvironment.values.firstWhere(
        (e) => e.label == map['user_environment'].toString().toLowerCase(),
        orElse: () => WTUserEnvironment.production,
      ),
      androidConfig: WTAndroidConfig.fromMap(map),
      iOSConfig: WTIOSConfig.fromMap(map),
      trackingWaitingTime: map['tracking_waiting_time'] as int? ?? 0,
      startTrackerAutomatically:
          map['start_tracker_automatically'] as bool? ?? false,
      customDeviceId: map['custom_device_id'],
      defaultTracker: map['default_tracker'],
      deeplinkEnabled: map['deeplink_enabled'] as bool? ?? true,
      logLevel: WTLogLevel.values.firstWhere(
        (l) =>
            l.level == map['log_level'] ||
            l.label.toLowerCase() == map['log_level'].toString().toLowerCase(),
        orElse: () => WTResources.defaultLogLevel,
      ),
    );
  }

  /// Converts the configuration object to a map.
  ///
  /// This is useful for serialization or sending configuration data to an external service.
  Map<String, dynamic> toMap() {
    return {
      'app_token': appToken,
      'client_secret': clientSecret,
      'user_environment': userEnvironment.label,
      ...androidConfig.toMap(),
      ...iOSConfig.toMap(),
      'tracking_waiting_time': trackingWaitingTime,
      'start_tracker_automatically': startTrackerAutomatically,
      'custom_device_id': customDeviceId,
      'default_tracker': defaultTracker,
      'deeplink_enabled': deeplinkEnabled,
      'log_level': logLevel.level,
    };
  }
}
