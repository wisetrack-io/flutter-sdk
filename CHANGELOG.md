# 📝 Changelog

---

## 🎯 Version 2.x

<details open>
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
