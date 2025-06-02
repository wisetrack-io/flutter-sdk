import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../entity/entity.dart';
import 'wisetrack_method_channel.dart';

/// An abstract platform interface for interacting with the WiseTrack library in Flutter.
///
/// This class provides a contract for platform-specific implementations (e.g., Android, iOS)
/// and should be extended by any platform-specific class to provide its own implementation.
abstract class WisetrackPlatform extends PlatformInterface {
  /// Constructs a `WisetrackPlatform`.
  WisetrackPlatform() : super(token: _token);

  static final Object _token = Object();

  static WisetrackPlatform _instance = MethodChannelWisetrack();

  /// The default instance of `WisetrackPlatform` to use.
  ///
  /// Defaults to [MethodChannelWisetrack].
  static WisetrackPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// class that extends `WisetrackPlatform` when they register themselves.
  static set instance(WisetrackPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void listenOnLogs(Function(String message) listener);

  Future<void> init(WTInitialConfig initConfig);

  Future<void> enableTestMode();

  Future<void> setLogLevel(WTLogLevel level);

  Future<void> setEnabled(bool enabled);

  Future<bool> isEnabled();

  Future<bool> iOSRequestForATT();

  Future<void> startTracking();

  Future<void> stopTracking();

  Future<void> setAPNSToken(String apnsToken);

  Future<void> setFCMToken(String fcmToken);

  Future<void> setPackagesInfo();

  Future<void> logEvent(WTEvent event);

  Future<String?> getAdId();

  Future<String?> getReferrer();

  Future<String?> getIdfa();
}
