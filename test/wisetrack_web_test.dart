import 'package:flutter_test/flutter_test.dart';
import 'package:wisetrack/src/entity/entity.dart';
import 'package:wisetrack/src/resources/running_platform.dart';
import 'package:wisetrack/wisetrack.dart';

void main() {
  setUp(() {
    RunningPlatform.currentOverride = Platforms.web;
  });

  tearDown(() {
    RunningPlatform.currentOverride = null;
  });

  group('Web Configuration Tests', () {
    test('webAppVersion is required for web platform', () {
      expect(
        () => WTInitialConfig(
          appToken: 'test_token',
          // webAppVersion is missing - should throw assertion error
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('allows webAppVersion for web platform', () {
      expect(
        () => WTInitialConfig(
          appToken: 'test_token',
          webAppVersion: '1.0.0',
        ),
        returnsNormally,
      );
    });

    test('creates config with all web-specific parameters', () {
      final config = WTInitialConfig(
        appToken: 'web_token',
        webAppVersion: '2.0.0',
        userEnvironment: WTUserEnvironment.sandbox,
        logLevel: WTLogLevel.debug,
        trackingWaitingTime: 5,
        startTrackerAutomatically: true,
        customDeviceId: 'web_device_id',
        defaultTracker: 'web_tracker',
        appSecret: 'web_secret',
        secretId: 'web_secret_id',
        attributionDeeplink: true,
        eventBuffering: true,
        oaidEnabled: false,
        referrerEnabled: true,
      );

      expect(config.appToken, 'web_token');
      expect(config.webAppVersion, '2.0.0');
      expect(config.userEnvironment, WTUserEnvironment.sandbox);
      expect(config.logLevel, WTLogLevel.debug);
      expect(config.trackingWaitingTime, 5);
      expect(config.startTrackerAutomatically, true);
      expect(config.customDeviceId, 'web_device_id');
      expect(config.defaultTracker, 'web_tracker');
      expect(config.appSecret, 'web_secret');
      expect(config.secretId, 'web_secret_id');
      expect(config.attributionDeeplink, true);
      expect(config.eventBuffering, true);
      expect(config.oaidEnabled, false);
      expect(config.referrerEnabled, true);
    });
  });

  group('Web Event Handling Tests', () {
    test('creates web-specific default event with parameters', () {
      final event = WTEvent.defaultEvent(
        name: 'web_test_event',
        params: {
          'web_param1': EventParameter.string('web_value'),
          'web_param2': EventParameter.number(42.5),
          'web_param3': EventParameter.boolean(true),
        },
      );

      expect(event.name, 'web_test_event');
      expect(event.type, WTEventType.defaultEvent);
      expect(event.params?['web_param1']?.value, 'web_value');
      expect(event.params?['web_param2']?.value, 42.5);
      expect(event.params?['web_param3']?.value, true);
    });

    test('creates web-specific revenue event', () {
      final event = WTEvent.revenueEvent(
        name: 'web_purchase',
        params: {
          'product_id': EventParameter.string('web_product_123'),
          'quantity': EventParameter.number(2),
        },
        amount: 99.99,
        currency: RevenueCurrency.USD,
      );

      expect(event.name, 'web_purchase');
      expect(event.type, WTEventType.revenueEvent);
      expect(event.revenueAmount, 99.99);
      expect(event.revenueCurrency, RevenueCurrency.USD);
      expect(event.params?['product_id']?.value, 'web_product_123');
      expect(event.params?['quantity']?.value, 2);
    });

    test('handles complex event parameters for web', () {
      final event = WTEvent.revenueEvent(
        name: 'web_complex_purchase',
        params: {
          'product_name': EventParameter.string('Web Product'),
          'price': EventParameter.number(29.99),
          'is_premium': EventParameter.boolean(true),
          'category': EventParameter.string('web_apps'),
          'quantity': EventParameter.number(1),
        },
        amount: 29.99,
        currency: RevenueCurrency.EUR,
      );

      expect(event.name, 'web_complex_purchase');
      expect(event.type, WTEventType.revenueEvent);
      expect(event.revenueAmount, 29.99);
      expect(event.revenueCurrency, RevenueCurrency.EUR);
      expect(event.params?['product_name']?.value, 'Web Product');
      expect(event.params?['price']?.value, 29.99);
      expect(event.params?['is_premium']?.value, true);
      expect(event.params?['category']?.value, 'web_apps');
      expect(event.params?['quantity']?.value, 1);
    });

    test('handles empty event parameters for web', () {
      final event = WTEvent.defaultEvent(name: 'web_simple_event');

      expect(event.name, 'web_simple_event');
      expect(event.type, WTEventType.defaultEvent);
      expect(event.params, null);
    });
  });

  group('Web Configuration Validation', () {
    test('validates webAppVersion requirement', () {
      // Test that assertion error is thrown when webAppVersion is missing
      expect(
        () => WTInitialConfig(appToken: 'test_token'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts valid web configuration', () {
      final config = WTInitialConfig(
        appToken: 'web_app_token',
        webAppVersion: '3.0.0',
        userEnvironment: WTUserEnvironment.production,
        logLevel: WTLogLevel.info,
        trackingWaitingTime: 0,
        startTrackerAutomatically: true,
      );

      expect(config.appToken, 'web_app_token');
      expect(config.webAppVersion, '3.0.0');
      expect(config.userEnvironment, WTUserEnvironment.production);
      expect(config.logLevel, WTLogLevel.info);
      expect(config.trackingWaitingTime, 0);
      expect(config.startTrackerAutomatically, true);
    });

    test('handles web configuration with minimal parameters', () {
      final config = WTInitialConfig(
        appToken: 'minimal_token',
        webAppVersion: '1.0.0',
      );

      expect(config.appToken, 'minimal_token');
      expect(config.webAppVersion, '1.0.0');
      // Test default values
      expect(config.userEnvironment, WTUserEnvironment.production);
      expect(config.androidStore, WTAndroidStore.other);
      expect(config.iOSStore, WTIOSStore.other);
      expect(config.trackingWaitingTime, 0);
      expect(config.startTrackerAutomatically, true);
      expect(config.oaidEnabled, false);
      expect(config.referrerEnabled, true);
    });
  });

  group('Web Platform Detection', () {
    test('validates platform-specific behavior for web', () {
      // This test verifies that the configuration properly handles web platform
      // by requiring webAppVersion when kIsWeb is true
      final config = WTInitialConfig(
        appToken: 'web_token',
        webAppVersion: '1.0.0',
      );

      // Verify that web-specific configuration is properly set
      expect(config.webAppVersion, isNotNull);
      expect(config.webAppVersion, '1.0.0');
    });

    test('handles web-specific event parameter types', () {
      // Test various parameter types that might be used in web events
      final event = WTEvent.defaultEvent(
        name: 'web_parameter_test',
        params: {
          'string_param': EventParameter.string('test_string'),
          'number_param': EventParameter.number(123.45),
          'boolean_param': EventParameter.boolean(true),
          'integer_param': EventParameter.number(42),
          'float_param': EventParameter.number(3.14159),
        },
      );

      expect(event.params?['string_param']?.value, 'test_string');
      expect(event.params?['number_param']?.value, 123.45);
      expect(event.params?['boolean_param']?.value, true);
      expect(event.params?['integer_param']?.value, 42);
      expect(event.params?['float_param']?.value, 3.14159);
    });
  });

  group('Web Event Type Validation', () {
    test('validates web event types', () {
      final defaultEvent = WTEvent.defaultEvent(name: 'web_default');
      final revenueEvent = WTEvent.revenueEvent(
        name: 'web_revenue',
        amount: 10.0,
        currency: RevenueCurrency.USD,
      );

      expect(defaultEvent.type, WTEventType.defaultEvent);
      expect(revenueEvent.type, WTEventType.revenueEvent);
    });

    test('handles web revenue event with different currencies', () {
      final usdEvent = WTEvent.revenueEvent(
        name: 'usd_purchase',
        amount: 10.0,
        currency: RevenueCurrency.USD,
      );

      final eurEvent = WTEvent.revenueEvent(
        name: 'eur_purchase',
        amount: 10.0,
        currency: RevenueCurrency.EUR,
      );

      final aedEvent = WTEvent.revenueEvent(
        name: 'aed_purchase',
        amount: 10.0,
        currency: RevenueCurrency.AED,
      );

      expect(usdEvent.revenueCurrency, RevenueCurrency.USD);
      expect(eurEvent.revenueCurrency, RevenueCurrency.EUR);
      expect(aedEvent.revenueCurrency, RevenueCurrency.AED);
    });
  });
}
