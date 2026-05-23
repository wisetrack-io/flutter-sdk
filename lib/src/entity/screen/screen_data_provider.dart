/// Custom screen data returned by a [WTScreenTrackingConfig.screenDataProvider] callback.
///
/// Return a [WTScreenDataProvider] from your callback to override the automatic
/// name and display-name resolution for a specific [Route]. Return `null` to
/// fall back to the default resolution logic.
///
/// Example:
/// ```dart
/// WTScreenTrackingConfig(
///   screenDataProvider: (route) {
///     if (route.settings.name == '/item') {
///       return WTScreenDataProvider(
///         screenName: 'item_detail',
///         screenDisplayName: 'Item Detail',
///         screenParams: {'source': 'home_feed'},
///       );
///     }
///     return null;
///   },
/// )
/// ```
class WTScreenDataProvider {
  WTScreenDataProvider({
    required this.screenName,
    this.screenDisplayName,
    this.screenParams,
  });

  /// Technical screen identifier used as the analytics key.
  final String screenName;

  /// Human-readable label shown in the analytics dashboard.
  final String? screenDisplayName;

  /// Optional key-value metadata to attach to this screen view.
  final Map<String, dynamic>? screenParams;
}
