import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wisetrack/src/config/channel_names.dart';
import 'package:wisetrack/src/config/wisetrack_method_channel.dart';
import 'package:wisetrack/src/resources/resources.dart';
import 'package:wisetrack/wisetrack.dart';

import 'wisetrack_method_channel_test.mocks.dart';

@GenerateMocks([MethodChannel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelWisetrack wisetrack;
  late MockMethodChannel mockChannel;

  const channel = MethodChannel('io.wisetrack.flutter');

  setUp(() {
    mockChannel = MockMethodChannel();
    wisetrack = MethodChannelWisetrack();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          return mockChannel.invokeMethod(call.method, call.arguments);
        });
  });

  tearDown(() {
    reset(mockChannel);
  });

  group('MethodChannelWisetrack', () {
    test('init succeeds with valid config', () async {
      final initConfig = WTInitialConfig(
        appToken: 'test_token',
        androidStore: WTAndroidStore.playstore,
        iOSStore: WTIOSStore.appstore,
        startTrackerAutomatically: true,
        trackingWattingTime: 10,
        userEnvironment: WTUserEnvironment.sandbox,
        appSecret: 'secret',
        attributionDeeplink: true,
        customDeviceId: 'custom_id',
        defaultTracker: 'tracker-1',
        eventBuffering: true,
        logLevel: WTLogLevel.info,
        secretId: 'secret_id',
      );

      when(
        mockChannel.invokeMethod(MethodChannelNames.methodInit, any),
      ).thenAnswer((_) async => null);

      await wisetrack.init(initConfig);

      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodInit, {
          'sdk_env': WTResources.defaultSdkEnvironment.name,
          'sdk_version': WTResources.sdkVersion,
          'app_token': initConfig.appToken,
          'user_environment': initConfig.userEnvironment.name,
          'android_store_name': initConfig.androidStore.name,
          'ios_store_name': initConfig.iOSStore.name,
          'tracking_waiting_time': initConfig.trackingWattingTime,
          'start_tracker_automatically': initConfig.startTrackerAutomatically,
          'custom_device_id': initConfig.customDeviceId,
          'default_tracker': initConfig.defaultTracker,
          'app_secret': initConfig.appSecret,
          'secret_id': initConfig.secretId,
          'attribution_deeplink': initConfig.attributionDeeplink,
          'event_buffering_enabled': initConfig.eventBuffering,
          'log_level': initConfig.logLevel.level,
          'oaid_enabled': initConfig.oaidEnabled,
          'referrer_enabled': initConfig.referrerEnabled,
        }),
      ).called(1);
    });

    test('init handles PlatformException', () async {
      final initConfig = WTInitialConfig(
        appToken: 'test_token',
        androidStore: WTAndroidStore.playstore,
        iOSStore: WTIOSStore.appstore,
        startTrackerAutomatically: true,
        trackingWattingTime: 10,
        userEnvironment: WTUserEnvironment.sandbox,
      );
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodInit, any),
      ).thenThrow(PlatformException(code: 'INIT_ERROR'));

      await expectLater(
        () => wisetrack.init(initConfig),
        prints(contains('Failed to initialize sdk')),
      );
    });

    test('enableTestMode succeeds', () async {
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodEnableTestMode),
      ).thenAnswer((_) async => null);

      await wisetrack.enableTestMode();
      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodEnableTestMode),
      ).called(1);
    });

    test('setLogLevel succeeds', () async {
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodSetLogLevel, any),
      ).thenAnswer((_) async => null);

      await wisetrack.setLogLevel(WTLogLevel.info);
      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodSetLogLevel, {
          "level": WTLogLevel.info.level,
        }),
      ).called(1);
    });

    test('setEnabled succeeds', () async {
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodSetEnabled, any),
      ).thenAnswer((_) async => null);

      await wisetrack.setEnabled(true);
      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodSetEnabled, {
          "enabled": true,
        }),
      ).called(1);
    });

    test('isEnabled succeeds', () async {
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodIsEnabled, any),
      ).thenAnswer((_) async => true);

      await wisetrack.isEnabled();
      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodIsEnabled),
      ).called(1);
    });

    test('iOSRequestForATT returns false on non-iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await wisetrack.iOSRequestForATT();
      expect(result, false);
      verifyNever(mockChannel.invokeMethod(any));
      debugDefaultTargetPlatformOverride = null;
    });

    test('iOSRequestForATT returns true on iOS', () async {
      when(
        mockChannel.invokeMethod(
          MethodChannelNames.methodIOSRequestForATT,
          any,
        ),
      ).thenAnswer((_) async => true);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await wisetrack.iOSRequestForATT();
      expect(result, true);

      verify(
        mockChannel.invokeMethod(
          MethodChannelNames.methodIOSRequestForATT,
          null,
        ),
      ).called(1);

      debugDefaultTargetPlatformOverride = null;
    });

    test('startTracking succeeds', () async {
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodStartTracking),
      ).thenAnswer((_) async => null);

      await wisetrack.startTracking();
      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodStartTracking),
      ).called(1);
    });

    test('stopTracking succeeds', () async {
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodStopTracking),
      ).thenAnswer((_) async => null);

      await wisetrack.stopTracking();
      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodStopTracking),
      ).called(1);
    });

    test('setAPNSToken succeeds', () async {
      const token = 'test-apns-token';
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodSetAPNSToken, any),
      ).thenAnswer((_) async => null);

      await wisetrack.setAPNSToken(token);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        verify(
          mockChannel.invokeMethod(MethodChannelNames.methodSetAPNSToken, {
            "token": token,
          }),
        ).called(1);
      } else {
        verifyNever(
          mockChannel.invokeMethod(MethodChannelNames.methodSetAPNSToken, {
            "token": token,
          }),
        );
      }
    });

    test('setFCMToken succeeds', () async {
      const token = 'test-fcm-token';
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodSetFCMToken, any),
      ).thenAnswer((_) async => null);

      await wisetrack.setFCMToken(token);
      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodSetFCMToken, {
          "token": token,
        }),
      ).called(1);
    });

    test('logEvent Default succeeds', () async {
      final event = WTEvent.defaultEvent(
        name: "test_event-1",
        params: {
          'key-1': EventParameter.string("val"),
          'key-2': EventParameter.number(1.5),
          'key-3': EventParameter.boolean(true),
        },
      );

      when(
        mockChannel.invokeMethod(MethodChannelNames.methodLogEvent, any),
      ).thenAnswer((_) async => null);

      await wisetrack.logEvent(event);
      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodLogEvent, {
          "type": WTEventType.defaultEvent.name,
          "name": event.name,
          "params": {'key-1': "val", 'key-2': 1.5, 'key-3': true},
          "revenue": null,
          "currency": null,
        }),
      ).called(1);
    });

    test('logEvent Revenue succeeds', () async {
      final eventParams = {
        'key-1': EventParameter.string("val"),
        'key-2': EventParameter.number(1.5),
        'key-3': EventParameter.boolean(true),
      };
      final event = WTEvent.revenueEvent(
        name: "test_event-1",
        params: eventParams,
        amount: 100.0,
        currency: RevenueCurrency.AED,
      );

      when(
        mockChannel.invokeMethod(MethodChannelNames.methodLogEvent, any),
      ).thenAnswer((_) async => null);

      await wisetrack.logEvent(event);
      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodLogEvent, {
          "type": WTEventType.revenueEvent.name,
          "name": event.name,
          "params": {'key-1': "val", 'key-2': 1.5, 'key-3': true},
          "revenue": 100.0,
          "currency": 'AED',
        }),
      ).called(1);
    });

    test('getIDFA returns null on non-iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await wisetrack.getIdfa();
      expect(result, null);
      verifyNever(mockChannel.invokeMethod(any));
      debugDefaultTargetPlatformOverride = null;
    });

    test('getIDFA returns non-null on iOS', () async {
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodGetIdFA, any),
      ).thenAnswer((_) async => 'idfa');

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await wisetrack.getIdfa();
      expect(result, 'idfa');

      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodGetIdFA, null),
      ).called(1);

      debugDefaultTargetPlatformOverride = null;
    });

    test('getADID returns null on non-android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await wisetrack.getAdId();
      expect(result, null);
      verifyNever(mockChannel.invokeMethod(any));
      debugDefaultTargetPlatformOverride = null;
    });

    test('getIDFA returns non-null on android', () async {
      when(
        mockChannel.invokeMethod(MethodChannelNames.methodGetAdId, any),
      ).thenAnswer((_) async => 'adid');

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await wisetrack.getAdId();
      expect(result, 'adid');

      verify(
        mockChannel.invokeMethod(MethodChannelNames.methodGetAdId, null),
      ).called(1);

      debugDefaultTargetPlatformOverride = null;
    });

    test('methods handle PlatformException gracefully', () async {
      when(
        mockChannel.invokeMethod(any, any),
      ).thenThrow(PlatformException(code: 'ERROR'));

      await expectLater(
        () => wisetrack.init(WTInitialConfig(appToken: 'appToken')),
        prints(contains('Failed to initialize sdk')),
      );

      await expectLater(
        () => wisetrack.startTracking(),
        prints(contains('Failed to start tracking')),
      );

      await expectLater(
        () => wisetrack.stopTracking(),
        prints(contains('Failed to stop tracking')),
      );

      await expectLater(
        () => wisetrack.enableTestMode(),
        prints(contains('Failed to enable test mode')),
      );
    });
  });
}
