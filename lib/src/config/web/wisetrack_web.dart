import 'dart:async';
// ignore: deprecated_member_use
import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'wisetrack_web_impl.dart';

/// Web-specific implementation of the Wisetrack plugin.
class WisetrackPlugin {
  static bool _sdkScriptLoaded = false;
  static Completer<void>? _loadingCompleter;

  static void registerWith(Registrar registrar) {
    _loadSDKScript();

    WisetrackWebImpl.registerWith(registrar);
  }

  static Future<void> _loadSDKScript() async {
    if (_sdkScriptLoaded) return;
    if (_loadingCompleter != null) return _loadingCompleter!.future;

    _loadingCompleter = Completer<void>();

    try {
      final script = ScriptElement();
      script.src = 'https://unpkg.com/wisetrack/dist/cdn/sdk.bundle.min.js';
      // script.src = 'sdk.bundle.min.js';
      script.type = 'text/javascript';
      script.async = true;

      script.onLoad.listen((_) {
        _sdkScriptLoaded = true;
        _loadingCompleter?.complete();
      });

      script.onError.listen((error) {
        _loadingCompleter?.completeError('Failed to load WiseTrack SDK');
      });

      document.head?.append(script);
    } catch (e) {
      _loadingCompleter?.completeError(e);
    }

    return _loadingCompleter!.future;
  }

  static Future<void> ensureSDKLoaded() async {
    if (_sdkScriptLoaded) return;
    if (_loadingCompleter != null) {
      return _loadingCompleter!.future;
    }
    return _loadSDKScript();
  }
}
