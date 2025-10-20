import 'dart:io';

import 'package:flutter/foundation.dart';

enum AppPlatform {
  android,
  ios,
  web;

  static AppPlatform get _current {
    if (kIsWeb) {
      return AppPlatform.web;
    }
    if (Platform.isIOS) {
      return AppPlatform.ios;
    }
    return AppPlatform.android;
  }

  static bool get isAndroid => AppPlatform._current == AppPlatform.android;
  static bool get isIos => AppPlatform._current == AppPlatform.ios;
  static bool get isWeb => AppPlatform._current == AppPlatform.web;
}
