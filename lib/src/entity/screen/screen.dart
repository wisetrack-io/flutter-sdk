import '../wt_param.dart';

part 'screen_type.dart';

/// Represents a screen view event for WiseTrack analytics.
///
/// Pass a [WTScreen] to [WiseTrack.instance.trackScreen] to record
/// that the user visited a particular screen.
///
/// Example:
/// ```dart
/// final screen = WTScreen(
///   'product_detail',
///   WTScreenType.page,
///   displayName: 'Product Detail',
///   params: {'product_id': WTParam.string('abc123')},
/// );
/// await WiseTrack.instance.trackScreen(screen);
/// ```
class WTScreen {
  /// Creates a [WTScreen].
  ///
  /// - [name]: Unique technical identifier for the screen (e.g. `'product_detail'`).
  /// - [type]: The presentation style — page, dialog, or bottom sheet.
  /// - [displayName]: Human-readable label shown in the analytics dashboard.
  ///   Derived automatically when omitted (e.g. `ProductPage` → `Product`).
  /// - [params]: Optional key-value metadata attached to this screen view.
  WTScreen(
    this.name,
    this.type, {
    this.displayName,
    this.params,
    this.isAuto = false,
    this.trigger,
  });

  /// The presentation style of this screen.
  final WTScreenType type;

  /// Unique technical identifier for the screen.
  ///
  /// Used as the primary key in analytics. For named routes this is derived
  /// from [RouteSettings.name]; for unnamed routes it falls back to the widget
  /// class name (e.g. `'ProductPage'`).
  ///
  /// **Important:** Maximum 150 characters. Longer values may be truncated or
  /// rejected by the tracking system.
  final String name;

  /// Optional key-value metadata attached to this screen view.
  ///
  /// Accepts [String], [num], and [bool] values via [WTParam].
  ///
  /// **Important:** Parameter keys have a maximum length of 50 characters;
  /// string values have a maximum length of 100 characters.
  /// Longer keys or values may be truncated or rejected by the tracking system.
  final Map<String, WTParam>? params;

  /// Human-readable label shown in the WiseTrack analytics dashboard.
  ///
  /// When omitted the SDK derives one automatically from [name]:
  /// `ProductPage` → `Product`, `/product/detail` → `Detail`.
  final String? displayName;

  /* @internal */
  final bool isAuto;

  /* @internal */
  final String? trigger;

  Map<String, dynamic> toMap() => {
        'type': type.label,
        'name': name,
        'display_name': displayName,
        'params': params?.map((key, value) => MapEntry(key, value.value)),
        'is_auto': isAuto,
        'trigger': trigger,
      };
}
