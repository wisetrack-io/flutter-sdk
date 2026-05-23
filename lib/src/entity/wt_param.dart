/// Represents a parameter value for an event/screen in the WiseTrack analytics system.
///
/// [WTParam] encapsulates various data types that can be used as
/// event or screen parameters, including strings, numbers, and booleans. It provides
/// type-safe factory constructors for creating parameters with specific types.
class WTParam {
  /// The underlying value of this parameter.
  ///
  /// Can be a [String], [num], or [bool].
  final dynamic value;

  /// Private constructor for creating an [WTParam] with the given [value].
  WTParam._(this.value);

  /// Creates an [WTParam] with a string value.
  ///
  /// **Important:** String values have a maximum length of 100 characters.
  /// Longer values may be truncated or rejected by the tracking system.
  ///
  /// Example:
  /// ```dart
  /// final param = WTParam.string('user_action');
  /// ```
  factory WTParam.string(String value) => WTParam._(value);

  /// Creates an [WTParam] with a numeric value.
  ///
  /// Accepts both integers and floating-point numbers.
  ///
  /// Example:
  /// ```dart
  /// final param = WTParam.number(42);
  /// final param2 = WTParam.number(3.14);
  /// ```
  factory WTParam.number(num value) => WTParam._(value);

  /// Creates an [WTParam] with a boolean value.
  ///
  /// Example:
  /// ```dart
  /// final param = WTParam.boolean(true);
  /// ```
  factory WTParam.boolean(bool value) => WTParam._(value);

  /// Creates an [WTParam] with a dynamic value.
  ///
  /// Automatically validates that the [value] is one of the supported types:
  /// [String], [num], or [bool].
  ///
  /// **Important:** String values have a maximum length of 100 characters.
  /// Longer values may be truncated or rejected by the tracking system.
  ///
  /// Throws an [Exception] if the value is not of a supported type.
  ///
  /// Example:
  /// ```dart
  /// final param1 = WTParam.dynamic('hello');
  /// final param2 = WTParam.dynamic(123);
  /// final param3 = WTParam.dynamic(true);
  /// ```
  ///
  /// Throws:
  /// * [Exception] when [value] is not a [String], [num], or [bool].
  factory WTParam.dynamic(dynamic value) {
    if (value is String || value is num || value is bool) {
      return WTParam._(value);
    }
    throw Exception('Invalid value for WTParam, `$value`');
  }
}
