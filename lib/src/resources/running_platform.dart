import 'package:flutter/foundation.dart';

enum Platforms { web, android, ios }

class RunningPlatform {
  static Platforms? _current;

  static Platforms? get current {
    if (_current != null) {
      return _current;
    }
    if (kIsWeb) {
      return Platforms.web;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Platforms.android;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Platforms.ios;
    }
    return null;
  }

  @visibleForTesting
  static set currentOverride(Platforms? platform) {
    if (!kDebugMode) {
      throw Exception('Cannot override current platform in non-debug mode');
    }
    _current = platform;
  }

  static bool get isWeb => current == Platforms.web;
  static bool get isAndroid => current == Platforms.android;
  static bool get isIOS => current == Platforms.ios;
}
