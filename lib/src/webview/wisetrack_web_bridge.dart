import 'dart:convert';

import 'package:wisetrack/src/config/config.dart';
import 'package:wisetrack/src/entity/entity.dart';

import 'js_evaluator.dart';

class WiseTrackWebBridge {
  const WiseTrackWebBridge({required this.evaluator});

  final WiseTrackJsEvaluator evaluator;

  final String _bridgeName = 'FlutterWiseTrackBridge';

  void register() {
    evaluator.addJSChannelHandler(_bridgeName, (message) async {
      Map<String, dynamic> messageJson = jsonDecode(message);
      final method = messageJson['method'];
      final args = messageJson['args'];
      await _handleCallback(method, args);
    });
  }

  void unregister() {
    evaluator.removeJSChannelHandler(_bridgeName);
  }

  Future<void> _respondToJs(String callbackId, dynamic result) async {
    final response = jsonEncode({
      'callbackId': callbackId,
      'data': result,
    });
    final escapedResponse = jsonEncode(response);
    final jsCode = 'WiseTrack.onNativeResponse(JSON.parse($escapedResponse));';
    await evaluator.evaluateJS(jsCode);
  }

  Future<void> _handleCallback(String method, Map<String, dynamic> args) async {
    switch (method) {
      case 'initialize':
        await WiseTrack.instance.init(WTInitialConfig.fromMap(args));
        break;
      case 'clearDataAndStop':
        await WiseTrack.instance.enableTestMode();
        break;
      case 'setLogLevel':
        await WiseTrack.instance
            .setLogLevel(WTLogLevelPriority.fromString(args['level']));
        break;
      case 'setEnabled':
        await WiseTrack.instance
            .setEnabled(args['enabled'].toString().toLowerCase() == 'true');
        break;
      case 'requestForATT':
        final isAuthorized = await WiseTrack.instance.iOSRequestForATT();
        await _respondToJs(args['callbackId'], isAuthorized);
        break;
      case 'getIDFA':
        final idfa = await WiseTrack.instance.getIdfa();
        await _respondToJs(args['callbackId'], idfa);
        break;
      case 'getADID':
        final adId = await WiseTrack.instance.getAdId();
        await _respondToJs(args['callbackId'], adId);
        break;
      case 'getReferrer':
        final referrer = await WiseTrack.instance.getReferrer();
        await _respondToJs(args['callbackId'], referrer);
        break;
      case 'startTracking':
        await WiseTrack.instance.startTracking();
        break;
      case 'stopTracking':
        await WiseTrack.instance.stopTracking();
        break;
      case 'destroy':
        break;
      case 'setPackagesInfo':
        await WiseTrack.instance.setPackgesInfo();
        break;
      case 'setFCMToken':
        await WiseTrack.instance.setFCMToken(args['token']);
        break;
      case 'setAPNSToken':
        await WiseTrack.instance.setAPNSToken(args['token']);
        break;
      case 'logEvent':
        final type = args['type'].toString().toLowerCase();
        final eventParams = (args['params'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, EventParameter.dynamic(v)));
        final WTEvent event;
        if (type == WTEventType.defaultEvent.label) {
          event = WTEvent.defaultEvent(name: args['name'], params: eventParams);
        } else if (type == WTEventType.revenueEvent.label) {
          event = WTEvent.revenueEvent(
            name: args['name'],
            params: eventParams,
            amount: args['revenue'],
            currency: RevenueCurrency.values.firstWhere((v) =>
                v.label.toLowerCase() ==
                args['currency'].toString().toLowerCase()),
          );
        } else {
          throw Exception('Invalid event type, `$type`');
        }
        await WiseTrack.instance.logEvent(event);
        break;
      case 'isEnabled':
        final isEnabled = await WiseTrack.instance.isEnabled();
        await _respondToJs(args['callbackId'], isEnabled);
        break;
      default:
    }
  }
}
