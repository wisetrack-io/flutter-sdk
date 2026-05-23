import '../wt_param.dart';

part 'event_currency.dart';
part 'event_type.dart';

/// A class representing an event that can be tracked within the WiseTrack SDK.
///
/// This class supports two types of events:
/// - **Default Event**: A standard event with optional parameters.
/// - **Revenue Event**: A special event associated with revenue, requiring a currency and amount.
///
/// Example usage:
/// ```dart
/// final defaultEvent = WTEvent.defaultEvent(
///   name: "user_signup",
///   params: {"method": WTParam.string("email")},
/// );
///
/// final revenueEvent = WTEvent.revenueEvent(
///   name: "purchase",
///   currency: RevenueCurrency.USD,
///   amount: 49.99,
///   params: {"product_id": WTParam.string("1234")},
/// );
/// ```
class WTEvent {
  /// Private constructor for creating an event.
  const WTEvent._(
    this.type,
    this.name, {
    this.params,
    this.revenueAmount,
    this.revenueCurrency,
  }) : assert(
          type == WTEventType.revenueEvent
              ? (revenueAmount != null && revenueCurrency != null)
              : true,
          'For revenue events, both revenueAmount and revenueCurrency must be provided.',
        );

  /// The type of the event, indicating whether it is a default or revenue event.
  final WTEventType type;

  /// The name of the event.
  ///
  /// This should be a descriptive string representing the action being tracked.
  ///
  /// **Important:** Maximum 50 characters. Longer values may be truncated or
  /// rejected by the tracking system.
  final String name;

  /// Additional parameters associated with the event.
  ///
  /// This can include metadata such as user actions, timestamps, or other relevant details.
  ///
  /// **Important:** Parameter keys have a maximum length of 50 characters;
  /// string values have a maximum length of 100 characters.
  /// Longer keys or values may be truncated or rejected by the tracking system.
  ///
  /// Example usage:
  /// ```dart
  /// final params = {
  ///   'key-1': WTParam.string('string-value'),
  ///   'key-2': WTParam.number(12.5),
  ///   'key-3': WTParam.bool(true)
  /// }
  /// ```
  final Map<String, WTParam>? params;

  /// The revenue amount associated with the event (only applicable for `revenue` events).
  final double? revenueAmount;

  /// The currency of the revenue event (only applicable for `revenue` events).
  final RevenueCurrency? revenueCurrency;

  /// Factory constructor for creating a **default event**.
  ///
  /// This type of event is used for general tracking without revenue attributes.
  ///
  /// Example usage:
  /// ```dart
  /// final event = WTEvent.defaultEvent(
  ///   name: "level_completed",
  ///   params: {"level": WTParam.number(5)},
  /// );
  /// ```
  factory WTEvent.defaultEvent({
    required String name,
    Map<String, WTParam>? params,
  }) {
    return WTEvent._(WTEventType.defaultEvent, name, params: params);
  }

  /// Factory constructor for creating a **revenue event**.
  ///
  /// This type of event tracks revenue transactions, including currency and amount.
  ///
  /// Example usage:
  /// ```dart
  /// final event = WTEvent.revenueEvent(
  ///   name: "subscription_purchase",
  ///   currency: RevenueCurrency.EUR,
  ///   amount: 9.99,
  ///   params: {"plan": WTParam.string("monthly")},
  /// );
  /// ```
  factory WTEvent.revenueEvent({
    required String name,
    required RevenueCurrency currency,
    required double amount,
    Map<String, WTParam>? params,
  }) {
    return WTEvent._(
      WTEventType.revenueEvent,
      name,
      revenueAmount: amount,
      revenueCurrency: currency,
      params: params,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.label,
        'name': name,
        'params': params?.map((key, value) => MapEntry(key, value.value)),
        'revenue': revenueAmount,
        'currency': revenueCurrency?.label,
      };
}
