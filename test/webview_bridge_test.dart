import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wisetrack/src/config/wisetrack_platform_interface.dart';
import 'package:wisetrack/wisetrack.dart';

class _RecordingPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements WisetrackPlatform {
  final screens = <WTScreen>[];
  final events = <WTEvent>[];

  @override
  Future<void> trackScreen(WTScreen screen) async => screens.add(screen);

  @override
  Future<void> trackEvent(WTEvent event) async => events.add(event);

  @override
  Future<bool> isEnabled() async => true;
}

class _FakeEvaluator implements WiseTrackJsEvaluator {
  JSMessageCallback? handler;
  final scripts = <String>[];

  @override
  void addJSChannelHandler(String name, JSMessageCallback messageCallback) {
    handler = messageCallback;
  }

  @override
  void removeJSChannelHandler(String name) => handler = null;

  @override
  Future<void> evaluateJS(String script) async => scripts.add(script);

  Future<void> send(String method, Map<String, dynamic> args) =>
      handler!(jsonEncode({'method': method, 'args': args}));
}

void main() {
  late _RecordingPlatform platform;
  late _FakeEvaluator evaluator;

  setUp(() {
    platform = _RecordingPlatform();
    WisetrackPlatform.instance = platform;
    evaluator = _FakeEvaluator();
    WiseTrackWebBridge(evaluator: evaluator).register();
  });

  group('trackScreen', () {
    test('parses screen type label and all fields', () async {
      await evaluator.send('trackScreen', {
        'name': 'checkout',
        'type': 'bottom_sheet',
        'display_name': 'Checkout',
        'trigger': 'push',
        'is_auto': true,
        'params': {'items': 3, 'promo': true, 'code': 'X'},
      });

      final screen = platform.screens.single;
      expect(screen.name, 'checkout');
      expect(screen.type, WTScreenType.bottomSheet);
      expect(screen.displayName, 'Checkout');
      expect(screen.trigger, 'push');
      expect(screen.isAuto, true);
      expect(screen.params?.map((k, v) => MapEntry(k, v.value)),
          {'items': 3, 'promo': true, 'code': 'X'});
    });

    test('unknown or missing type falls back to other', () async {
      await evaluator.send('trackScreen', {'name': 'a', 'type': 'weird'});
      await evaluator.send('trackScreen', {'name': 'b'});
      expect(platform.screens.map((s) => s.type),
          [WTScreenType.other, WTScreenType.other]);
    });
  });

  group('trackEvent', () {
    test('revenue event accepts an integer amount', () async {
      await evaluator.send('trackEvent', {
        'type': 'revenue',
        'name': 'purchase',
        'revenue': 50000,
        'currency': 'IRR',
      });
      final event = platform.events.single;
      expect(event.revenueAmount, 50000.0);
      expect(event.revenueCurrency, RevenueCurrency.IRR);
    });

    test('ETH and legacy EHT codes both map to ETH', () async {
      for (final code in ['ETH', 'EHT']) {
        await evaluator.send('trackEvent', {
          'type': 'revenue',
          'name': 'purchase',
          'revenue': 1.5,
          'currency': code,
        });
      }
      expect(platform.events.map((e) => e.revenueCurrency),
          [RevenueCurrency.ETH, RevenueCurrency.ETH]);
      expect(RevenueCurrency.ETH.label, 'EHT');
    });

    test('invalid message does not throw', () async {
      await evaluator.send('trackEvent', {
        'type': 'revenue',
        'name': 'purchase',
        'revenue': 1,
        'currency': 'NOPE',
      });
      expect(platform.events, isEmpty);
    });
  });

  test('failed request still resolves the pending JS callback', () async {
    await evaluator.send('getIDFA', {'callbackId': 'cb_1'});
    expect(evaluator.scripts.single, contains('cb_1'));
  });

  group('allowedHosts', () {
    Future<void> sendFrom(String? url) async {
      final evaluator = _FakeEvaluator();
      WiseTrackWebBridge(
        evaluator: evaluator,
        allowedHosts: const {'shop.example.com', '*.trusted.io'},
        currentUrl: () async => url == null ? null : Uri.parse(url),
      ).register();
      await evaluator.send('trackScreen', {'name': 'x', 'type': 'page'});
    }

    test('allows exact and wildcard hosts', () async {
      await sendFrom('https://shop.example.com/cart');
      await sendFrom('https://a.trusted.io/');
      await sendFrom('https://trusted.io/');
      expect(platform.screens, hasLength(3));
    });

    test('blocks other hosts and unknown URL', () async {
      await sendFrom('https://evil.com/');
      await sendFrom('https://example.com/');
      await sendFrom('https://nottrusted.io/');
      await sendFrom(null);
      expect(platform.screens, isEmpty);
    });
  });
}
