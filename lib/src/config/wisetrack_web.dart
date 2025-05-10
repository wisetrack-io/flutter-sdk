// // In order to *not* need this ignore, consider extracting the "web" version
// // of your plugin as a separate package, instead of inlining it in the same
// // package as the core of your plugin.
// // ignore: avoid_web_libraries_in_flutter

// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// import 'package:wisetrack/src/entity/entity.dart';

// import 'wisetrack_platform_interface.dart';

// /// A web implementation of the WisetrackPlatform of the Wisetrack plugin.
// class WisetrackWeb extends WisetrackPlatform {
//   /// Constructs a WisetrackWeb
//   WisetrackWeb();

//   static void registerWith(Registrar registrar) {
//     WisetrackPlatform.instance = WisetrackWeb();
//   }

//   @override
//   void listenOnLogs(Function(String message) listener) {
//     // TODO: implement listenOnLogs
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> enableTestMode() {
//     // TODO: implement enableTestMode
//     throw UnimplementedError();
//   }

//   @override
//   Future<bool> iOSRequestForATT() {
//     // TODO: implement iOSRequestForATT
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> init(WTInitialConfig initConfig) {
//     // TODO: implement init
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> logEvent(WTEvent event) {
//     // TODO: implement logEvent
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> setAPNSToken(String apnsToken) {
//     // TODO: implement setAPNSToken
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> setEnabled(bool enabled) {
//     // TODO: implement setEnabled
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> setFCMToken(String fcmToken) {
//     // TODO: implement setFCMToken
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> setLogLevel(WTLogLevel level) {
//     // TODO: implement setLogLevel
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> startTracking() {
//     // TODO: implement startTracking
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> stopTracking() {
//     // TODO: implement stopTracking
//     throw UnimplementedError();
//   }

//   @override
//   Future<bool> isEnabled() {
//     // TODO: implement isEnabled
//     throw UnimplementedError();
//   }

//   @override
//   Future<String?> getAdId() {
//     // TODO: implement getAdId
//     throw UnimplementedError();
//   }

//   @override
//   Future<String?> getIdfa() {
//     // TODO: implement getIdfa
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> setPackagesInfo() {
//     // TODO: implement setPackagesInfo
//     throw UnimplementedError();
//   }
// }
