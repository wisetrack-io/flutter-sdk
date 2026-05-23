# 📝 Changelog

---

## 🎯 Version 2.x

**2.4.1** — _Screen Tracking Webview Bridge_

- 🌎 **Major Feature: Screen Tracking WebBridge Integration**
  - Added `trackScreen` for webview bridge.

**2.4.0** — _Screen Tracking Feature_

- 📱 **Major Feature: Screen Tracking**
  - Added `trackScreen(WTScreen screen)` for manual screen view tracking
  - Introduced `WTNavigatorObserver`, a `NavigatorObserver` that automatically tracks screen views without per-screen setup
    - Compatible with all routing packages: `go_router`, `GetX`, `auto_route`, `Beamer`, and plain Navigator 1.0/2.0
    - Added advanced screen name resolution with customizable `screenDataProvider`
    - Automatically extracts screen route parameters
  - Introduced `WTScreenTrackMixin` for fine-grained widget-level tracking via `RouteAware`
  - Added `WTScreen` model with `name`, `displayName`, `type`, and `params`
  - Added `WTScreenType` enum: `page`, `dialog`, `bottomSheet`, `other`
  - Added `WTScreenTrackingConfig` for configuring auto-tracking behavior
  - Added `WTScreenDataProvider` model used by `screenDataProvider`

**2.3.1** — _Native SDK Updates_

- 📦 **Native SDK Updates**
  - Android SDK updated to `2.3.1`
  - iOS SDK updated to `2.3.1`

**2.3.0** — _Deep Link Handling & Platform-Specific Configurations_

- 🔗 **Major Feature: Deep Link Handling**
  - Added `getLastDeeplink()` to retrieve the last received deep link
  - Added `getDeferredDeeplink()` to retrieve deferred deep links
  - Added `onDeeplinkReceived(callback)` listener for real-time deep link events
  - New `deeplinkEnabled` configuration option to enable/disable deep link handling
- ⚙️ **Platform-Specific Configuration Classes**
  - Introduced `WTAndroidConfig` for Android-specific settings:
    - `store` - Android app store selection
    - `oaidEnabled` - Open Advertising ID support
  - Introduced `WTIOSConfig` for iOS-specific settings:
    - `store` - iOS app store selection
    - `attWaitingInterval` - Maximum wait time for ATT authorization (default: 30 seconds)
    - `requestATTAutomatically` - Automatic ATT request (default: true)
- 🔐 **Authentication Update**
  - Added `clientSecret` as a required parameter in `WTInitialConfig`
- 🔧 **Plugin Improvements**
  - Refined and refactored Android, iOS, and Web plugins to latest versions
  - Improved web module compatibility with older Flutter versions
- ‼️ **Breaking Changes**
  - **Configuration Structure**: `androidStore`, `iOSStore`, and `oaidEnabled` moved to platform-specific config classes
    - Migration: Use `androidConfig: WTAndroidConfig(store: ..., oaidEnabled: ...)` instead of direct parameters
    - Migration: Use `iOSConfig: WTIOSConfig(store: ..., attWaitingInterval: ..., requestATTAutomatically: ...)` instead of direct parameters
  - **Required Parameter**: `clientSecret` is now required in `WTInitialConfig`

**2.2.0** — _Web Platform Support & Major Architecture Refactor_

- 🌐 **Major Feature: Web Platform Support**
  - Complete web platform implementation added with full SDK functionality
  - New web-specific configuration with `webAppVersion` parameter (required for web)
- 📦 **Dependency Updates**
  - Android SDK updated to `2.2.5`
- ‼️ **Breaking Changes**
  - **Method Rename**: `enableTestMode()` → `clearAndStop()`
    - Migration: Replace all calls to `enableTestMode()` with `clearAndStop()`
  - **Default Environment**: Changed from `WTUserEnvironment.sandbox` to `WTUserEnvironment.production`
    - Migration: Explicitly set `userEnvironment: WTUserEnvironment.sandbox` if needed
  - **Web Requirement**: `webAppVersion` parameter is now required when using web platform
    - Migration: Add `webAppVersion: "your_version"` to `WTInitialConfig` for web apps

**2.1.5** — _Native SDK Updates & Event Parameter Validation_

- 📦 **Native SDK Updates**
  - Android SDK updated to `2.2.2`
  - iOS SDK updated to `2.2.1`
- ✅ **Event Parameter Validation**
  - Added validation for event parameters to ensure data integrity
  - Improved parameter handling across Android and iOS platforms

**2.1.4** — _Uninstall Detection & Firebase Integration_

- 🚀 **New Feature: Uninstall Detection**
  - Added support for uninstall detection using **Firebase Cloud Messaging (FCM)**.
- 📦 **Native SDK Updates**
  - Android SDK updated to `2.2.1`
  - iOS SDK updated to `2.2.0`

**2.1.2** — _Native SDK Updates_

- 📦 **Native SDK Updates**
  - Android SDK updated to `2.1.1`
  - iOS SDK updated to `2.1.0`

**2.1.0** — _WebBridge Integration & Native SDK Updates_

- 🌐 **Major Feature: WebBridge Integration**
  - Introduced a new **WebBridge** layer to enable JavaScript-to-native communication via WebView.
  - This feature allows web pages opened inside your app (via WebView) to call native methods.
  - ✅ Supported WebView packages:
    - `webview_flutter`
    - `flutter_inappwebview`
- 🔄 **Other Enhancements**
  - Added support for retrieving the **Install Referrer** on `Android` using `getReferrer()`.
  - Improved internal method argument normalization across platforms for consistent native bridge handling.
- 📦 **Native SDK Updates**
  - Android SDK updated to `2.0.10`
  - iOS SDK updated to `1.0.5`

**2.0.6** — _Maintenance & SDK Bumps_

- ‼️ **Breaking Changes**
  - The field `trackingWattingTime` has been renamed to `trackingWaitingTime` to correct a typo.
  - Important: Ensure that the value passed to `trackingWaitingTime` is in **seconds**. Using a different unit (e.g., milliseconds) may lead to unexpected results.
- 📦 **Dependency Management**
  - Bumped Android native sdk core to 2.0.10

**2.0.5** — _Maintenance & Compatibility_

- ✅ **Flutter/Dart SDK Updates**
  - Updated Flutter SDK constraints.
  - Updated Dart SDK to support `2.12.0`.
- 📦 **Dependency Management**
  - Bumped related package dependencies for compatibility with Java 17.

**2.0.4** — _Wider Compatibility_

- 🔧 **SDK Constraints**
  - Lowered minimum Flutter SDK constraint to `>=2.2.0`.
  - Updated Dart SDK constraint to `>=2.12.0 <4.0.0`.
- 🚫 **Future-proofing**
  - Ensured compatibility with dart 2.12.0 and flutter 2 while preventing future breaking changes.

**2.0.3** — _Localization & SDK Bumps_

- 🚀 **Native SDKs**
  - Updated Android and iOS native SDKs to the latest stable versions.
- 🌍 **Documentation**
  - Added Persian (`fa`) version of the `README.md`.

---

## 🚀 Version 1.x

**1.0.0** — _Initial Release_

- 🧱 **Foundation**
  - First stable release of the Flutter plugin.
- 📱 **Native SDK Integration**
  - Android native SDK: `2.0.5`
  - iOS native SDK: `1.0.1`
- 🛠️ **Fixes**
  - Resolved versioning and packaging inconsistencies.
