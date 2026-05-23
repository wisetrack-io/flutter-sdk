import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wisetrack/src/config/wisetrack_platform_interface.dart';
import 'package:wisetrack/wisetrack.dart';

// ---------- test doubles ----------

/// Records every [trackScreen] call so tests can assert on it.
class _CapturingPlatform
    with MockPlatformInterfaceMixin
    implements WisetrackPlatform {
  final List<WTScreen> screens = [];

  @override
  void registerMethodCallbacks() {}

  @override
  Future<void> trackScreen(WTScreen screen) async => screens.add(screen);

  @override
  Future<void> trackEvent(WTEvent event) async {}

  @override
  Future<void> clearAndStop() async {}

  @override
  Future<bool> iOSRequestForATT() async => false;

  @override
  Future<void> init(WTInitialConfig config) async {}

  @override
  void listenOnLogs(Function(String message) listener) {}

  @override
  Future<void> setAPNSToken(String apnsToken) async {}

  @override
  Future<void> setEnabled(bool enabled) async {}

  @override
  Future<void> setFCMToken(String fcmToken) async {}

  @override
  Future<void> setLogLevel(WTLogLevel level) async {}

  @override
  Future<void> startTracking() async {}

  @override
  Future<void> stopTracking() async {}

  @override
  Future<bool> isEnabled() async => true;

  @override
  Future<String?> getAdId() async => null;

  @override
  Future<String?> getReferrer() async => null;

  @override
  Future<String?> getIdfa() async => null;

  @override
  Future<void> setPackagesInfo() async {}

  @override
  Future<bool> isWiseTrackNotification(Map<String, dynamic> payload) async =>
      false;

  @override
  Future<String?> getLastDeeplink() async => null;

  @override
  Future<String?> getDeferredDeeplink() async => null;

  @override
  void onDeeplinkReceived(DeeplinkCallback callback) {}
}

/// Minimal named-route stub — only [settings] is used by the observer.
class _NamedRoute extends Fake implements Route<dynamic> {
  @override
  final RouteSettings settings;

  _NamedRoute(String? name, {Object? arguments})
      : settings = RouteSettings(name: name, arguments: arguments);
}

/// Stub that IS a [PopupRoute] for type-check assertions.
class _FakePopupRoute extends PopupRoute<void> {
  final String? routeName;

  _FakePopupRoute({this.routeName});

  @override
  RouteSettings get settings => RouteSettings(name: routeName);

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      const SizedBox.shrink();
}

// ---------- main ----------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _CapturingPlatform platform;

  setUp(() {
    platform = _CapturingPlatform();
    WisetrackPlatform.instance = platform;
  });

  // ─────────────────────────────────────────────────────────
  // WTScreen
  // ─────────────────────────────────────────────────────────

  group('WTScreen.toMap', () {
    test('serializes all fields', () {
      final screen = WTScreen(
        'checkout',
        WTScreenType.page,
        displayName: 'Checkout',
        params: {
          'items': WTParam.number(3),
          'promo': WTParam.boolean(true),
          'code': WTParam.string('SAVE10'),
        },
        isAuto: true,
      );
      final map = screen.toMap();

      expect(map['name'], 'checkout');
      expect(map['type'], 'page');
      expect(map['display_name'], 'Checkout');
      expect(map['is_auto'], true);
      expect(map['params'], {'items': 3, 'promo': true, 'code': 'SAVE10'});
    });

    test('null params and displayName stay null', () {
      final map = WTScreen('home', WTScreenType.page).toMap();
      expect(map['params'], isNull);
      expect(map['display_name'], isNull);
    });

    test('isAuto defaults to false', () {
      expect(WTScreen('x', WTScreenType.page).isAuto, false);
      expect(WTScreen('x', WTScreenType.page).toMap()['is_auto'], false);
    });
  });

  // ─────────────────────────────────────────────────────────
  // WTScreenType labels
  // ─────────────────────────────────────────────────────────

  group('WTScreenType.label', () {
    test('page → page', () => expect(WTScreenType.page.label, 'page'));
    test('dialog → dialog', () => expect(WTScreenType.dialog.label, 'dialog'));
    test('bottomSheet → bottom_sheet',
        () => expect(WTScreenType.bottomSheet.label, 'bottom_sheet'));
    test('other → other', () => expect(WTScreenType.other.label, 'other'));
  });

  // ─────────────────────────────────────────────────────────
  // WTParam
  // ─────────────────────────────────────────────────────────

  group('WTParam', () {
    test('string stores value', () => expect(WTParam.string('hi').value, 'hi'));
    test('number stores int', () => expect(WTParam.number(42).value, 42));
    test(
        'number stores double', () => expect(WTParam.number(3.14).value, 3.14));
    test('boolean stores value',
        () => expect(WTParam.boolean(false).value, false));

    group('dynamic factory', () {
      test('accepts String',
          () => expect(WTParam.dynamic('text').value, 'text'));
      test('accepts int', () => expect(WTParam.dynamic(99).value, 99));
      test('accepts bool', () => expect(WTParam.dynamic(true).value, true));
      test('rejects Object',
          () => expect(() => WTParam.dynamic(Object()), throwsException));
      test('rejects List',
          () => expect(() => WTParam.dynamic([1, 2]), throwsException));
      test('rejects null',
          () => expect(() => WTParam.dynamic(null), throwsException));
    });
  });

  // ─────────────────────────────────────────────────────────
  // ScreenDeduplicator
  // ─────────────────────────────────────────────────────────

  group('ScreenDeduplicator', () {
    test('first call always allowed', () {
      final d = ScreenDeduplicator(windowMs: 200);
      expect(d.shouldTrack('home'), true);
    });

    test('same name within window is rejected', () {
      final d = ScreenDeduplicator(windowMs: 200);
      d.shouldTrack('home');
      expect(d.shouldTrack('home'), false);
    });

    test('same name after window is allowed again', () async {
      final d = ScreenDeduplicator(windowMs: 50);
      d.shouldTrack('home');
      await Future.delayed(const Duration(milliseconds: 60));
      expect(d.shouldTrack('home'), true);
    });

    test('different name within window is allowed', () {
      final d = ScreenDeduplicator(windowMs: 200);
      d.shouldTrack('home');
      expect(d.shouldTrack('products'), true);
    });

    test('reset clears state so same name is allowed immediately', () {
      final d = ScreenDeduplicator(windowMs: 5000);
      d.shouldTrack('home');
      d.reset();
      expect(d.shouldTrack('home'), true);
    });
  });

  // ─────────────────────────────────────────────────────────
  // WTNavigatorObserver — route name resolution
  // ─────────────────────────────────────────────────────────

  group('WTNavigatorObserver name resolution', () {
    late WTNavigatorObserver observer;

    setUp(() {
      // Use a very short dedup window so consecutive different tests don't
      // interfere with each other.
      observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(deduplicationWindowMs: 0),
      );
    });

    test('leading slash stripped: /products → products', () {
      observer.didPush(_NamedRoute('/products'), null);
      expect(platform.screens.first.name, 'products');
    });

    test('nested path: /products/123 → products/123', () {
      observer.didPush(_NamedRoute('/products/123'), null);
      expect(platform.screens.first.name, 'products/123');
    });

    test('root / stays as /', () {
      observer.didPush(_NamedRoute('/'), null);
      expect(platform.screens.first.name, '/');
    });

    test('plain name without slash kept as-is: home → home', () {
      observer.didPush(_NamedRoute('home'), null);
      expect(platform.screens.first.name, 'home');
    });

    test('URI query params extracted as screen params', () {
      observer.didPush(_NamedRoute('/products?tab=reviews&page=2'), null);
      final screen = platform.screens.first;
      expect(screen.name, 'products');
      expect(screen.params?['tab']?.value, 'reviews');
      expect(screen.params?['page']?.value, '2');
    });

    test('empty query param values are ignored', () {
      observer.didPush(_NamedRoute('/search?q='), null);
      expect(platform.screens.first.params, isNull);
    });

    test('full URL: scheme + host + path', () {
      observer.didPush(_NamedRoute('https://app.example.com/checkout'), null);
      expect(platform.screens.first.name, 'https://app.example.com/checkout');
    });

    test('deep link with fragment', () {
      observer.didPush(_NamedRoute('/products#top'), null);
      expect(platform.screens.first.name, 'products#top');
    });

    test('route with Map arguments merged into params', () {
      observer.didPush(
        _NamedRoute('/checkout', arguments: {'cart_id': 'abc', 'total': 99.0}),
        null,
      );
      final params = platform.screens.first.params;
      expect(params?['cart_id']?.value, 'abc');
      expect(params?['total']?.value, 99.0);
    });

    test('non-Map arguments are ignored', () {
      observer.didPush(_NamedRoute('/home', arguments: 'some_string'), null);
      expect(platform.screens.first.params, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────
  // WTNavigatorObserver — screen type resolution
  // ─────────────────────────────────────────────────────────

  group('WTNavigatorObserver screen type', () {
    setUp(() {
      // Enable dialogs so popup routes are not filtered out.
      WisetrackPlatform.instance = platform;
    });

    test('regular route → page', () {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(deduplicationWindowMs: 0),
      );
      observer.didPush(_NamedRoute('/home'), null);
      expect(platform.screens.first.type, WTScreenType.page);
    });

    testWidgets('PopupRoute → dialog', (tester) async {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(
          trackDialogs: true,
          deduplicationWindowMs: 0,
        ),
      );
      observer.didPush(_FakePopupRoute(routeName: '/confirm'), null);
      expect(platform.screens.first.type, WTScreenType.dialog);
    });
  });

  // ─────────────────────────────────────────────────────────
  // WTNavigatorObserver — isAuto flag
  // ─────────────────────────────────────────────────────────

  group('WTNavigatorObserver isAuto', () {
    test('auto-tracked screen has isAuto = true', () {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(deduplicationWindowMs: 0),
      );
      observer.didPush(_NamedRoute('/home'), null);
      expect(platform.screens.first.isAuto, true);
    });
  });

  // ─────────────────────────────────────────────────────────
  // WTNavigatorObserver — filtering
  // ─────────────────────────────────────────────────────────

  group('WTNavigatorObserver filtering', () {
    test('enabled=false tracks nothing', () {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(enabled: false),
      );
      observer.didPush(_NamedRoute('/home'), null);
      expect(platform.screens, isEmpty);
    });

    test('excludedScreens skips matching screen', () {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(
          excludedScreens: {'home'},
          deduplicationWindowMs: 0,
        ),
      );
      observer.didPush(_NamedRoute('/home'), null);
      expect(platform.screens, isEmpty);
    });

    test('excludePatterns skips matching screen', () {
      final observer = WTNavigatorObserver(
        config: WTScreenTrackingConfig(
          excludePatterns: [RegExp(r'^internal/.*')],
          deduplicationWindowMs: 0,
        ),
      );
      observer.didPush(_NamedRoute('/internal/debug'), null);
      expect(platform.screens, isEmpty);
    });

    test('excludePatterns does not skip non-matching screen', () {
      final observer = WTNavigatorObserver(
        config: WTScreenTrackingConfig(
          excludePatterns: [RegExp(r'^internal/.*')],
          deduplicationWindowMs: 0,
        ),
      );
      observer.didPush(_NamedRoute('/products'), null);
      expect(platform.screens, hasLength(1));
    });

    testWidgets('trackDialogs=false (default) skips PopupRoute',
        (tester) async {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(
          trackDialogs: false,
          deduplicationWindowMs: 0,
        ),
      );
      observer.didPush(_FakePopupRoute(routeName: '/dialog'), null);
      expect(platform.screens, isEmpty);
    });

    testWidgets('trackDialogs=true tracks PopupRoute', (tester) async {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(
          trackDialogs: true,
          deduplicationWindowMs: 0,
        ),
      );
      observer.didPush(_FakePopupRoute(routeName: '/confirm'), null);
      expect(platform.screens, hasLength(1));
    });
  });

  // ─────────────────────────────────────────────────────────
  // WTNavigatorObserver — didPop / didReplace
  // ─────────────────────────────────────────────────────────

  group('WTNavigatorObserver didPop / didReplace', () {
    late WTNavigatorObserver observer;

    setUp(() {
      observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(deduplicationWindowMs: 0),
      );
    });

    test('didPop tracks previousRoute', () {
      observer.didPop(_NamedRoute('/products'), _NamedRoute('/home'));
      expect(platform.screens, hasLength(1));
      expect(platform.screens.first.name, 'home');
    });

    test('didPop with null previousRoute tracks nothing', () {
      observer.didPop(_NamedRoute('/home'), null);
      expect(platform.screens, isEmpty);
    });

    test('didReplace tracks newRoute', () {
      observer.didReplace(
        newRoute: _NamedRoute('/settings'),
        oldRoute: _NamedRoute('/home'),
      );
      expect(platform.screens, hasLength(1));
      expect(platform.screens.first.name, 'settings');
    });

    test('didReplace with null newRoute tracks nothing', () {
      observer.didReplace(newRoute: null, oldRoute: _NamedRoute('/home'));
      expect(platform.screens, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────
  // WTNavigatorObserver — deduplication
  // ─────────────────────────────────────────────────────────

  group('WTNavigatorObserver deduplication', () {
    test('duplicate push within window is suppressed', () {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(deduplicationWindowMs: 500),
      );
      observer.didPush(_NamedRoute('/home'), null);
      observer.didPush(_NamedRoute('/home'), null);
      expect(platform.screens, hasLength(1));
    });

    test('same route after window is tracked again', () async {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(deduplicationWindowMs: 50),
      );
      observer.didPush(_NamedRoute('/home'), null);
      await Future.delayed(const Duration(milliseconds: 60));
      observer.didPush(_NamedRoute('/home'), null);
      expect(platform.screens, hasLength(2));
    });

    test('different routes within window are both tracked', () {
      final observer = WTNavigatorObserver(
        config: const WTScreenTrackingConfig(deduplicationWindowMs: 500),
      );
      observer.didPush(_NamedRoute('/home'), null);
      observer.didPush(_NamedRoute('/products'), null);
      expect(platform.screens, hasLength(2));
    });
  });

  // ─────────────────────────────────────────────────────────
  // WTNavigatorObserver — screenDataProvider
  // ─────────────────────────────────────────────────────────

  group('WTNavigatorObserver screenDataProvider', () {
    test('provider overrides name and displayName', () {
      final observer = WTNavigatorObserver(
        config: WTScreenTrackingConfig(
          deduplicationWindowMs: 0,
          screenDataProvider: (_) => WTScreenDataProvider(
            screenName: 'custom_screen',
            screenDisplayName: 'Custom Screen',
          ),
        ),
      );
      observer.didPush(_NamedRoute('/anything'), null);
      final screen = platform.screens.first;
      expect(screen.name, 'custom_screen');
      expect(screen.displayName, 'Custom Screen');
    });

    test('provider returning null falls through to default resolution', () {
      final observer = WTNavigatorObserver(
        config: WTScreenTrackingConfig(
          deduplicationWindowMs: 0,
          screenDataProvider: (_) => null,
        ),
      );
      observer.didPush(_NamedRoute('/products'), null);
      expect(platform.screens.first.name, 'products');
    });

    test('provider with empty screenName falls through to default', () {
      final observer = WTNavigatorObserver(
        config: WTScreenTrackingConfig(
          deduplicationWindowMs: 0,
          screenDataProvider: (_) => WTScreenDataProvider(screenName: ''),
        ),
      );
      observer.didPush(_NamedRoute('/home'), null);
      expect(platform.screens.first.name, 'home');
    });

    test('provider params merged into screen params', () {
      final observer = WTNavigatorObserver(
        config: WTScreenTrackingConfig(
          deduplicationWindowMs: 0,
          screenDataProvider: (_) => WTScreenDataProvider(
            screenName: 'item',
            screenParams: {'source': 'home_feed'},
          ),
        ),
      );
      observer.didPush(_NamedRoute('/item'), null);
      expect(platform.screens.first.params?['source']?.value, 'home_feed');
    });
  });
}
