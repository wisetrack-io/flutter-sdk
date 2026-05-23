import 'package:flutter/widgets.dart';
import 'package:wisetrack/wisetrack.dart' show WiseTrack;

import '../entity/screen/screen.dart';
import '../entity/wt_param.dart';

/// Mixin for manual screen tracking on individual widgets.
///
/// Usage:
/// ```dart
/// // 1. Create a global RouteObserver and add to MaterialApp
/// final wtRouteObserver = RouteObserver<ModalRoute<void>>();
/// WTScreenTrackMixin.routeObserver = wtRouteObserver;
///
/// MaterialApp(navigatorObservers: [wtRouteObserver])
///
/// // 2. Apply mixin to your State
/// class _ProductDetailState extends State<ProductDetail>
///     with RouteAware, WTScreenTrackMixin {
///   @override
///   String get screenName => 'product_detail';
/// }
/// ```
mixin WTScreenTrackMixin<T extends StatefulWidget> on State<T>, RouteAware {
  static RouteObserver<ModalRoute<void>>? _globalRouteObserver;

  /// Set once at app startup; pass the same instance to your Navigator observers.
  static set routeObserver(RouteObserver<ModalRoute<void>> observer) {
    _globalRouteObserver = observer;
  }

  /// Technical screen identifier reported to WiseTrack analytics.
  ///
  /// Override this getter to return a stable, unique key for the screen
  /// (e.g. `'product_detail'`). Avoid spaces or special characters.
  String get screenName;

  /// Human-readable label shown in the WiseTrack analytics dashboard.
  ///
  /// Defaults to `null`, in which case the dashboard derives a label from [screenName].
  String? get screenDisplayName => null;

  /// Optional key-value metadata attached to each screen view event.
  ///
  /// Values must be [String], [num], or [bool] wrapped in [WTParam].
  Map<String, WTParam>? get screenParams => null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = _globalRouteObserver;
    final route = ModalRoute.of(context);
    if (observer != null && route != null) {
      observer.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _globalRouteObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    WiseTrack.instance.trackScreen(WTScreen(
      screenName,
      WTScreenType.page,
      displayName: screenDisplayName,
      params: screenParams,
      isAuto: false,
      trigger: 'push',
    ));
  }

  @override
  void didPopNext() {
    // fires when popping back to this screen
    WiseTrack.instance.trackScreen(WTScreen(
      screenName,
      WTScreenType.page,
      displayName: screenDisplayName,
      params: screenParams,
      isAuto: false,
      trigger: 'pop_return',
    ));
  }
}
