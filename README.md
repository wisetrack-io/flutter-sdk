# WiseTrack Flutter Plugin

The WiseTrack Flutter Plugin provides a cross-platform solution for tracking user interactions, events, and push notifications in your Flutter applications. This README guide covers the installation, setup, and usage of the plugin for both iOS and Android platforms, including examples for common use cases.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Initialization](#initialization)
- [Basic Usage](#basic-usage)
  - [Enabling/Disabling Tracking](#enablingdisabling-tracking)
  - [Requesting App Tracking Transparency (ATT) Permission (iOS)](#requesting-app-tracking-transparency-att-permission-ios)
  - [Starting/Stopping Tracking](#startingstopping-tracking)
  - [Setting Push Notification Tokens](#setting-push-notification-tokens)
  - [Logging Custom Events](#logging-custom-events)
  - [Setting Log Levels](#setting-log-levels)
  - [Retrieving Advertising IDs](#retrieving-advertising-ids)
- [Advanced Usage](#advanced-usage)
  - [Customizing SDK Behavior](#customizing-sdk-behavior)
- [Example Project](#example-project)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features
- Cross-platform tracking for iOS and Android
- Support for custom and revenue event logging
- Push notification token management (APNs and FCM)
- App Tracking Transparency (ATT) support for iOS
- Configurable logging levels
- Heatmap support (iOS only, via native integration)
- Advertising ID retrieval (IDFA for iOS, Ad ID for Android)

## Requirements
- Flutter 3.0.0 or later
- Dart 2.17.0 or later
- iOS 11.0 or later
- Android API 21 (Lollipop) or later

## Installation
To integrate the WiseTrack Flutter Plugin into your Flutter project, follow these steps:

1. **Add the dependency**:
   Add the `wisetrack` plugin to your `pubspec.yaml` file:
   ```yaml
   dependencies:
     wisetrack: ^1.0.0 # Replace with the latest version
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
     implementation 'io.wisetrack:sdk:oaid:2.0.0' # Replace with the latest version
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
     implementation 'io.wisetrack:sdk:referrer:2.0.0' # Replace with the latest version
     implementation 'com.android.installreferrer:installreferrer:2.2' # Google Play referrer
     implementation 'com.github.cafebazaar:referrersdk:1.0.2' # CafeBazaar referrer
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
               classpath 'com.google.gms:google-services:4.4.1' # Or latest version
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

5. **Rebuild the project**:
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
    userEnvironment: WTUserEnvironment.production, // Use .sandbox for testing
    androidStore: WTAndroidStore.googlePlay,
    iOSStore: WTIOSStore.appStore,
    trackingWattingTime: 5000, // 5 seconds
    startTrackerAutomatically: true,
    logLevel: WTLogLevel.debug,
    oaidEnabled: false,
    referrerEnabled: true,
  );

  await WiseTrack.instance.init(config);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('WiseTrack Demo')),
        body: Center(child: Text('Welcome to WiseTrack!')),
      ),
    );
  }
}
```

**Note**: Replace `'your-app-token'` with the token provided by the WiseTrack dashboard.

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

### Setting Push Notification Tokens
Set APNs or FCM tokens for push notifications:

```dart
// Set APNs token (iOS)
await WiseTrack.instance.setAPNSToken('your-apns-token');

// Set FCM token (Android)
await WiseTrack.instance.setFCMToken('your-fcm-token');
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

## Advanced Usage

### Customizing SDK Behavior
You can customize the SDK behavior through the `WTInitialConfig` parameters:
- `appToken`: Your unique app token (required).
- `userEnvironment`: The environment (`.production`, `.sandbox`, `.stage`).
- `androidStore`: The Android app store (e.g., `.googleplay`, `.cafebazaar`, `.other`, ...).
- `iOSStore`: The iOS app store (e.g., `.appstore`, `.sibche`, `.other`, ..).
- `trackingWattingTime`: Delay before starting tracking (in milliseconds).
- `startTrackerAutomatically`: Whether to start tracking automatically.
- `customDeviceId`: A custom device identifier.
- `defaultTracker`: A default tracker for event attribution.
- `appSecret`: A secret key for authentication.
- `secretId`: A unique secret identifier.
- `attributionDeeplink`: Enable deep link attribution.
- `eventBuffering`: Enable event buffering for optimized data transmission.
- `logLevel`: Set the initial log level.
- `oaidEnabled`: Indicates whether the Open Advertising ID (OAID) is enabled.
- `referrerEnabled`: Indicates whether the Referrer ID is enabled.

Example with advanced configuration:
```dart
final config = WTInitialConfig(
  appToken: 'your-app-token',
  userEnvironment: WTUserEnvironment.sandbox,
  androidStore: WTAndroidStore.googlePlay,
  iOSStore: WTIOSStore.appStore,
  trackingWattingTime: 5000,
  startTrackerAutomatically: true,
  customDeviceId: 'custom-device-123',
  defaultTracker: 'default-tracker',
  appSecret: 'your-app-secret',
  secretId: 'your-secret-id',
  attributionDeeplink: true,
  eventBuffering: true,
  logLevel: WTLogLevel.debug,
  oaidEnabled: false,
  referrerEnabled: true,
);

await WiseTrack.instance.init(config);
```

## Example Project
An example project demonstrating the WiseTrack Flutter Plugin integration is available at [GitHub Repository URL](https://github.com/wisetrack-io/flutter-sdk/tree/main/example). Clone the repository and follow the setup instructions to see the plugin in action.

## Troubleshooting
- **SDK not initializing**: Ensure the `appToken` is correct and the network is reachable.
- **Tracking not working**: Verify that `setEnabled(true)` is called and ATT permission is granted (iOS).
- **Logs not appearing**: Set the log level to `WTLogLevel.debug` and ensure a log listener is set up:
  ```dart
  WiseTrack.instance.listenOnLogs((message) => print('SDK Log: $message'));
  ```
- **IDFA/Ad ID not available**: Ensure ATT permission is granted (iOS) or Google Play Services is included (Android).
- **Push notifications not tracked**: Verify that valid APNs/FCM tokens are set.

For further assistance, contact support at [support@wisetrack.com](mailto:support@wisetrack.com).

## License
The WiseTrack Flutter Plugin is licensed under the WiseTrack SDK License Agreement. See the [LICENSE](LICENSE) file for details.