part of 'event.dart';

/// Represents different types of events that can be tracked in WiseTrack SDK.
enum WTEventType {
  /// A standard and default event without any attributes.
  defaultEvent,

  /// A revenue-related event that includes monetary value and currency.
  revenueEvent;

  String get name =>
      {
        WTEventType.defaultEvent: 'default',
        WTEventType.revenueEvent: 'revenue',
      }[this]!;
}
