☀︎ Languages: English | [Persian (فارسی) 🇮🇷](https://github.com/wisetrack-io/flutter-sdk/blob/main/README.fa.md)

# WiseTrack Flutter Plugin

The **WiseTrack** Flutter plugin offers a cross-platform solution to accelerate your app’s growth — helping you increase users, boost revenue, and reduce costs, all at once.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Initialization](#initialization)
- [Basic Usage](#basic-usage)
  - [Enabling/Disabling Tracking](#enablingdisabling-tracking)
  - [Requesting App Tracking Transparency (ATT) Permission (iOS)](#requesting-app-tracking-transparency-att-permission-ios)
  - [Starting/Stopping Tracking](#startingstopping-tracking)
  - [Uninstall Detection and Setting Push Notification Tokens](#uninstall-detection-and-setting-push-notification-tokens)
  - [Deep Link Handling](#deep-link-handling)
  - [Logging Custom Events](#logging-custom-events)
  - [Setting Log Levels](#setting-log-levels)
  - [Retrieving Advertising IDs](#retrieving-advertising-ids)
- [Advanced Usage](#advanced-usage)
  - [Customizing SDK Behavior](#customizing-sdk-behavior)
  - [WebView Integration](#webview-integration)
- [Example Project](#example-project)
- [Breaking Changes](#breaking-changes)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features

- Cross-platform tracking for iOS, Android, and Web
- Support for custom and revenue event logging
- Push notification token management (APNs and FCM)
- App Tracking Transparency (ATT) support for iOS with configurable behavior
- Deep link and deferred deep link handling
- Configurable logging levels
- Advertising ID retrieval (IDFA for iOS, Ad ID for Android)
- Web platform support with JavaScript interop integration
- Platform-specific configuration classes for Android and iOS
- Unified API across all platforms (mobile and web)

## Requirements

- Flutter 2.0.0 or later
- Dart 2.12.0 or later
- iOS 11.0 or later
- Android embedding v2 enabled
- Android API 21 (Lollipop) or later
- Android Gradle Plugin >= 7.1.0 for full compatibility with Java 17

## Installation

To integrate the WiseTrack Flutter Plugin into your Flutter project, follow these steps:

1. **Add the dependency**:
   Add the `wisetrack` plugin to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     wisetrack: ^2.3.0 # Replace with the latest version
   ```

2. **Install the package**:
   Run the following command in your project directory:

   ```bash
   flutter pub get
   ```

3. **Configure iOS**:
   To support App Tracking Transparency (ATT) on iOS, add the following key to your `ios/Runner/Info.plist`:

   ```xml
   <key>NSUserTrackingUsageDescription</key>
   <string>We use this data to provide a better user experience and personalized ads.</string>
   ```

4. **Configure Android**:
   Ensure your `android/app/build.gradle` has the following settings:

   ```gradle
   android {
       compileSdkVersion 33
       defaultConfig {
           minSdkVersion 21
           targetSdkVersion 33
       }
   }
   ```

   **Android Permissions**:
   To enable the WiseTrack SDK to access device information and network features on Android, add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

   If your app does not target the Google Play Store (e.g., CafeBazaar, Myket), add these additional permissions:

   ```xml
   <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
   <uses-permission android:name="android.permission.READ_PHONE_STATE" />
   ```

   **Feature-Specific Dependencies (Android)**:
   The WiseTrack SDK supports additional Android features that require specific dependencies. Add only the dependencies for the features you need in `android/app/build.gradle`:

   - **Google Advertising ID (Ad ID)**: Enables retrieval of the Google Advertising ID via `getAdId()`.

     ```gradle
     implementation 'com.google.android.gms:play-services-ads-identifier:18.2.0'
     ```

   - **Open Advertising ID (OAID)**: Enables OAID as an alternative to Ad ID for devices without Google Play Services (e.g., Chinese devices) via `WTInitialConfig` with `oaidEnabled: true`.

     ```gradle
     implementation 'io.wisetrack.sdk:oaid:2.0.0' // Replace with the latest version
     ```

   - **Huawei Ads Identifier**: Enables Ad ID retrieval on Huawei devices.
     add repository:

   ```gradle
   maven { url 'https://developer.huawei.com/repo/' }
   ```

   and this dependency:

   ```gradle
   implementation 'com.huawei.hms:ads-identifier:3.4.62.300'
   ```

   - **Referrer Tracking**: Enables referrer tracking for Google Play and CafeBazaar via `WTInitialConfig` with `referrerEnabled: true`.

     ```gradle
     implementation 'io.wisetrack.sdk:referrer:2.0.0' // Replace with the latest version
     implementation 'com.android.installreferrer:installreferrer:2.2' // Google Play referrer
     implementation 'com.github.cafebazaar:referrersdk:1.0.2' // CafeBazaar referrer
     ```

   - **Firebase Installation ID (FID)**: Enables retrieval of a unique Firebase Installation ID for device identification.

     ```gradle
     implementation 'com.google.firebase:firebase-installations:17.2.0'
     ```

     To use Firebase services, register your app in the Firebase Console:

     - Add your package name (e.g., `com.example.app`).
     - Download the `google-services.json` file and place it in `android/app/`.
     - Update `android/build.gradle`:
       ```gradle
       buildscript {
           dependencies {
               classpath 'com.google.gms:google-services:4.4.1' // Or latest version
           }
       }
       ```
     - Apply the Google Services plugin in `android/app/build.gradle`:
       ```gradle
       apply plugin: 'com.google.gms.google-services'
       ```

   - **AppSet ID**: Provides additional device identification for analytics.
     ```gradle
     implementation 'com.google.android.gms:play-services-appset:16.1.0'
     ```

6. **Rebuild the project**:
   Run your project to ensure all dependencies are correctly integrated:
   ```bash
   flutter run
   ```

## Initialization

To start using the WiseTrack Flutter Plugin, initialize it with a configuration object in your app's entry point (e.g., `main.dart`).

### Example

```dart
import 'package:flutter/material.dart';
import 'package:wisetrack/wisetrack.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WiseTrack
  final config = WTInitialConfig(
    appToken: 'your-app-token',
    clientSecret: 'your-client-secret', // Required for authentication
    webAppVersion: kIsWeb ? '1.0.0' : null, // Required for web platform
    userEnvironment: WTUserEnvironment.production, // Use .sandbox for testing
    androidConfig: WTAndroidConfig(
      store: WTAndroidStore.playstore,
      oaidEnabled: false,
    ),
    iOSConfig: WTIOSConfig(
      store: WTIOSStore.appstore,
      attWaitingInterval: 30,
      requestATTAutomatically: true,
    ),
    logLevel: WTLogLevel.warning,
  );

  await WiseTrack.instance.init(config);

  runApp(MyApp());
}
```

**Note**: Replace `'your-app-token'` and `'your-client-secret'` with the credentials provided by the WiseTrack dashboard.

## Basic Usage

Below are common tasks you can perform with the WiseTrack Flutter Plugin.

### Enabling/Disabling Tracking

Enable or disable tracking at runtime:

```dart
// Enable tracking
await WiseTrack.instance.setEnabled(true);

// Disable tracking
await WiseTrack.instance.setEnabled(false);

// Check if tracking is enabled
bool isTrackingEnabled = await WiseTrack.instance.isEnabled();
print('Tracking enabled: $isTrackingEnabled');
```

### Requesting App Tracking Transparency (ATT) Permission (iOS)

For iOS 14+, request user permission for tracking:

```dart
bool isAuthorized = await WiseTrack.instance.iOSRequestForATT();
print('Tracking Authorized: $isAuthorized');
```

### Starting/Stopping Tracking

Manually control tracking:

```dart
// Start tracking
await WiseTrack.instance.startTracking();

// Stop tracking
await WiseTrack.instance.stopTracking();
```

### Uninstall Detection and Setting Push Notification Tokens

To enable WiseTrack Uninstall Detection feature, you need to configure your project to receive push notifications using **Firebase Cloud Messaging (FCM)**.
**NOTE**: For a working implementation, you can check the [example project](https://github.com/wisetrack-io/flutter-sdk/tree/main/example/lib/firebase_messaging_handler.dart)

#### 1. Configure Firebase Cloud Messaging (FCM)

Follow the official FlutterFire documentation to set up FCM in your project:
👉 [Firebase Cloud Messaging Setup Guide](https://firebase.flutter.dev/docs/messaging/overview)

Ensure that:

- Your app is registered in the Firebase Console.
- The `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) files are added correctly.
- Firebase dependencies (`firebase_core` and `firebase_messaging`) are added and initialized in your project.

#### 2. Handle Notification Tokens

Once FCM is configured, you need to get Fcm and APNS token and pass them to WiseTrack:

```dart
  static _getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      WiseTrack.instance.setFCMToken(token);
    }

    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) WiseTrack.instance.setAPNSToken(apnsToken);

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      WiseTrack.instance.setFCMToken(token);
    });
  }
```

#### 3. Handle Incoming Notifications

And finally inside your `FirebaseMessaging.onMessage` or `FirebaseMessaging.onBackgroundMessage` handlers, call the following helper method to check if the message belongs to WiseTrack:

```dart
  // For handle notification when app is in foreground:
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (await WiseTrack.instance.isWiseTrackNotification(message.data)) {
      // This notification is handled internally by WiseTrack.
      return;
    }
  // Otherwise, handle your app's custom notifications here.
  });

  // For handle notification when app is in background or terminated:
  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (await WiseTrack.instance.isWiseTrackNotification(message.data)) {
      // This notification is handled internally by WiseTrack.
      return;
    }
    // Otherwise, handle your app's custom notifications here.
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

#### 4. Enable Background Modes & Background Task Identifier for iOS App

To improve uninstall detection reliability, your app must support **Background Fetch** and **Background Processing**.
You can enable them in two ways:

- **Using Xcode Capabilities tab**:
  Go to your project target (Runner App) → **Signing & Capabilities** → **Background Modes** and enable:

  - _Background fetch_
  - _Background processing_

- **Manually via `Info.plist`**:
  Add the following keys:

  ```xml
  <key>UIBackgroundModes</key>
  <array>
    <string>fetch</string>
    <string>processing</string>
  </array>
  ```

  Add the WiseTrack task identifier to your `ios/Runner/Info.plist`

  ```xml
  <key>BGTaskSchedulerPermittedIdentifiers</key>
  <array>
      <string>io.wisetrack.sdk.bgtask</string>
  </array>
  ```

### Deep Link Handling

WiseTrack SDK provides comprehensive support for handling deep links and deferred deep links. This allows you to track user acquisition through deep links and handle navigation accordingly.

#### Enabling Deep Link Handling

Deep link handling is enabled by default. You can disable it in the configuration:

```dart
final config = WTInitialConfig(
  appToken: 'your-app-token',
  clientSecret: 'your-client-secret',
  deeplinkEnabled: false, // Disable deep link handling
);
```

#### Retrieving Deep Links

```dart
// Get the last received deep link
String? lastDeeplink = await WiseTrack.instance.getLastDeeplink();
print('Last Deep Link: ${lastDeeplink ?? "None"}');

// Get deferred deep link (for users who installed the app via a deep link)
String? deferredDeeplink = await WiseTrack.instance.getDeferredDeeplink();
print('Deferred Deep Link: ${deferredDeeplink ?? "None"}');
```

#### Listening for Deep Link Events

You can set up a listener to receive deep link events in real-time:

```dart
WiseTrack.instance.onDeeplinkReceived((String url, bool isDeferred) {
  print('Deep Link Received: $url');
  print('Is Deferred: $isDeferred');

  // Handle navigation based on the deep link
  if (url.contains('/product/')) {
    // Navigate to product page
  }
});
```

### Logging Custom Events

Log custom or revenue events:

```dart
// Log a default event
await WiseTrack.instance.logEvent(WTEvent(
  name: 'Custom Event',
  params: {
    'key-str': 'value',
    'key-num': 1.1,
    'key-bool': true,
  },
));

// Log a revenue event
await WiseTrack.instance.logEvent(WTEvent.revenue(
  name: 'Purchase',
  currency: 'USD',
  amount: 9.99,
  params: {
    'item': 'Premium Subscription',
  },
));
```

**Note:** Event parameter keys and values have a maximum limit of 50 characters.

### Setting Log Levels

Control the verbosity of SDK logs:

```dart
await WiseTrack.instance.setLogLevel(WTLogLevel.debug); // Options: none, error, warning, info, debug
```

### Retrieving Advertising IDs

Retrieve the Identifier for Advertising (IDFA) on iOS or Advertising ID (Ad ID) on Android:

```dart
// Get IDFA (iOS)
String? idfa = await WiseTrack.instance.getIdfa();
print('IDFA: ${idfa ?? "Not available"}');

// Get Ad ID (Android)
String? adId = await WiseTrack.instance.getAdId();
print('Ad ID: ${adId ?? "Not available"}');
```

**Note**: On web platform, advertising ID retrieval is not supported due to browser privacy restrictions. These methods will return `null` on web.

## Advanced Usaged

### Customizing SDK Behavior

You can customize the SDK behavior through the `WTInitialConfig` parameters:

**General Parameters:**
- `appToken`: Your unique app token (required).
- `clientSecret`: The secret key for authentication (required).
- `userEnvironment`: The environment (`.production`, `.sandbox`).
- `trackingWaitingTime`: Delay before starting tracking (in seconds).
- `startTrackerAutomatically`: Whether to start tracking automatically.
- `customDeviceId`: A custom device identifier.
- `defaultTracker`: A default tracker for event attribution.
- `logLevel`: Set the initial log level.
- `deeplinkEnabled`: Indicates whether deep link handling is enabled (default: `true`).

**Android-Specific Parameters (WTAndroidConfig):**
- `store`: The Android app store (e.g., `.googleplay`, `.cafebazaar`, `.other`, ...).
- `oaidEnabled`: Indicates whether the Open Advertising ID (OAID) is enabled.

**iOS-Specific Parameters (WTIOSConfig):**
- `store`: The iOS app store (e.g., `.appstore`, `.sibche`, `.other`, ..).
- `attWaitingInterval`: Maximum time to wait for ATT authorization (default: 30 seconds), Set to null to disable waiting.
- `requestATTAutomatically`: Whether SDK should automatically request ATT (default: `true`).

**Web-Specific Parameters:**
- `webAppVersion`: The app version for web (required for web platform).

**Example with Advanced Configuration:**

```dart
final config = WTInitialConfig(
  appToken: 'your-app-token',
  clientSecret: 'your-client-secret',

  // Web-specific (required when targeting web)
  webAppVersion: kIsWeb ? '1.0.0' : null,

  userEnvironment: WTUserEnvironment.sandbox,

  // Android-specific configuration
  androidConfig: WTAndroidConfig(
    store: WTAndroidStore.googlePlay,
    oaidEnabled: false,
  ),

  // iOS-specific configuration
  iOSConfig: WTIOSConfig(
    store: WTIOSStore.appStore,
    attWaitingInterval: 30,
    requestATTAutomatically: true,
  ),

  trackingWaitingTime: 5,
  startTrackerAutomatically: true,
  customDeviceId: 'custom-device-123',
  defaultTracker: 'default-tracker',
  deeplinkEnabled: true,
  logLevel: WTLogLevel.debug,
);

await WiseTrack.instance.init(config);
```

### WebView Integration

The **WebView Integration** feature allows you to bridge communication between JavaScript running inside a WebView and your Flutter application using the `WiseTrackWebBridge` system.

This is especially useful when embedding a web-based user interface or a hybrid web app in your Flutter application and you need to:

- Call native features from JavaScript (like `logEvent`, `initialize`, `getIDFA`, etc.)
- Receive asynchronous responses back from Flutter/Dart to your JS code

WiseTrack supports integration with the two most popular Flutter WebView packages:

- [`webview_flutter`](https://pub.dev/packages/webview_flutter)
- [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview)

#### Integration with `webview_flutter`

1. Create JSEvaluator:

```dart
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
```

2. Create and Register `WiseTrackWebBridge`:

```dart
final _controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted);

// Initialize WebBridge with flutter webview evaluator
final webBridge = WiseTrackWebBridge(
  evaluator: FlutterWebViewJSEvaluator(_controller),
);
webBridge.register();

_controller.loadRequest(...);
```

_Note_: register `WiseTrackWebBridge` before load any content in webview controller!

#### Integration with `flutter_inappwebview`

1. Create JSEvaluator:

```dart
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
```

2. Create and Register `WiseTrackWebBridge`:

```dart
InAppWebView(
  ...
  onWebViewCreated: (controller) {
    // Initialize WebBridge with inapp webview evaluator
    webBridge = WiseTrackWebBridge(
        evaluator: InAppWebViewJSEvaluator(controller));
    webBridge.register();
  },
  ....
)
```

#### Helper Files (.js files)

These JavaScript files are provided to help you build and test web pages intended for display inside the WebView. You can use them as a reference or foundation when integrating WiseTrack functionality into your in-app HTML pages.
Located in: [`assets`](./example/assets/html/)

Files include:

- `wisetrack.js`: Main interface for invoking bridge methods.
- `wt_config.js`: Contains the `WTInitConfig` constructor and configuration schema.
- `wt_event.js`: Defines the `WTEvent` structure for event logging.
- `test.html`: A standalone page to manually trigger SDK methods via a UI or console.

## Example Project

An example project demonstrating the WiseTrack Flutter Plugin integration is available at [GitHub Repository URL](https://github.com/wisetrack-io/flutter-sdk/tree/main/example). Clone the repository and follow the setup instructions to see the plugin in action.

## Breaking Changes

### Version 2.3.0

- **Configuration Structure Change**: Platform-specific parameters moved to dedicated config classes

  ```dart
  // OLD (Version 2.2.x and earlier)
  final config = WTInitialConfig(
    appToken: 'your-app-token',
    androidStore: WTAndroidStore.googlePlay,
    iOSStore: WTIOSStore.appStore,
    oaidEnabled: false,
  );

  // NEW (Version 2.3.0+)
  final config = WTInitialConfig(
    appToken: 'your-app-token',
    clientSecret: 'your-client-secret', // Now required
    androidConfig: WTAndroidConfig(
      store: WTAndroidStore.googlePlay,
      oaidEnabled: false,
    ),
    iOSConfig: WTIOSConfig(
      store: WTIOSStore.appStore,
      attWaitingInterval: 30,
      requestATTAutomatically: true,
    ),
  );
  ```

- **Required Parameter**: `clientSecret` is now a required parameter in `WTInitialConfig`

- **New iOS ATT Configuration**: iOS App Tracking Transparency behavior can now be configured via `WTIOSConfig`:
  - `attWaitingInterval`: Maximum wait time for ATT authorization (default: 30 seconds)
  - `requestATTAutomatically`: Whether SDK should automatically request ATT (default: true)

### Version 2.2.0

- **Method Rename**: `enableTestMode()` has been renamed to `clearAndStop()`

  ```dart
  // OLD (Version 2.1.x and earlier)
  await WiseTrack.instance.enableTestMode();

  // NEW (Version 2.2.0+)
  await WiseTrack.instance.clearAndStop();
  ```

- **Default Environment Change**: The default `userEnvironment` has changed from `WTUserEnvironment.sandbox` to `WTUserEnvironment.production`

  ```dart
  // Explicitly set sandbox if needed
  final config = WTInitialConfig(
    appToken: 'your-app-token',
    clientSecret: 'your-client-secret',
    userEnvironment: WTUserEnvironment.sandbox, // Explicitly set sandbox
  );
  ```

- **Web Platform Requirement**: `webAppVersion` parameter is now required when targeting web platform
  ```dart
  // Add webAppVersion for web builds
  final config = WTInitialConfig(
    appToken: 'your-app-token',
    clientSecret: 'your-client-secret',
    webAppVersion: kIsWeb ? '1.0.0' : null, // Required for web
  );
  ```

## Troubleshooting

- **SDK not initializing**: Ensure the `appToken` is correct and the network is reachable.
- **Logs not appearing**: Set the log level to `WTLogLevel.debug` and ensure a log listener is set up:
  ```dart
  WiseTrack.instance.listenOnLogs((message) => print('SDK Log: $message'));
  ```
- **IDFA/Ad ID not available**: Ensure ATT permission is granted (iOS) or Google Play Services is included (Android).
- **Web initialization fails**: Ensure `webAppVersion` is provided in `WTInitialConfig`
- **Web events not tracking**: Check browser console for JavaScript errors and enable web-specific logging

For further assistance, contact support at [support@wisetrack.io](mailto:support@wisetrack.io).

## License

The WiseTrack Flutter Plugin is licensed under the WiseTrack SDK License Agreement. See the [LICENSE](LICENSE) file for details.
