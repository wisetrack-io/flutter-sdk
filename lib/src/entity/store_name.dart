/// Represents the various Android store names supported in the application.
///
/// This class contains predefined store names such as "Play Store", "Cafe Bazaar", and "Myket".
/// It also provides a mechanism for custom store names and allows conversion from string values.
///
/// Example usage:
/// ```dart
/// final store = WTAndroidStore.playstore;
/// final customStore = WTAndroidStore.custom('your-store-name');
/// ```
class WTAndroidStore {
  /// Predefined store for the Google Play Store.
  static const playstore = WTAndroidStore._('playstore');

  /// Predefined store for Cafe Bazaar.
  static const cafebazaar = WTAndroidStore._('cafebazaar');

  /// Predefined store for Myket.
  static const myket = WTAndroidStore._('myket');

  /// Predefined store for other unspecified stores.
  static const other = WTAndroidStore._('other');

  /// The name of the store.
  final String name;

  /// Private constructor for creating a store instance.
  const WTAndroidStore._(this.name);

  /// Factory constructor for creating a custom store name.
  ///
  /// This allows you to create an instance of `WTAndroidStore` with any name.
  factory WTAndroidStore.custom(String name) {
    return WTAndroidStore._(name);
  }

  /// Factory constructor to create a store name from a string value.
  ///
  /// This maps the provided string to one of the predefined store names or creates a custom store name.
  factory WTAndroidStore.fromString(String value) {
    if (value == playstore.name) return playstore;
    if (value == cafebazaar.name) return cafebazaar;
    if (value == myket.name) return myket;
    if (value == other.name) return other;
    return WTAndroidStore.custom(value);
  }

  static List<WTAndroidStore> get values => [
    playstore,
    cafebazaar,
    myket,
    other,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is WTAndroidStore && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// Represents the various iOS stores supported in the application.
///
/// This class contains predefined stores such as "App Store", "Sibche", and "Sibapp".
/// It also provides a mechanism for custom stores and allows conversion from string values.
///
/// Example usage:
/// ```dart
/// final store = WTIOSStore.appstore;
/// final customStore = WTIOSStore.custom('your-store-name);
/// ```
class WTIOSStore {
  /// Predefined store for the iOS App Store.
  static const appstore = WTIOSStore._('appstore');

  /// Predefined store for Sibche store.
  static const sibche = WTIOSStore._('sibche');

  /// Predefined store for Sibapp store.
  static const sibapp = WTIOSStore._('sibapp');

  /// Predefined store for Anardoni store.
  static const anardoni = WTIOSStore._('anardoni');

  /// Predefined store for Sibirani store.
  static const sibirani = WTIOSStore._('sibirani');

  /// Predefined store for Sibjo store.
  static const sibjo = WTIOSStore._('sibjo');

  /// Predefined store for other unspecified stores.
  static const other = WTIOSStore._('other');

  /// The name of the store.
  final String name;

  /// Private constructor for creating a store name instance.
  const WTIOSStore._(this.name);

  /// Factory constructor for creating a custom store name.
  ///
  /// This allows you to create an instance of `WTIOSStore` with any name.
  factory WTIOSStore.custom(String name) {
    return WTIOSStore._(name);
  }

  /// Factory constructor to create a store name from a string value.
  ///
  /// This maps the provided string to one of the predefined store names or creates a custom store name.
  factory WTIOSStore.fromString(String value) {
    if (value == appstore.name) return appstore;
    if (value == sibche.name) return sibche;
    if (value == sibapp.name) return sibapp;
    if (value == anardoni.name) return anardoni;
    if (value == sibirani.name) return sibirani;
    if (value == sibjo.name) return sibjo;
    if (value == other.name) return other;
    return WTIOSStore.custom(value);
  }

  static List<WTIOSStore> get values => [
    appstore,
    sibapp,
    sibche,
    anardoni,
    sibirani,
    sibjo,
    other,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is WTIOSStore && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
