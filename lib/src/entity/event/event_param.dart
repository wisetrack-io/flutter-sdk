part of 'event.dart';

class EventParameter {
  final dynamic value;
  EventParameter._(this.value);

  factory EventParameter.string(String value) => EventParameter._(value);
  factory EventParameter.number(num value) => EventParameter._(value);
  factory EventParameter.boolean(bool value) => EventParameter._(value);
  factory EventParameter.dynamic(dynamic value) {
    if (value is String || value is num || value is bool) {
      return EventParameter._(value);
    }
    throw Exception('Invalid value for EventParameter, `$value`');
  }
}
