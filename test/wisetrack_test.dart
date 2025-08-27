import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wisetrack/src/config/wisetrack_method_channel.dart';
import 'package:wisetrack/src/config/wisetrack_platform_interface.dart';
import 'package:wisetrack/wisetrack.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final WisetrackPlatform initialPlatform = WisetrackPlatform.instance;

  group('WisetrackTests', () {
    test('MethodChannelWisetrack is the default instance', () {
      expect(initialPlatform, isInstanceOf<MethodChannelWisetrack>());
    });

    test('check iOS Request for ATT', () async {
      WiseTrack wisetrackPlugin = WiseTrack.instance;
      MockWisetrackPlatform fakePlatform = MockWisetrackPlatform();
      WisetrackPlatform.instance = fakePlatform;

      expect(await wisetrackPlugin.iOSRequestForATT(), true);
    });

    test('check get ADID for android', () async {
      WiseTrack wisetrackPlugin = WiseTrack.instance;
      MockWisetrackPlatform fakePlatform = MockWisetrackPlatform();
      WisetrackPlatform.instance = fakePlatform;

      expect(await wisetrackPlugin.getAdId(), "adid");
    });

    test('check get IDFA for iOS', () async {
      WiseTrack wisetrackPlugin = WiseTrack.instance;
      MockWisetrackPlatform fakePlatform = MockWisetrackPlatform();
      WisetrackPlatform.instance = fakePlatform;

      expect(await wisetrackPlugin.getIdfa(), "idfa");
    });

    test('check is tracking enabled', () async {
      WiseTrack wisetrackPlugin = WiseTrack.instance;
      MockWisetrackPlatform fakePlatform = MockWisetrackPlatform();
      WisetrackPlatform.instance = fakePlatform;

      expect(await wisetrackPlugin.isEnabled(), true);
    });
  });
}

class MockWisetrackPlatform
    with MockPlatformInterfaceMixin
    implements WisetrackPlatform {
  @override
  Future<void> enableTestMode() async {}

  @override
  Future<bool> iOSRequestForATT() {
    return Future.delayed(const Duration(seconds: 1), () => true);
  }

  @override
  Future<void> init(WTInitialConfig initConfig) {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  void listenOnLogs(Function(String message) listener) {}

  @override
  Future<void> logEvent(WTEvent event) {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  Future<void> setAPNSToken(String apnsToken) {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  Future<void> setEnabled(bool enabled) {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  Future<void> setFCMToken(String fcmToken) {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  Future<void> setLogLevel(WTLogLevel level) {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  Future<void> startTracking() {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  Future<void> stopTracking() {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  Future<String?> getAdId() {
    return Future.delayed(const Duration(seconds: 1), () => "adid");
  }

  @override
  Future<String?> getIdfa() {
    return Future.delayed(const Duration(seconds: 1), () => "idfa");
  }

  @override
  Future<bool> isEnabled() {
    return Future.delayed(const Duration(seconds: 1), () => true);
  }

  @override
  Future<void> setPackagesInfo() {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  Future<String?> getReferrer() {
    return Future.delayed(const Duration(seconds: 1), () => null);
  }

  @override
  Future<bool> isWiseTrackNotification(Map<String, dynamic> payload) {
    return Future.delayed(const Duration(seconds: 1), () => false);
  }
}
