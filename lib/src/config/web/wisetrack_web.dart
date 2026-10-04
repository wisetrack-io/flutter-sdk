import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'wisetrack_web_impl.dart';

/// Web-specific implementation of the Wisetrack plugin.
class WisetrackPlugin {
  /// Version of the WiseTrack JS SDK this plugin release is built against.
  static const jsSdkVersion = '2.3.0';

  /// CDN sources for the pinned JS SDK, tried in order.
  static const sdkUrls = [
    'https://cdn.jsdelivr.net/npm/wisetrack@$jsSdkVersion/dist/cdn/sdk.bundle.min.js',
    'https://unpkg.com/wisetrack@$jsSdkVersion/dist/cdn/sdk.bundle.min.js',
  ];

  /// Matches a WiseTrack SDK `<script>` the app added itself (or one injected earlier).
  static const _existingScriptSelector =
      'script[data-wisetrack-sdk], script[src*="wisetrack"][src*="sdk.bundle"]';

  static const _loadTimeout = Duration(seconds: 15);

  static Future<void>? _loading;

  static void registerWith(Registrar registrar) {
    // Start loading as early as possible
    ensureSDKLoaded().catchError(
      (Object e) => debugPrint('WisetrackWeb: $e'),
    );

    WisetrackWebImpl.registerWith(registrar);
  }

  static bool get _isLoaded => globalContext.has('WiseTrackSDK');

  /// Completes once the JS SDK global (`WiseTrackSDK`) is available.
  ///
  /// A failed attempt is not cached, so a later call retries.
  static Future<void> ensureSDKLoaded() {
    if (_isLoaded) return Future.value();

    return _loading ??= _load().then(
      (_) {},
      onError: (Object e, StackTrace s) {
        _loading = null;
        return Future<void>.error(e, s);
      },
    );
  }

  static Future<void> _load() async {
    final existing = web.document.querySelector(_existingScriptSelector)
        as web.HTMLScriptElement?;
    if (existing != null) {
      await _waitForScript(existing);
      if (_isLoaded) return;
      debugPrint(
          'WisetrackWeb: WiseTrack script on the page (${existing.src}) did not load, falling back to CDN');
    }

    final errors = <Object>[];
    for (final url in sdkUrls) {
      try {
        await _injectScript(url);
        if (_isLoaded) return;
        errors.add('$url loaded but did not define WiseTrackSDK');
      } catch (e) {
        errors.add(e);
      }
    }
    throw StateError(
        'WiseTrack web SDK could not be loaded: ${errors.join('; ')}');
  }

  /// Waits for a script that is already in the document
  static Future<void> _waitForScript(web.HTMLScriptElement script) {
    final completer = Completer<void>();
    void finish() {
      if (!completer.isCompleted) completer.complete();
    }

    final listener = ((web.Event _) => finish()).toJS;
    script.addEventListener('load', listener);
    script.addEventListener('error', listener);

    // The script may have finished before the listeners were attached.
    final poll = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_isLoaded) finish();
    });

    return completer.future
        .timeout(_loadTimeout, onTimeout: () {})
        .whenComplete(() {
      poll.cancel();
      script.removeEventListener('load', listener);
      script.removeEventListener('error', listener);
    });
  }

  static Future<void> _injectScript(String url) {
    final completer = Completer<void>();
    final script =
        web.document.createElement('script') as web.HTMLScriptElement;
    script
      ..src = url
      ..async = true
      ..setAttribute('data-wisetrack-sdk', jsSdkVersion);

    script.addEventListener(
      'load',
      ((web.Event _) {
        if (!completer.isCompleted) completer.complete();
      }).toJS,
    );
    script.addEventListener(
      'error',
      ((web.Event _) {
        script.remove();
        if (!completer.isCompleted) {
          completer.completeError(StateError('Failed to load $url'));
        }
      }).toJS,
    );

    web.document.head!.appendChild(script);

    return completer.future.timeout(_loadTimeout, onTimeout: () {
      script.remove();
      throw TimeoutException('Timed out loading $url', _loadTimeout);
    });
  }
}
