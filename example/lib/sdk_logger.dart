import 'dart:async';

/// Global SDK log manager. Call [listenOnLogs] once (from HomeScreen.initState)
/// to start capturing WiseTrack SDK log messages. All UI components that need
/// the log (AppBar button, global FAB, etc.) read from this singleton.
class SdkLogger {
  static final SdkLogger instance = SdkLogger._();
  SdkLogger._();

  final List<String> logs = [];
  final StreamController<List<String>> controller =
      StreamController<List<String>>.broadcast();

  void add(String message) {
    logs.add(message);
    controller.add(List.from(logs));
  }
}
