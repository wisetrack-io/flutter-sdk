☀︎ زبان ها: فارسی | [English (انگلیسی) 🇺🇸](https://github.com/wisetrack-io/flutter-sdk/blob/main/README.md)

# پلاگین فلاتر WiseTrack

پلاگین افزونه فلاتر **WiseTrack** یک راهکار چندسکویی برای شتاب‌دهی به رشد اپلیکیشن شما ارائه می‌دهد — ابزاری که به شما کمک می‌کند همزمان تعداد کاربران را افزایش دهید، درآمد را بیشتر کنید و هزینه‌ها را کاهش دهید.

## فهرست مطالب

- [ویژگی ها](#ویژگی-ها)
- [نیازمندی ها](#نیازمندی-ها)
- [نصب](#نصب)
- [راه اندازی اولیه](#راه-اندازی-اولیه)
- [استفاده پایه](#استفاده-پایه)
  - [فعال/غیرفعال کردن ردیابی](#فعالغیرفعال-کردن-ردیابی)
  - [درخواست مجوز شفافیت ردیابی برنامه (ATT) (iOS)](#درخواست-مجوز-شفافیت-ردیابی-برنامه-att-ios)
  - [شروع/توقف ردیابی](#شروعتوقف-ردیابی)
  - [تشخیص حذف نصب و تنظیم توکن‌ های اعلان پوش](#تشخیص-حذف-نصب-و-تنظیم-توکن‌-های-اعلان-پوش)
  - [تنظیم توکن‌ های اعلان پوش](#تنظیم-توکن-های-اعلان-پوش)
  - [ثبت رویدادهای سفارشی](#ثبت-رویدادهای-سفارشی)
  - [تنظیم سطوح لاگ](#تنظیم-سطوح-لاگ)
  - [بازیابی شناسه های تبلیغاتی](#بازیابی-شناسه-های-تبلیغاتی)
- [استفاده پیشرفته](#استفاده-پیشرفته)
  - [سفارشی سازی رفتار SDK](#سفارشی-سازی-رفتار-sdk)
  - [اتصال به WebView](#اتصال-به-webview)
- [پروژه نمونه](#پروژه-نمونه)
- [تغییرات مهم](#تغییرات-مهم)
- [عیب یابی](#عیب-یابی)
- [مجوز](#مجوز)

## ویژگی‌ ها

- ردیابی چندپلتفرمی برای iOS، اندروید و وب
- پشتیبانی از ثبت رویدادهای سفارشی و درآمدی
- مدیریت توکن اعلان پوش (APNS و FCM)
- پشتیبانی از شفافیت ردیابی برنامه (ATT) برای iOS
- سطوح لاگ قابل تنظیم
- بازیابی شناسه تبلیغاتی (IDFA برای iOS، Ad ID برای اندروید)
- پشتیبانی از پلتفرم وب با ادغام JavaScript interop
- API یکپارچه در همه پلتفرم‌ها (موبایل و وب)

## نیازمندی ها

- فلاتر 2.0.0 یا بالاتر
- دارت 2.12.0 یا بالاتر
- iOS 11.0 یا بالاتر
- پشتیبانی از Android embedding v2
- اندروید API 21 (لالی‌پاپ) یا بالاتر
- Android Gradle Plugin >= 7.1.0 برای سازگاری کامل با جاوا 17

## نصب

برای ادغام پلاگین فلاتر WiseTrack در پروژه فلاتر خود، مراحل زیر را دنبال کنید:

1. **افزودن وابستگی**:
   پلاگین `wisetrack` را به فایل `pubspec.yaml` خود اضافه کنید:

   ```yaml
   dependencies:
     wisetrack: ^2.2.0 # با آخرین نسخه جایگزین کنید
   ```

2. **نصب بسته**:
   دستور زیر را در دایرکتوری پروژه خود اجرا کنید:

   ```bash
   flutter pub get
   ```

3. **فعال‌سازی پشتیبانی وب** (اگر وب را هدف قرار می‌دهید):
   پشتیبانی وب به صورت خودکار گنجانده شده است. برای ویژگی‌های خاص وب، اطمینان حاصل کنید که فایل `web/index.html` شما شامل بسته SDK WiseTrack است:

   ```html
   <script src="sdk.bundle.min.js"></script>
   ```

4. **پیکربندی iOS**:
   برای پشتیبانی از شفافیت ردیابی برنامه (ATT) در iOS، کلید زیر را به فایل `ios/Runner/Info.plist` اضافه کنید:

   ```xml
   <key>NSUserTrackingUsageDescription</key>
   <string>ما از این داده‌ها برای ارائه تجربه کاربری بهتر و تبلیغات شخصی‌سازی‌شده استفاده می‌کنیم.</string>
   ```

5. **پیکربندی اندروید**:
   اطمینان حاصل کنید که فایل `android/app/build.gradle` شما تنظیمات زیر را دارد:

   ```gradle
   android {
       compileSdkVersion 33
       defaultConfig {
           minSdkVersion 21
           targetSdkVersion 33
       }
   }
   ```

   **مجوزهای اندروید**:
   برای فعال کردن SDK WiseTrack جهت دسترسی به اطلاعات دستگاه و ویژگی‌های شبکه در اندروید، مجوزهای زیر را به فایل `android/app/src/main/AndroidManifest.xml` اضافه کنید:

   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

   اگر برنامه شما فروشگاه Google Play را هدف قرار نمی‌دهد (مانند کافه‌بازار یا مایکت)، مجوزهای زیر را نیز اضافه کنید:

   ```xml
   <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
   <uses-permission android:name="android.permission.READ_PHONE_STATE" />
   ```

   **وابستگی‌های خاص ویژگی‌ها (اندروید)**:
   SDK WiseTrack از ویژگی‌های اضافی اندروید پشتیبانی می‌کند که نیازمند وابستگی‌های خاصی هستند. فقط وابستگی‌های مربوط به ویژگی‌هایی که نیاز دارید را در فایل `android/app/build.gradle` اضافه کنید:

   - **شناسه تبلیغاتی گوگل (Ad ID)**: امکان بازیابی شناسه تبلیغاتی گوگل را از طریق `getAdId()` فراهم می‌کند.

     ```gradle
     implementation 'com.google.android.gms:play-services-ads-identifier:18.2.0'
     ```

   - **شناسه تبلیغاتی باز (OAID)**: امکان استفاده از OAID به‌عنوان جایگزینی برای Ad ID در دستگاه‌های بدون Google Play Services (مانند دستگاه‌های چینی) از طریق `WTInitialConfig` با `oaidEnabled: true`.

     ```gradle
     implementation 'io.wisetrack.sdk:oaid:2.0.0' // با آخرین نسخه جایگزین کنید
     ```

   - **شناسه تبلیغات هواوی**: امکان بازیابی Ad ID در دستگاه‌های هواوی را فراهم می‌کند.
     افزودن مخزن:

     ```gradle
     maven { url 'https://developer.huawei.com/repo/' }
     ```

     و این وابستگی:

     ```gradle
     implementation 'com.huawei.hms:ads-identifier:3.4.62.300'
     ```

   - **ردیابی ارجاع (Referrer Tracking)**: امکان ردیابی ارجاع برای Google Play و کافه‌بازار از طریق `WTInitialConfig` با `referrerEnabled: true`.

     ```gradle
     implementation 'io.wisetrack.sdk:referrer:2.0.0' // با آخرین نسخه جایگزین کنید
     implementation 'com.android.installreferrer:installreferrer:2.2' // ارجاع Google Play
     implementation 'com.github.cafebazaar:referrersdk:1.0.2' // ارجاع کافه‌بازار
     ```

   - **شناسه نصب فایربیس (FID)**: امکان بازیابی شناسه نصب فایربیس برای شناسایی دستگاه را فراهم می‌کند.

     ```gradle
     implementation 'com.google.firebase:firebase-installations:17.2.0'
     ```

     برای استفاده از سرویس‌های فایربیس، برنامه خود را در کنسول فایربیس ثبت کنید:

     - نام بسته خود را اضافه کنید (مانند `com.example.app`).
     - فایل `google-services.json` را دانلود کرده و در `android/app/` قرار دهید.
     - فایل `android/build.gradle` را به‌روزرسانی کنید:
       ```gradle
       buildscript {
           dependencies {
               classpath 'com.google.gms:google-services:4.4.1' // یا آخرین نسخه
           }
       }
       ```
     - پلاگین Google Services را در `android/app/build.gradle` اعمال کنید:
       ```gradle
       apply plugin: 'com.google.gms.google-services'
       ```

   - **AppSet ID**: شناسایی اضافی دستگاه برای تحلیل‌ها را فراهم می‌کند.
     ```gradle
     implementation 'com.google.android.gms:play-services-appset:16.1.0'
     ```

6. **بازسازی پروژه**:
   پروژه خود را اجرا کنید تا مطمئن شوید همه وابستگی‌ها به درستی ادغام شده‌اند:
   ```bash
   flutter run
   ```

## راه اندازی اولیه

برای شروع استفاده از پلاگین فلاتر WiseTrack، آن را با یک شیء پیکربندی در نقطه ورودی برنامه خود (مانند `main.dart`) راه‌اندازی کنید.

### مثال

```dart
import 'package:flutter/material.dart';
import 'package:wisetrack/wisetrack.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // راه‌اندازی WiseTrack
  final config = WTInitialConfig(
    appToken: 'your-app-token',
    webAppVersion: kIsWeb ? '1.0.0' : null, // برای پلتفرم وب الزامی است
    userEnvironment: WTUserEnvironment.production, // برای تست از .sandbox استفاده کنید
    androidStore: WTAndroidStore.playstore,
    iOSStore: WTIOSStore.appstore,
    logLevel: WTLogLevel.warning,
  );

  await WiseTrack.instance.init(config);

  runApp(MyApp());
}
```

**توجه**: `'your-app-token'` را با توکن ارائه‌شده توسط داشبورد WiseTrack جایگزین کنید.

## استفاده پایه

در ادامه، وظایف رایجی که می‌توانید با پلاگین فلاتر WiseTrack انجام دهید آورده شده است.

### فعال/غیرفعال کردن ردیابی

ردیابی را در زمان اجرا فعال یا غیرفعال کنید:

```dart
await WiseTrack.instance.setEnabled(true); // فعال کردن sdk

await WiseTrack.instance.setEnabled(false); // غیرفعال کردن sdk

bool isTrackingEnabled = await WiseTrack.instance.isEnabled(); // بررسی فعال بودن sdk
print('sdk فعال است: $isTrackingEnabled');
```

### درخواست مجوز شفافیت ردیابی برنامه (ATT) (iOS)

برای iOS 14+، از کاربر برای ردیابی مجوز بخواهید:

```dart
bool isAuthorized = await WiseTrack.instance.iOSRequestForATT();
print('ردیابی مجاز است: $isAuthorized');
```

### شروع/توقف ردیابی

ردیابی را به صورت دستی کنترل کنید:

```dart
  await WiseTrack.instance.startTracking(); // شروع ردیابی
  await WiseTrack.instance.stopTracking(); // توقف ردیابی
```

### تشخیص حذف نصب و تنظیم توکن‌ های اعلان پوش

برای فعال‌سازی قابلیت تشخیص حذف اپلیکیشن (Uninstall Detection) در WiseTrack، باید پروژه‌ی خود را برای دریافت پوش نوتیفیکیشن‌ها با استفاده از **Firebase Cloud Messaging (FCM)** پیکربندی کنید.
**نکته:** برای مشاهده‌ی یک پیاده‌سازی عملی، می‌توانید به [پروژه‌ی نمونه](https://github.com/wisetrack-io/flutter-sdk/tree/main/example/lib/firebase_messaging_handler.dart) مراجعه کنید.

#### 1. پیکربندی Firebase Cloud Messaging (FCM)

طبق مستندات رسمی FlutterFire، FCM را در پروژه‌ی خود راه‌اندازی کنید:
👉 [راهنمای راه‌اندازی Firebase Cloud Messaging](https://firebase.flutter.dev/docs/messaging/overview)

اطمینان حاصل کنید که:

- اپلیکیشن شما در **Firebase Console** ثبت شده باشد.
- فایل‌های `google-services.json` (برای Android) یا `GoogleService-Info.plist` (برای iOS) به درستی اضافه شده باشند.
- وابستگی‌های لازم (`firebase_core` و `firebase_messaging`) به پروژه اضافه و مقداردهی اولیه شده باشند.

#### 2. مدیریت توکن‌های نوتیفیکیشن

بعد از پیکربندی FCM، باید توکن‌های **FCM** و **APNS** را دریافت کرده و به WiseTrack ارسال کنید:

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

#### 3. مدیریت نوتیفیکیشن‌های دریافتی

در نهایت، داخل متدهای `FirebaseMessaging.onMessage` یا `FirebaseMessaging.onBackgroundMessage` باید از متد کمکی زیر استفاده کنید تا بررسی شود پیام مربوط به WiseTrack است یا خیر:

```dart
  // برای مدیریت نوتیفیکیشن وقتی اپ در حالت foreground است:
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (await WiseTrack.instance.isWiseTrackNotification(message.data)) {
      // این نوتیفیکیشن به صورت داخلی توسط WiseTrack مدیریت می‌شود.
      return;
    }
    // در غیر این صورت نوتیفیکیشن‌های اختصاصی اپلیکیشن خودتان را مدیریت کنید.
  });

  // برای مدیریت نوتیفیکیشن وقتی اپ در حالت background یا بسته (terminated) است:
  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (await WiseTrack.instance.isWiseTrackNotification(message.data)) {
      // این نوتیفیکیشن به صورت داخلی توسط WiseTrack مدیریت می‌شود.
      return;
    }
    // در غیر این صورت نوتیفیکیشن‌های اختصاصی اپلیکیشن خودتان را مدیریت کنید.
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

#### 4. فعال‌سازی Background Modes و Background Task Identifier برای اپ iOS

برای افزایش دقت و قابلیت اطمینان در تشخیص uninstall، اپلیکیشن شما باید از **Background Fetch** و **Background Processing** پشتیبانی کند.
می‌توانید این قابلیت‌ها را به دو روش فعال کنید:

- **استفاده از تب Capabilities در Xcode**:
  به **Target** پروژه خود (مثلاً Runner App) بروید → **Signing & Capabilities** → **Background Modes** و گزینه‌های زیر را فعال کنید:

  - _Background fetch_
  - _Background processing_

- **به صورت دستی از طریق `Info.plist`:**:
  کلیدهای زیر را به `Info.plist` اضافه کنید::

  ```xml
  <key>UIBackgroundModes</key>
  <array>
    <string>fetch</string>
    <string>processing</string>
  </array>
  ```

  همچنین شناسه تسک WiseTrack را به `ios/Runner/Info.plist` اضافه کنید:

  ```xml
  <key>BGTaskSchedulerPermittedIdentifiers</key>
  <array>
      <string>io.wisetrack.sdk.bgtask</string>
  </array>
  ```

### ثبت رویدادهای سفارشی

رویدادهای سفارشی یا درآمدی را ثبت کنید:

```dart
// default event => تنظیم توکن FCM (اندروید)
await WiseTrack.instance.logEvent(WTEvent(
  name: 'رویداد پیشفرض',
  params: {
    'key-str': 'مقدار',
    'key-num': 1.1,
    'key-bool': true,
  },
));

// revenue event =>  ثبت یک رویداد درآمدی
await WiseTrack.instance.logEvent(WTEvent.revenue(
  name: 'خرید',
  currency: 'USD',
  amount: 9.99,
  params: {
    'item': 'اشتراک پرمیوم',
  },
));
```

**نکته:** کلید ها و مقادیر در پارامتر های رویداد ها میتوانند حداکثر ۵۰ کاراکتر طول داشته باشند

### تنظیم سطوح لاگ

میزان جزئیات لاگ‌های SDK را کنترل کنید:

```dart
await WiseTrack.instance.setLogLevel(WTLogLevel.warning); // گزینه‌ها: error، warning، info، debug
```

### بازیابی شناسه های تبلیغاتی

شناسه تبلیغاتی (IDFA) در iOS یا شناسه تبلیغاتی (Ad ID) در اندروید را بازیابی کنید:

```dart
String? idfa = await WiseTrack.instance.getIdfa(); // دریافت IDFA (iOS)
print('IDFA: ${idfa ?? "در دسترس نیست"}');

String? adId = await WiseTrack.instance.getAdId(); // دریافت Ad ID (اندروید)
print('Ad ID: ${adId ?? "در دسترس نیست"}');
```

**نکته**: در پلتفرم وب، بازیابی شناسه تبلیغاتی به دلیل محدودیت‌های حریم خصوصی مرورگر پشتیبانی نمی‌شود. این متدها در وب `null` برمی‌گردانند.

## استفاده پیشرفته

### سفارشی سازی رفتار SDK

شما می‌توانید رفتار SDK را از طریق پارامترهای `WTInitialConfig` سفارشی کنید:

**پارامترهای عمومی:**

- `appToken`: توکن یکتای برنامه شما (الزامی).
- `userEnvironment`: محیط (`.production`, `.sandbox`).
- `trackingWaitingTime`: تاخیر قبل از شروع ردیابی (به ثانیه).
- `startTrackerAutomatically`: آیا ردیابی به صورت خودکار شروع شود.
- `customDeviceId`: یک شناسه دستگاه سفارشی.
- `defaultTracker`: یک ردیاب پیش‌فرض برای تخصیص رویداد.
- `logLevel`: تنظیم سطح لاگ اولیه.
- `attributionDeeplink`: نشان‌دهنده فعال بودن attribution از طریق deep links.
- `eventBuffering`: فعال‌سازی buffering رویدادها برای بهینه‌سازی انتقال داده.
- `appSecret`: کلید مخفی استفاده شده برای احراز هویت یا رمزگذاری.
- `secretId`: شناسه مخفی یکتا مرتبط با اعتبارنامه‌های برنامه.

**پارامترهای خاص موبایل:**

- `androidStore`: فروشگاه برنامه اندروید (مانند `.googleplay`, `.cafebazaar`, `.other`, ...).
- `iOSStore`: فروشگاه برنامه iOS (مانند `.appstore`, `.sibche`, `.other`, ..).
- `oaidEnabled`: نشان‌دهنده فعال بودن شناسه تبلیغاتی باز (OAID).
- `referrerEnabled`: نشان‌دهنده فعال بودن شناسه ارجاع.

**پارامترهای خاص وب:**

- `webAppVersion`: نسخه برنامه برای وب (برای پلتفرم وب الزامی است).

**مثال با پیکربندی پیشرفته:**

```dart
final config = WTInitialConfig(
  appToken: 'your-app-token',

  // خاص وب (هنگام هدف قرار دادن وب الزامی است)
  webAppVersion: kIsWeb ? '1.0.0' : null,

  userEnvironment: WTUserEnvironment.sandbox,
  androidStore: WTAndroidStore.googlePlay,
  iOSStore: WTIOSStore.appStore,
  trackingWaitingTime: 3,
  startTrackerAutomatically: true,
  customDeviceId: 'custom-device-123',
  defaultTracker: 'default-tracker',
  logLevel: WTLogLevel.debug,
  oaidEnabled: false,
  referrerEnabled: true,
);

await WiseTrack.instance.init(config);
```

### اتصال به WebView

قابلیت **اتصال به WebView** این امکان را فراهم می‌کند تا بین JavaScript درون یک WebView و اپلیکیشن Flutter شما، ارتباط مستقیم برقرار شود. این ارتباط از طریق سیستم `WiseTrackWebBridge` انجام می‌شود.
این ویژگی به‌خصوص زمانی کاربردی است که:

- رابط کاربری تحت وب یا اپ هیبریدی را درون اپلیکیشن Flutter خود نمایش می‌دهید
- نیاز دارید از داخل JavaScript به متدهای بومی (native) مثل `logEvent`، `initialize`، `getIDFA` و ... دسترسی داشته باشید
- بخواهید پاسخ‌های ناهم‌زمان (asynchronous) را از Flutter/Dart به سمت JavaScript دریافت کنید

پکیج WiseTrack از دو پکیج WebView محبوب Flutter پشتیبانی می‌کند:

- [`webview_flutter`](https://pub.dev/packages/webview_flutter)
- [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview)

#### پیاده سازی با `webview_flutter`

1. ایجاد JSEvaluator:

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

2. ساخت و ثبت `WiseTrackWebBridge`:

```dart
final _controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted);

// راه‌اندازی WebBridge با evaluator مخصوص webview_flutter
final webBridge = WiseTrackWebBridge(
  evaluator: FlutterWebViewJSEvaluator(_controller),
);
webBridge.register();

_controller.loadRequest(...);
```

_نکته:_

حتماً قبل از بارگذاری هر محتوایی در WebView، متد register() را برای `WiseTrackWebBridge` فراخوانی کنید.

#### پیاده سازی با `flutter_inappwebview`

1. ایجاد JSEvaluator:

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

2. ساخت و ثبت `WiseTrackWebBridge`:

```dart
InAppWebView(
  ...
  onWebViewCreated: (controller) {
    // راه‌اندازی WebBridge با evaluator مخصوص inappwebview
    webBridge = WiseTrackWebBridge(
        evaluator: InAppWebViewJSEvaluator(controller));
    webBridge.register();
  },
  ....
)
```

#### فایل‌های کمکی (JavaScript)

چند فایل JavaScript به‌صورت آماده در اختیار شما قرار گرفته‌اند تا بتوانید صفحات HTML مورد استفاده در WebView را راحت‌تر بسازید و تست کنید. این فایل‌ها می‌توانند به‌عنوان مرجع یا پایه‌ی پیاده‌سازی صفحات درون‌برنامه‌ای مورد استفاده قرار بگیرند.

محل قرارگیری: [`assets`](./example/assets/html/)

- `wisetrack.js`: رابط اصلی برای فراخوانی متدهای پل ارتباطی (Bridge)
- `wt_config.js`: شامل ساختار `WTInitConfig` برای پیکربندی اولیه
- `wt_event.js`: تعریف ساختار `WTEvent` برای ثبت رویدادها
- `test.html`: صفحه‌ی آزمایشی برای تست دستی متدهای SDK (با رابط کاربری یا کنسول مرورگر)

## پروژه نمونه

یک پروژه نمونه که ادغام پلاگین فلاتر WiseTrack را نشان می‌دهد، در [مخزن گیت‌هاب](https://github.com/wisetrack-io/flutter-sdk/tree/main/example) در دسترس است. مخزن را کلون کرده و دستورالعمل‌های راه‌اندازی را دنبال کنید تا پلاگین را در عمل ببینید.

## تغییرات مهم

### نسخه 2.2.0

- **تغییر نام متد**: `enableTestMode()` به `clearAndStop()` تغییر نام یافته است

  ```dart
  // قدیمی (نسخه 2.1.x و قبل از آن)
  await WiseTrack.instance.enableTestMode();

  // جدید (نسخه 2.2.0+)
  await WiseTrack.instance.clearAndStop();
  ```

- **تغییر محیط پیش‌فرض**: محیط پیش‌فرض `userEnvironment` از `WTUserEnvironment.sandbox` به `WTUserEnvironment.production` تغییر یافته است

  ```dart
  // اگر به sandbox نیاز دارید، صراحتاً تنظیم کنید
  final config = WTInitialConfig(
    appToken: 'your-app-token',
    userEnvironment: WTUserEnvironment.sandbox, // صراحتاً sandbox را تنظیم کنید
  );
  ```

- **نیاز پلتفرم وب**: پارامتر `webAppVersion` اکنون هنگام هدف قرار دادن پلتفرم وب الزامی است
  ```dart
  // webAppVersion را برای build های وب اضافه کنید
  final config = WTInitialConfig(
    appToken: 'your-app-token',
    webAppVersion: kIsWeb ? '1.0.0' : null, // برای وب الزامی است
  );
  ```

## عیب یابی

- **SDK راه‌اندازی نمی‌شود**: اطمینان حاصل کنید که `appToken` صحیح است و شبکه در دسترس است.
- **ردیابی کار نمی‌کند**: بررسی کنید که `setEnabled(true)` فراخوانی شده و مجوز ATT اعطا شده است (iOS).
- **لاگ‌ها نمایش داده نمی‌شوند**: سطح لاگ را به `WTLogLevel.debug` تنظیم کنید و مطمئن شوید که یک شنونده لاگ تنظیم شده است:
  ```dart
  WiseTrack.instance.listenOnLogs((message) => print('لاگ SDK: $message'));
  ```
- **IDFA/Ad ID در دسترس نیست**: اطمینان حاصل کنید که مجوز ATT اعطا شده است (iOS) یا Google Play Services گنجانده شده است (اندروید).
- **راه‌اندازی وب ناموفق است**: اطمینان حاصل کنید که `webAppVersion` در `WTInitialConfig` ارائه شده است
- **رویدادهای وب ردیابی نمی‌شوند**: کنسول مرورگر را برای خطاهای JavaScript بررسی کنید و لاگ‌گیری خاص وب را فعال کنید
- **اعلان‌های پوش ردیابی نمی‌شوند**: بررسی کنید که توکن‌های APNS/FCM معتبر تنظیم شده‌اند.

برای کمک بیشتر، با پشتیبانی در [support@wisetrack.io](mailto:support@wisetrack.io) تماس بگیرید.

## مجوز

پلاگین فلاتر WiseTrack تحت توافق‌نامه مجوز SDK WiseTrack منتشر شده است. برای جزئیات، فایل [LICENSE](LICENSE) را ببینید.
