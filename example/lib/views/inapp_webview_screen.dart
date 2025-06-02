import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wisetrack/wisetrack.dart';
import 'package:wisetrack_example/views/webview_js_evaluators.dart';

class InAppWebViewScreen extends StatefulWidget {
  const InAppWebViewScreen({Key? key}) : super(key: key);

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  InAppWebViewController? webViewController;
  late WiseTrackWebBridge webBridge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('InAppWebView Example')),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/html/test.html'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return InAppWebView(
            initialData: InAppWebViewInitialData(data: snapshot.data!),
            onWebViewCreated: (controller) {
              webViewController = controller;

              webBridge = WiseTrackWebBridge(
                  evaluator: InAppWebViewJSEvaluator(controller));
              webBridge.register();
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    webBridge.unregister();
    super.dispose();
  }
}
