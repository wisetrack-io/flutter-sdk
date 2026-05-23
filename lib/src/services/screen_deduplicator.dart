part of 'navigator_observer.dart';

class ScreenDeduplicator {
  final int windowMs;
  String? _lastName;
  int _lastTime = 0;

  ScreenDeduplicator({this.windowMs = 100});

  bool shouldTrack(String name) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (name == _lastName && (now - _lastTime) < windowMs) {
      return false;
    }
    _lastName = name;
    _lastTime = now;
    return true;
  }

  void reset() {
    _lastName = null;
    _lastTime = 0;
  }
}
