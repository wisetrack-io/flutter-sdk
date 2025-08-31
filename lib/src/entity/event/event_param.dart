part of 'event.dart';

/// Represents a parameter value for an event in the WiseTrack analytics system.
///
/// [EventParameter] encapsulates various data types that can be used as
/// event parameters, including strings, numbers, and booleans. It provides
/// type-safe factory constructors for creating parameters with specific types.
class EventParameter {
  /// The underlying value of this parameter.
  ///
  /// Can be a [String], [num], or [bool].
  final dynamic value;

  /// Private constructor for creating an [EventParameter] with the given [value].
  EventParameter._(this.value);

  /// Creates an [EventParameter] with a string value.
  ///
  /// **Important:** String values have a maximum length of 50 characters.
  /// Longer values may be truncated or rejected by the tracking system.
  ///
  /// Example:
  /// ```dart
  /// final param = EventParameter.string('user_action');
  /// ```
  factory EventParameter.string(String value) => EventParameter._(value);

  /// Creates an [EventParameter] with a numeric value.
  ///
  /// Accepts both integers and floating-point numbers.
  ///
  /// Example:
  /// ```dart
  /// final param = EventParameter.number(42);
  /// final param2 = EventParameter.number(3.14);
  /// ```
  factory EventParameter.number(num value) => EventParameter._(value);

  /// Creates an [EventParameter] with a boolean value.
  ///
  /// Example:
  /// ```dart
  /// final param = EventParameter.boolean(true);
  /// ```
  factory EventParameter.boolean(bool value) => EventParameter._(value);

  /// Creates an [EventParameter] with a dynamic value.
  ///
  /// Automatically validates that the [value] is one of the supported types:
  /// [String], [num], or [bool].
  ///
  /// **Important:** String values have a maximum length of 50 characters.
  /// Longer values may be truncated or rejected by the tracking system.
  ///
  /// Throws an [Exception] if the value is not of a supported type.
  ///
  /// Example:
  /// ```dart
  /// final param1 = EventParameter.dynamic('hello');
  /// final param2 = EventParameter.dynamic(123);
  /// final param3 = EventParameter.dynamic(true);
  /// ```
  ///
  /// Throws:
  /// * [Exception] when [value] is not a [String], [num], or [bool].
  factory EventParameter.dynamic(dynamic value) {
    if (value is String || value is num || value is bool) {
      return EventParameter._(value);
    }
    throw Exception('Invalid value for EventParameter, `$value`');
  }
}
