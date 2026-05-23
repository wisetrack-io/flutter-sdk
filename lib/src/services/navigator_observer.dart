import 'package:flutter/material.dart' show ModalBottomSheetRoute;
import 'package:flutter/widgets.dart';
import 'package:wisetrack/wisetrack.dart' show WiseTrack;

import '../entity/config/screen_tracking_config.dart';
import '../entity/screen/screen.dart';
import '../entity/wt_param.dart';

part 'screen_deduplicator.dart';

/// A [NavigatorObserver] that automatically tracks screen views via WiseTrack.
///
/// Add an instance to your [MaterialApp.navigatorObservers] (or equivalent)
/// and configure behaviour through [WTScreenTrackingConfig].
///
/// Works with any routing package that uses Flutter's [Navigator] under the
/// hood — including go_router, GetX, auto_route, Beamer, and plain Navigator
/// 1.0/2.0 — without requiring any per-screen setup.
///
/// **Setup:**
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     WTNavigatorObserver(
///       config: WTScreenTrackingConfig(
///         enabled: true,
///         excludedScreens: {'/splash'},
///       ),
///     ),
///   ],
///   ...
/// )
/// ```
///
/// **Screen name resolution priority (highest → lowest):**
/// 1. [WTScreenTrackingConfig.screenDataProvider] — full manual override.
/// 2. [RouteSettings.name] — parsed as a URI; query params become screen params.
/// 3. Widget class name extracted from [Route.runtimeType] (e.g. `ProductPage`).
class WTNavigatorObserver extends NavigatorObserver {
  /// The configuration controlling which screens are tracked and how.
  /// The configuration controlling which screens are tracked and how.
  final WTScreenTrackingConfig config;
  late final _deduplicator =
      ScreenDeduplicator(windowMs: config.deduplicationWindowMs);

  /// Creates a [WTNavigatorObserver] with the given [config].
  ///
  /// All fields default to sensible values — pass a [WTScreenTrackingConfig]
  /// only when you need to customise behaviour.
  WTNavigatorObserver({this.config = const WTScreenTrackingConfig()});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRoute(route, trigger: 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _trackRoute(previousRoute, trigger: 'pop');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _trackRoute(newRoute, trigger: 'replace');
    }
  }

  void _trackRoute(Route<dynamic> route, {required String trigger}) {
    if (!config.enabled) return;

    final data = _resolveScreenData(route);
    if (data == null) return;

    if (_shouldSkip(data.name, route)) return;

    if (!_deduplicator.shouldTrack(data.name)) return;

    // Merge priority (highest wins): screenDataProvider > URI query > route args > auto
    final merged = {
      ..._extractArgsParams(route),
      ...?_convertParams(data.uriQueryParams),
      ...?_convertParams(data.params),
    };

    final screen = WTScreen(
      data.name,
      _resolveScreenType(route),
      displayName: data.displayName,
      params: merged.isEmpty ? null : merged,
      isAuto: true,
      trigger: trigger,
    );

    WiseTrack.instance.trackScreen(screen);
  }

  _ScreenData? _resolveScreenData(Route<dynamic> route) {
    // Priority 1: custom screenDataProvider
    if (config.screenDataProvider != null) {
      final provided = config.screenDataProvider!(route);
      if (provided != null && provided.screenName.isNotEmpty) {
        return _ScreenData(
          name: provided.screenName,
          displayName: provided.screenDisplayName,
          params: provided.screenParams,
        );
      }
    }

    // Priority 2: RouteSettings.name — parse as URI to get name + query params
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      return _parseRouteName(route.settings.name!);
    }

    // Priority 3: runtimeType — extract widget class name
    final typeName = _extractNameFromType(route.runtimeType.toString());
    if (_isInternalRoute(typeName)) return null;
    return _ScreenData(
      name: typeName,
      displayName: _camelToDisplayName(typeName),
    );
  }

  /// Parses a route name (path, full URL, or deep link) into a screen name,
  /// display name, and query params — mirrors Android extractScreenData logic.
  _ScreenData _parseRouteName(String rawName) {
    Uri? uri;
    try {
      uri = Uri.parse(rawName);
    } catch (_) {}

    if (uri == null) {
      final cleaned = _cleanPath(rawName);
      return _ScreenData(
        name: cleaned,
        displayName: _pathToDisplayName(cleaned),
      );
    }

    // Build normalized screen name from URI parts
    final path = uri.path;
    final normalizedPath = _normalizePath(uri);

    final nameBuffer = StringBuffer();
    if (uri.hasScheme && uri.host.isNotEmpty) {
      // Full URL: scheme://host[:port][/path][#fragment]
      nameBuffer.write('${uri.scheme}://${uri.host}');
      if (uri.hasPort) nameBuffer.write(':${uri.port}');
      if (normalizedPath.isNotEmpty) nameBuffer.write(normalizedPath);
      if (uri.fragment.isNotEmpty) nameBuffer.write('#${uri.fragment}');
    } else {
      // Relative path like /product/123 or product/:id
      final cleaned = _cleanPath(path.isEmpty ? rawName : path);
      nameBuffer.write(cleaned);
      if (uri.fragment.isNotEmpty) nameBuffer.write('#${uri.fragment}');
    }

    final name = nameBuffer.toString();
    final queryParams = _extractQueryParams(uri);

    return _ScreenData(
      name: name.isEmpty ? '/' : name,
      displayName: _pathToDisplayName(name),
      uriQueryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  String _normalizePath(Uri uri) {
    final path = uri.path;
    if (uri.fragment.isNotEmpty && path.isEmpty) return '/';
    if (path.isEmpty || path == '/') return '';
    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }

  /// Extracts query parameters from URI, skips empty values.
  Map<String, dynamic> _extractQueryParams(Uri uri) {
    final result = <String, dynamic>{};
    for (final key in uri.queryParametersAll.keys) {
      final values = uri.queryParametersAll[key]!;
      if (values.isEmpty) continue;
      final value = values.first;
      if (value.isEmpty) continue;
      result[key] = value;
    }
    return result;
  }

  /// Extracts route.settings.arguments if it's a Map.
  Map<String, WTParam> _extractArgsParams(Route<dynamic> route) {
    final args = route.settings.arguments;
    if (args is! Map) return const {};
    final result = <String, WTParam>{};
    args.forEach((k, v) {
      if (k is! String) return;
      final param = _toParam(v);
      if (param != null) result[k] = param;
    });
    return result;
  }

  String _cleanPath(String name) {
    var cleaned = name;
    if (cleaned.startsWith('/')) cleaned = cleaned.substring(1);
    // Strip query string if somehow present without URI parsing
    final qIdx = cleaned.indexOf('?');
    if (qIdx != -1) cleaned = cleaned.substring(0, qIdx);
    return cleaned.isEmpty ? '/' : cleaned;
  }

  /// `MaterialPageRoute<ProductPage>` → `ProductPage`
  String _extractNameFromType(String typeName) {
    final match = RegExp(r'<([^<>]+)>').firstMatch(typeName);
    if (match != null) {
      final inner = match.group(1)!;
      if (inner != 'dynamic' && inner != 'void') return inner;
    }
    return typeName.replaceFirst(RegExp(r'^_'), '');
  }

  /// `product/123` → `Product`, `product/:id` → `Product`
  String _pathToDisplayName(String path) {
    if (!path.contains('/') && !path.contains(':') && !path.contains('://')) {
      return _camelToDisplayName(path);
    }
    // For URL-like: use last meaningful non-param segment
    final withoutScheme = path.contains('://') ? path.split('://').last : path;
    final parts = withoutScheme
        .split('/')
        .where((p) => p.isNotEmpty && !p.startsWith(':') && !p.contains('#'))
        .toList();
    if (parts.isEmpty) return path;
    final segment = parts.last;
    // Remove common path ID patterns like `123` — use second-to-last segment
    final meaningful =
        _isId(segment) && parts.length > 1 ? parts[parts.length - 2] : segment;
    return meaningful[0].toUpperCase() + meaningful.substring(1);
  }

  bool _isId(String segment) =>
      RegExp(r'^\d+$').hasMatch(segment) || segment.startsWith(':');

  /// `ProductPage` → `Product Page`, `ProductRoute` → `Product`, `search` → `Search`
  String _camelToDisplayName(String name) {
    var cleaned = name
        .replaceAll(RegExp(r'Route$'), '')
        .replaceAll(RegExp(r'Screen$'), '')
        .replaceAll(RegExp(r'Page$'), '');
    if (cleaned.isEmpty) cleaned = name;
    final result = cleaned
        .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
        .trim();
    if (result.isEmpty) return cleaned;
    return result[0].toUpperCase() + result.substring(1);
  }

  bool _isInternalRoute(String name) =>
      name.startsWith('_') ||
      name == 'dynamic' ||
      name == 'void' ||
      name.startsWith('ModalBarrier') ||
      name.startsWith('Overlay');

  WTScreenType _resolveScreenType(Route<dynamic> route) {
    if (route is ModalBottomSheetRoute) return WTScreenType.bottomSheet;
    if (route is PopupRoute) return WTScreenType.dialog;
    return WTScreenType.page;
  }

  bool _shouldSkip(String name, Route<dynamic> route) {
    if (route is PopupRoute && !config.trackDialogs) return true;
    if (config.excludedScreens.contains(name)) return true;
    for (final pattern in config.excludePatterns) {
      if (pattern.hasMatch(name)) return true;
    }
    return false;
  }

  Map<String, WTParam>? _convertParams(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) return null;
    final result = <String, WTParam>{};
    raw.forEach((k, v) {
      final param = v is WTParam ? v : _toParam(v);
      if (param != null) result[k] = param;
    });
    return result.isEmpty ? null : result;
  }

  WTParam? _toParam(dynamic v) {
    try {
      return WTParam.dynamic(v);
    } catch (e) {
      return null;
    }
  }
}

class _ScreenData {
  final String name;
  final String? displayName;
  final Map<String, dynamic>? params; // from screenDataProvider
  final Map<String, dynamic>? uriQueryParams; // from URI query string

  const _ScreenData({
    required this.name,
    this.displayName,
    this.params,
    this.uriQueryParams,
  });
}
