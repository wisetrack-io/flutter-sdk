# 📝 Changelog

---

## 🎯 Version 2.x

<details open>
<summary><strong>2.3.0</strong> — <em>Deep Link Handling & Platform-Specific Configurations</em></summary>

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

</details>

<details>
<summary><strong>2.2.0</strong> — <em>Web Platform Support & Major Architecture Refactor</em></summary>

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

</details>

<details>
<summary><strong>2.1.5</strong> — <em>Native SDK Updates & Event Parameter Validation</em></summary>

- 📦 **Native SDK Updates**
  - Android SDK updated to `2.2.2`
  - iOS SDK updated to `2.2.1`

- ✅ **Event Parameter Validation**
  - Added validation for event parameters to ensure data integrity
  - Improved parameter handling across Android and iOS platforms

</details>

<details>
<summary><strong>2.1.4</strong> — <em>Uninstall Detection & Firebase Integration</em></summary>

- 🚀 **New Feature: Uninstall Detection**
  - Added support for uninstall detection using **Firebase Cloud Messaging (FCM)**.

- 📦 **Native SDK Updates**
  - Android SDK updated to `2.2.1`
  - iOS SDK updated to `2.2.0`

</details>

<details>
<summary><strong>2.1.2</strong> — <em>Native SDK Updates</em></summary>

- 📦 **Native SDK Updates**
  - Android SDK updated to `2.1.1`
  - iOS SDK updated to `2.1.0`

</details>

<details>
<summary><strong>2.1.0</strong> — <em>WebBridge Integration & Native SDK Updates</em></summary>

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

</details>

<details>
<summary><strong>2.0.6</strong> — <em>Maintenance & SDK Bumps</em></summary>

- ‼️ **Breaking Changes**

  - The field `trackingWattingTime` has been renamed to `trackingWaitingTime` to correct a typo.
  - Important: Ensure that the value passed to `trackingWaitingTime` is in **seconds**. Using a different unit (e.g., milliseconds) may lead to unexpected results.

- 📦 **Dependency Management**
  - Bumped Android native sdk core to 2.0.10

</details>

<details>
<summary><strong>2.0.5</strong> — <em>Maintenance & Compatibility</em></summary>

- ✅ **Flutter/Dart SDK Updates**

  - Updated Flutter SDK constraints.
  - Updated Dart SDK to support `2.12.0`.

- 📦 **Dependency Management**
  - Bumped related package dependencies for compatibility with Java 17.

</details>

<details>
<summary><strong>2.0.4</strong> — <em>Wider Compatibility</em></summary>

- 🔧 **SDK Constraints**

  - Lowered minimum Flutter SDK constraint to `>=2.2.0`.
  - Updated Dart SDK constraint to `>=2.12.0 <4.0.0`.

- 🚫 **Future-proofing**
  - Ensured compatibility with dart 2.12.0 and flutter 2 while preventing future breaking changes.

</details>

<details>
<summary><strong>2.0.3</strong> — <em>Localization & SDK Bumps</em></summary>

- 🚀 **Native SDKs**

  - Updated Android and iOS native SDKs to the latest stable versions.

- 🌍 **Documentation**
  - Added Persian (`fa`) version of the `README.md`.

</details>

---

## 🚀 Version 1.x

<details>
<summary><strong>1.0.0</strong> — <em>Initial Release</em></summary>

- 🧱 **Foundation**

  - First stable release of the Flutter plugin.

- 📱 **Native SDK Integration**

  - Android native SDK: `2.0.5`
  - iOS native SDK: `1.0.1`

- 🛠️ **Fixes**
  - Resolved versioning and packaging inconsistencies.

</details>
