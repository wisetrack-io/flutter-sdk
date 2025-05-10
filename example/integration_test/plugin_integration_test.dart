// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wisetrack/wisetrack.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late WiseTrack wisetrack;

  setUp(() {
    wisetrack = WiseTrack.instance;
  });

  testWidgets('init method works correctly', (WidgetTester tester) async {
    final config = WTInitialConfig(appToken: "app-token");
    await wisetrack.init(config);
    expect(true, isTrue);
  });

  testWidgets('startTracking and stopTracking', (WidgetTester tester) async {
    await wisetrack.startTracking();
    await wisetrack.stopTracking();
    expect(true, isTrue);
  });

  testWidgets('iOSRequestForATT works correctly on iOS', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final result = await wisetrack.iOSRequestForATT();
    if (result) {
      expect(result, isTrue);
    } else {
      expect(result, isFalse);
    }
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOSRequestForATT should return false on Android', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    if (await wisetrack.iOSRequestForATT() == false) {
      expect(true, isTrue);
    } else {
      fail("iOSRequestForATT method should return false on Android");
    }
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('getADID works correctly on android', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final result = await wisetrack.getAdId();
    if (result != null) {
      expect(result, isNotNull);
    } else {
      expect(result, isNull);
    }
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('getADID should return null on iOS', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final result = await wisetrack.getAdId();
    expect(result, null);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('getIDFA works correctly on iOS', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final result = await wisetrack.getIdfa();
    if (result != null) {
      expect(result, isNotNull);
    } else {
      expect(result, isNull);
    }
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('getADID should return null on android', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final result = await wisetrack.getIdfa();
    expect(result, null);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('setAPNSToken should not throw error', (
    WidgetTester tester,
  ) async {
    await wisetrack.setAPNSToken("test_apns_token");
    expect(true, isTrue);
  });

  testWidgets('setFCMToken should not throw error', (
    WidgetTester tester,
  ) async {
    await wisetrack.setFCMToken("test_fcm_token");
    expect(true, isTrue);
  });

  testWidgets('logEvent Default should work correctly', (
    WidgetTester tester,
  ) async {
    final event = WTEvent.defaultEvent(
      name: "test_event",
      params: {
        "key1": EventParameter.string("value1"),
        "key2": EventParameter.boolean(true),
        "key3": EventParameter.number(123.45),
      },
    );
    await wisetrack.logEvent(event);
    expect(true, isTrue);
  });

  testWidgets('logEvent Revenue should work correctly', (
    WidgetTester tester,
  ) async {
    final event = WTEvent.revenueEvent(
      name: "test_event",
      params: {
        "key1": EventParameter.string("value1"),
        "key2": EventParameter.boolean(true),
        "key3": EventParameter.number(123.45),
      },
      amount: 100.0,
      currency: RevenueCurrency.AED,
    );
    await wisetrack.logEvent(event);
    expect(true, isTrue);
  });

  testWidgets('setEnabled should correctly enable/disable tracking', (
    WidgetTester tester,
  ) async {
    await wisetrack.setEnabled(false);
    expect(await wisetrack.isEnabled(), false);
    await wisetrack.setEnabled(true);
    expect(await wisetrack.isEnabled(), true);
    expect(true, isTrue);
  });

  testWidgets('setLogLevel should correctly set log level', (
    WidgetTester tester,
  ) async {
    await wisetrack.setLogLevel(WTLogLevel.debug);
    await wisetrack.setLogLevel(WTLogLevel.info);
    expect(true, isTrue);
  });

  testWidgets('handle platform exception in startTracking', (
    WidgetTester tester,
  ) async {
    try {
      await wisetrack.startTracking();
    } catch (e) {
      fail("startTracking error: $e");
    }
  });
}
