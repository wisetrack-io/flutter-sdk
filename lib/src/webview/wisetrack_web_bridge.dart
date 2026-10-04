import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/wisetrack_sdk.dart';
import '../entity/entity.dart';
import 'js_evaluator.dart';

/// Bridges WiseTrack calls made by JavaScript inside a WebView to the SDK.
///
/// **Security:** every page loaded in the WebView can call the bridge (read
/// IDFA/ADID, stop tracking, re-initialize with another token). If the WebView
/// can navigate to pages you do not control, restrict the bridge with
/// [allowedHosts] and [currentUrl]:
///
/// ```dart
/// WiseTrackWebBridge(
///   evaluator: FlutterWebViewJSEvaluator(controller),
///   allowedHosts: {'shop.example.com', '*.example.com'},
///   currentUrl: () async {
///     final url = await controller.currentUrl();
///     return url == null ? null : Uri.tryParse(url);
///   },
/// ).register();
/// ```
///
/// The check uses the URL of the top-level page, so it cannot tell apart
/// messages sent from iframes embedded in an allowed page.
class WiseTrackWebBridge {
  const WiseTrackWebBridge({
    required this.evaluator,
    this.allowedHosts,
    this.currentUrl,
  }) : assert(allowedHosts == null || currentUrl != null,
            'currentUrl is required when allowedHosts is set');

  final WiseTrackJsEvaluator evaluator;

  /// Hosts allowed to use the bridge; `*.example.com` also matches every
  /// subdomain of `example.com`. `null` (default) allows every page.
  final Set<String>? allowedHosts;

  /// Returns the URL of the page currently loaded in the WebView.
  /// Required when [allowedHosts] is set.
  final Future<Uri?> Function()? currentUrl;

  final String _bridgeName = 'FlutterWiseTrackBridge';

  void register() {
    evaluator.addJSChannelHandler(_bridgeName, (message) async {
      Map<String, dynamic> args = const {};
      try {
        final messageJson = jsonDecode(message) as Map<String, dynamic>;
        final method = messageJson['method'] as String;
        args = (messageJson['args'] as Map?)?.cast<String, dynamic>() ?? {};
        if (!await _isPageAllowed()) {
          throw StateError('page is not in allowedHosts, `$method` ignored');
        }
        await _handleCallback(method, args);
      } catch (e) {
        debugPrint('WiseTrackWebBridge: Failed to handle message: $e');
        // Resolve a pending JS promise instead of leaving it hanging forever.
        final callbackId = args['callbackId'];
        if (callbackId is String) await _respondToJs(callbackId, null);
      }
    });
  }

  void unregister() {
    evaluator.removeJSChannelHandler(_bridgeName);
  }

  Future<bool> _isPageAllowed() async {
    final hosts = allowedHosts;
    if (hosts == null) return true;
    final host = (await currentUrl?.call())?.host.toLowerCase();
    if (host == null || host.isEmpty) return false;
    return hosts.any((pattern) {
      final p = pattern.toLowerCase();
      if (p.startsWith('*.')) {
        final base = p.substring(2);
        return host == base || host.endsWith('.$base');
      }
      return host == p;
    });
  }

  Future<void> _respondToJs(String callbackId, dynamic result) async {
    final response = jsonEncode({
      'callbackId': callbackId,
      'data': result,
    });
    final escapedResponse = jsonEncode(response);
    final jsCode = 'WiseTrack.onNativeResponse(JSON.parse($escapedResponse));';
    await evaluator.evaluateJS(jsCode);
  }

  Future<void> _handleCallback(String method, Map<String, dynamic> args) async {
    switch (method) {
      case 'initialize':
        await WiseTrack.instance.init(WTInitialConfig.fromMap(args));
        break;
      case 'clearDataAndStop':
        await WiseTrack.instance.clearAndStop();
        break;
      case 'setLogLevel':
        await WiseTrack.instance
            .setLogLevel(WTLogLevelPriority.fromString(args['level']));
        break;
      case 'setEnabled':
        await WiseTrack.instance
            .setEnabled(args['enabled'].toString().toLowerCase() == 'true');
        break;
      case 'requestForATT':
        final isAuthorized = await WiseTrack.instance.iOSRequestForATT();
        await _respondToJs(args['callbackId'], isAuthorized);
        break;
      case 'getIDFA':
        final idfa = await WiseTrack.instance.getIdfa();
        await _respondToJs(args['callbackId'], idfa);
        break;
      case 'getADID':
        final adId = await WiseTrack.instance.getAdId();
        await _respondToJs(args['callbackId'], adId);
        break;
      case 'getReferrer':
        final referrer = await WiseTrack.instance.getReferrer();
        await _respondToJs(args['callbackId'], referrer);
        break;
      case 'startTracking':
        await WiseTrack.instance.startTracking();
        break;
      case 'stopTracking':
        await WiseTrack.instance.stopTracking();
        break;
      case 'destroy':
        break;
      case 'setPackagesInfo':
        await WiseTrack.instance.setPackagesInfo();
        break;
      case 'setFCMToken':
        await WiseTrack.instance.setFCMToken(args['token']);
        break;
      case 'setAPNSToken':
        await WiseTrack.instance.setAPNSToken(args['token']);
        break;
      case 'trackEvent':
        final type = args['type'].toString().toLowerCase();
        final eventParams = _parseParams(args['params']);
        final WTEvent event;
        if (type == WTEventType.defaultEvent.label) {
          event = WTEvent.defaultEvent(name: args['name'], params: eventParams);
        } else if (type == WTEventType.revenueEvent.label) {
          event = WTEvent.revenueEvent(
            name: args['name'],
            params: eventParams,
            // JSON integers (e.g. Rial amounts) decode as int.
            amount: (args['revenue'] as num).toDouble(),
            currency: _parseCurrency(args['currency']),
          );
        } else {
          throw Exception('Invalid event type, `$type`');
        }
        await WiseTrack.instance.trackEvent(event);
        break;
      case 'trackScreen':
        final WTScreen screen = WTScreen(
          args['name'] as String,
          _parseScreenType(args['type']),
          displayName: args['display_name'] as String?,
          trigger: args['trigger'] as String?,
          isAuto: args['is_auto'] == true,
          params: _parseParams(args['params']),
        );
        await WiseTrack.instance.trackScreen(screen);
        break;
      case 'isEnabled':
        final isEnabled = await WiseTrack.instance.isEnabled();
        await _respondToJs(args['callbackId'], isEnabled);
        break;
      default:
    }
  }

  Map<String, WTParam>? _parseParams(Object? raw) {
    if (raw is! Map) return null;
    final result = <String, WTParam>{};
    raw.forEach((key, value) {
      if (value is String || value is num || value is bool) {
        result[key.toString()] = WTParam.dynamic(value);
      }
    });
    return result.isEmpty ? null : result;
  }

  RevenueCurrency _parseCurrency(Object? raw) {
    final code = raw.toString().toUpperCase();
    if (code == 'ETH' || code == 'EHT') return RevenueCurrency.ETH;
    return RevenueCurrency.values.firstWhere(
      (c) => c.label == code,
      orElse: () => throw ArgumentError.value(raw, 'currency', 'Unsupported'),
    );
  }

  WTScreenType _parseScreenType(Object? raw) {
    final label = raw?.toString().toLowerCase();
    return WTScreenType.values.firstWhere(
      (t) => t.label == label || t.name.toLowerCase() == label,
      orElse: () => WTScreenType.other,
    );
  }
}
