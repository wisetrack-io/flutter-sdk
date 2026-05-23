import 'package:flutter/widgets.dart';

import '../screen/screen_data_provider.dart';

/// Configuration for automatic screen tracking via [WTNavigatorObserver].
///
/// Pass an instance to [WTInitialConfig.screenTrackingConfig] and add
/// [WTNavigatorObserver] to your navigator observers to enable auto-tracking.
///
/// Example:
/// ```dart
/// WTInitialConfig(
///   appToken: 'your-app-token',
///   clientSecret: 'your-client-secret',
///   screenTrackingConfig: WTScreenTrackingConfig(
///     enabled: true,
///     trackDialogs: false,
///     excludedScreens: {'/splash', '/onboarding'},
///     excludePatterns: [RegExp(r'^/internal/.*')],
///   ),
/// )
/// ```
class WTScreenTrackingConfig {
  /// Whether automatic screen tracking is active.
  ///
  /// Set to `false` to disable auto-tracking globally while keeping
  /// [WTNavigatorObserver] in the observers list.
  final bool enabled;

  /// Whether dialogs and popups (routes extending [PopupRoute]) are tracked.
  ///
  /// Bottom sheets are always distinguished from dialogs regardless of this flag.
  final bool trackDialogs;

  /// Screen names to exclude from automatic tracking.
  ///
  /// Matched against the resolved screen [name] (after URI normalization).
  final Set<String> excludedScreens;

  /// Regular expression patterns for excluding screens by name.
  ///
  /// Any screen whose name matches at least one pattern is skipped.
  final List<RegExp> excludePatterns;

  /// Optional callback to supply custom screen data for a given [Route].
  ///
  /// Called with highest priority — before route-name parsing and runtime-type
  /// fallback. Return a [WTScreenDataProvider] to override name/displayName/params,
  /// or `null` to continue with automatic resolution.
  final WTScreenDataProvider? Function(Route<dynamic> route)?
      screenDataProvider;

  /// Minimum interval in milliseconds between consecutive events for the same screen.
  ///
  /// Prevents duplicate events caused by push+pop or rapid navigation.
  /// Defaults to `500` ms.
  final int deduplicationWindowMs;

  const WTScreenTrackingConfig({
    this.enabled = true,
    this.trackDialogs = false,
    this.excludedScreens = const {},
    this.excludePatterns = const [],
    this.screenDataProvider,
    this.deduplicationWindowMs = 500,
  });
}
