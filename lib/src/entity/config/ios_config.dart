part of 'initial_config.dart';

class WTIOSConfig {
  const WTIOSConfig({
    this.store = WTIOSStore.other,
    this.attWaitingInterval = 30,
    this.requestATTAutomatically = true,
  });

  /// Specifies the app store for iOS.
  ///
  /// Possible values:
  /// - `WTIOSStore.appstore`
  /// - `WTIOSStore.sibche`
  /// - `WTIOSStore.other` (default)
  final WTIOSStore store;

  /// Maximum time to wait for ATT authorization. Defaults to 30 seconds. Set to null to disable waiting
  final int? attWaitingInterval;

  /// Whether SDK should automatically request ATT. Defaults to true.
  final bool requestATTAutomatically;

  /// Creates an instance of [WTIOSConfig] from a map.
  ///
  /// This method is useful when deserializing configuration data from a JSON object or storage.
  factory WTIOSConfig.fromMap(Map<String, dynamic> map) {
    return WTIOSConfig(
      store: WTIOSStore.fromString(map['ios_store_name'].toString()),
      attWaitingInterval: map['att_waiting_interval'] as int? ?? 30,
      requestATTAutomatically:
          map['request_att_automatically'] as bool? ?? false,
    );
  }

  /// Converts the configuration object to a map.
  ///
  /// This is useful for serialization or sending configuration data to an external service.
  Map<String, dynamic> toMap() {
    return {
      'ios_store_name': store.name,
      'att_waiting_interval': attWaitingInterval,
      'request_att_automatically': requestATTAutomatically,
    };
  }
}
