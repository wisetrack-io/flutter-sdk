import 'package:flutter/material.dart';
import 'package:wisetrack/wisetrack.dart';

/// Global log of auto-tracked navigation events shown in the Screen Tracking demo.
final screenEventLog = ValueNotifier<List<String>>([]);

/// RouteObserver required by [WTScreenTrackMixin]. Added to MaterialApp in main.dart.
final wtRouteObserver = RouteObserver<ModalRoute<void>>();

/// Root navigator observer — added to MaterialApp in main.dart.
/// Extends [WTNavigatorObserver] to also write to [screenEventLog] for live demo display.
final wtNavigatorObserver = WTDemoNavigatorObserver(
  log: screenEventLog,
  config: const WTScreenTrackingConfig(
    enabled: true,
    trackDialogs: true,
    deduplicationWindowMs: 300,
    // excludedScreens: {
    //   'LogsView',
    //   '_DraggableScrollableSheetScrollView',
    // },
  ),
);

/// A [WTNavigatorObserver] that additionally writes route events to a [ValueNotifier]
/// so the Screen Tracking demo can display live feedback.
class WTDemoNavigatorObserver extends WTNavigatorObserver {
  final ValueNotifier<List<String>> log;

  WTDemoNavigatorObserver({required this.log, super.config});

  void _record(Route<dynamic> route, String trigger) {
    final name = route.settings.name;
    final label =
        (name != null && name.isNotEmpty)
            ? name
            : '<${route.runtimeType.toString().split('<').first}>';
    log.value = ['$trigger $label', ...log.value.take(29)];
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _record(route, '→');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _record(previousRoute, '← pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _record(newRoute, '⇄');
  }
}
