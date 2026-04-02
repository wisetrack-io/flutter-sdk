part of 'initial_config.dart';

class WTAndroidConfig {
  const WTAndroidConfig({
    this.store = WTAndroidStore.other,
    this.oaidEnabled = false,
  });

  /// Specifies the app store for Android.
  ///
  /// Possible values:
  /// - `WTAndroidStore.playstore`
  /// - `WTAndroidStore.cafebazaar`
  /// - `WTAndroidStore.other` (default)
  final WTAndroidStore store;

  /// Indicates whether the Open Advertising ID (OAID) is enabled.
  /// The default value is `false`.
  final bool oaidEnabled;

  /// Creates an instance of [WTAndroidConfig] from a map.
  ///
  /// This method is useful when deserializing configuration data from a JSON object or storage.
  factory WTAndroidConfig.fromMap(Map<String, dynamic> map) {
    return WTAndroidConfig(
      store: WTAndroidStore.fromString(map['android_store_name'].toString()),
      oaidEnabled: map['oaid_enabled'] as bool? ?? false,
    );
  }

  /// Converts the configuration object to a map.
  ///
  /// This is useful for serialization or sending configuration data to an external service.
  Map<String, dynamic> toMap() {
    return {
      'android_store_name': store.name,
      'oaid_enabled': oaidEnabled,
    };
  }
}
