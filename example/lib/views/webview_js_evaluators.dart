import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wisetrack/wisetrack.dart';

class InAppWebViewJSEvaluator implements WiseTrackJsEvaluator {
  final InAppWebViewController controller;
  InAppWebViewJSEvaluator(this.controller);

  @override
  void addJSChannelHandler(String name, JSMessageCallback messageCallback) {
    controller.addJavaScriptHandler(
      handlerName: name,
      callback: (messages) => messageCallback(messages.first),
    );
  }

  @override
  Future<void> evaluateJS(String script) {
    return controller.evaluateJavascript(source: script);
  }

  @override
  void removeJSChannelHandler(String name) {
    controller.removeJavaScriptHandler(handlerName: name);
  }
}

class FlutterWebViewJSEvaluator implements WiseTrackJsEvaluator {
  final WebViewController controller;
  FlutterWebViewJSEvaluator(this.controller);

  @override
  void addJSChannelHandler(String name, JSMessageCallback messageCallback) {
    controller.addJavaScriptChannel(
      name,
      onMessageReceived: (message) => messageCallback(message.message),
    );
  }

  @override
  Future<void> evaluateJS(String script) {
    return controller.runJavaScript(script);
  }

  @override
  void removeJSChannelHandler(String name) {
    controller.removeJavaScriptChannel(name);
  }
}
