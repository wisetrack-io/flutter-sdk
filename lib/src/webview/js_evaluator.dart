typedef JSMessageCallback = Future<void> Function(String message);

abstract class WiseTrackJsEvaluator {
  void addJSChannelHandler(String name, JSMessageCallback messageCallback);

  void removeJSChannelHandler(String name);

  Future<void> evaluateJS(String script);
}
