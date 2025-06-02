import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wisetrack/wisetrack.dart';

import 'webview_js_evaluators.dart';

class WebViewFlutterScreen extends StatefulWidget {
  const WebViewFlutterScreen({Key? key}) : super(key: key);

  @override
  State<WebViewFlutterScreen> createState() => _WebViewFlutterScreenState();
}

class _WebViewFlutterScreenState extends State<WebViewFlutterScreen> {
  WebViewController? _controller;
  late WiseTrackWebBridge webBridge;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  Future<void> _initWebViewController() async {
    final String fileHtmlContents =
        await rootBundle.loadString('assets/html/test.html');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    webBridge =
        WiseTrackWebBridge(evaluator: FlutterWebViewJSEvaluator(_controller!));
    webBridge.register();

    _controller!.loadHtmlString(fileHtmlContents, baseUrl: "https://localhost");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('webview_flutter Example')),
      body: _controller == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : WebViewWidget(controller: _controller!),
    );
  }

  @override
  void dispose() {
    webBridge.unregister();
    super.dispose();
  }
}
