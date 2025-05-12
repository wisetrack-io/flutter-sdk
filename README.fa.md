☀︎ زبان ها: فارسی | [English (انگلیسی) 🇺🇸](https://github.com/wisetrack-io/flutter-sdk/blob/main/README.md)

# پلاگین فلاتر WiseTrack

پلاگین فلاتر WiseTrack یک راه‌حل چندپلتفرمی برای ردیابی تعاملات کاربران، رویدادها و اعلان‌های پوش در برنامه‌های فلاتر ارائه می‌دهد. این راهنما نصب، راه‌اندازی و استفاده از این پلاگین را برای پلتفرم‌های iOS و اندروید پوشش می‌دهد و شامل مثال‌هایی برای موارد استفاده رایج است.

## فهرست مطالب
- [ویژگی‌ها](#ویژگی‌ها)
- [نیازمندی‌ها](#نیازمندی‌ها)
- [نصب](#نصب)
- [راه‌اندازی اولیه](#راه‌اندازی-اولیه)
- [استفاده پایه](#استفاده-پایه)
  - [فعال/غیرفعال کردن ردیابی](#فعالغیرفعال-کردن-ردیابی)
  - [درخواست مجوز شفافیت ردیابی برنامه (ATT) (iOS)](#درخواست-مجوز-شفافیت-ردیابی-برنامه-att-ios)
  - [شروع/توقف ردیابی](#شروعتوقف-ردیابی)
  - [تنظیم توکن‌های اعلان پوش](#تنظیم-توکن‌های-اعلان-پوش)
  - [ثبت رویدادهای سفارشی](#ثبت-رویدادهای-سفارشی)
  - [تنظیم سطوح لاگ](#تنظیم-سطوح-لاگ)
  - [بازیابی شناسه‌های تبلیغاتی](#بازیابی-شناسه‌های-تبلیغاتی)
- [استفاده پیشرفته](#استفاده-پیشرفته)
  - [سفارشی‌سازی رفتار SDK](#سفارشی‌سازی-رفتار-sdk)
- [پروژه نمونه](#پروژه-نمونه)
- [عیب‌یابی](#عیب‌یابی)
- [مجوز](#مجوز)

## ویژگی‌ها
- ردیابی چندپلتفرمی برای iOS و اندروید
- پشتیبانی از ثبت رویدادهای سفارشی و درآمدی
- مدیریت توکن اعلان پوش (APNS و FCM)
- پشتیبانی از شفافیت ردیابی برنامه (ATT) برای iOS
- سطوح لاگ قابل تنظیم
- پشتیبانی از هیت‌مپ (فقط در iOS، از طریق ادغام بومی)
- بازیابی شناسه تبلیغاتی (IDFA برای iOS، Ad ID برای اندروید)

## نیازمندی‌ها
- فلاتر 3.0.0 یا بالاتر
- دارت 2.17.0 یا بالاتر
- iOS 11.0 یا بالاتر
- اندروید API 21 (لالی‌پاپ) یا بالاتر

## نصب
برای ادغام پلاگین فلاتر WiseTrack در پروژه فلاتر خود، مراحل زیر را دنبال کنید:

1. **افزودن وابستگی**:
   پلاگین `wisetrack` را به فایل `pubspec.yaml` خود اضافه کنید:
   ```yaml
   dependencies:
     wisetrack: ^2.0.0 # با آخرین نسخه جایگزین کنید
   ```

2. **نصب بسته**:
   دستور زیر را در دایرکتوری پروژه خود اجرا کنید:
   ```bash
   flutter pub get
   ```

3. **پیکربندی iOS**:
   برای پشتیبانی از شفافیت ردیابی برنامه (ATT) در iOS، کلید زیر را به فایل `ios/Runner/Info.plist` اضافه کنید:
   ```xml
   <key>NSUserTrackingUsageDescription</key>
   <string>ما از این داده‌ها برای ارائه تجربه کاربری بهتر و تبلیغات شخصی‌سازی‌شده استفاده می‌کنیم.</string>
   ```

4. **پیکربندی اندروید**:
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
     implementation 'io.wisetrack:sdk:oaid:2.0.0' # با آخرین نسخه جایگزین کنید
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
     implementation 'io.wisetrack:sdk:referrer:2.0.0' # با آخرین نسخه جایگزین کنید
     implementation 'com.android.installreferrer:installreferrer:2.2' # ارجاع Google Play
     implementation 'com.github.cafebazaar:referrersdk:1.0.2' # ارجاع کافه‌بازار
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
               classpath 'com.google.gms:google-services:4.4.1' # یا آخرین نسخه
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

5. **بازسازی پروژه**:
   پروژه خود را اجرا کنید تا مطمئن شوید همه وابستگی‌ها به درستی ادغام شده‌اند:
   ```bash
   flutter run
   ```

## راه‌اندازی اولیه
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
    userEnvironment: WTUserEnvironment.production, // برای تست از .sandbox استفاده کنید
    androidStore: WTAndroidStore.googlePlay,
    iOSStore: WTIOSStore.appStore,
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

### تنظیم توکن‌های اعلان پوش
توکن‌های APNs یا FCM را برای اعلان‌های پوش تنظیم کنید:

```dart
await WiseTrack.instance.setAPNSToken('your-apns-token'); // تنظیم توکن APNs (iOS)

await WiseTrack.instance.setFCMToken('your-fcm-token'); // تنظیم توکن FCM (اندروید)
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

### تنظیم سطوح لاگ
میزان جزئیات لاگ‌های SDK را کنترل کنید:

```dart
await WiseTrack.instance.setLogLevel(WTLogLevel.warning); // گزینه‌ها: error، warning، info، debug
```

### بازیابی شناسه‌های تبلیغاتی
شناسه تبلیغاتی (IDFA) در iOS یا شناسه تبلیغاتی (Ad ID) در اندروید را بازیابی کنید:

```dart
String? idfa = await WiseTrack.instance.getIdfa(); // دریافت IDFA (iOS)
print('IDFA: ${idfa ?? "در دسترس نیست"}');

String? adId = await WiseTrack.instance.getAdId(); // دریافت Ad ID (اندروید)
print('Ad ID: ${adId ?? "در دسترس نیست"}');
```

## استفاده پیشرفته

### سفارشی‌سازی رفتار SDK
شما می‌توانید رفتار SDK را از طریق پارامترهای `WTInitialConfig` سفارشی کنید:
- `appToken`: توکن یکتای برنامه شما (الزامی).
- `userEnvironment`: محیط (`.production`, `.sandbox`).
- `androidStore`: فروشگاه برنامه اندروید (مانند `.googleplay`, `.cafebazaar`, `.myket`  `.other`).
- `iOSStore`: فروشگاه برنامه iOS (مانند `.appstore`, `.sibche`, `.sibapp`, `.anardoni`, `.sibirani`, `.sibjo`, `.other`).
- `trackingWattingTime`: تاخیر قبل از شروع ردیابی (به میلی‌ثانیه).
- `startTrackerAutomatically`: آیا ردیابی به صورت خودکار شروع شود.
- `customDeviceId`: یک شناسه دستگاه سفارشی.
- `defaultTracker`: یک ردیاب پیش‌فرض برای تخصیص رویداد.
- `appSecret`: یک کلید مخفی برای احراز هویت.
- `secretId`: یک شناسه مخفی یکتا.
- `attributionDeeplink`: فعال کردن تخصیص دیپ‌لینک.
- `eventBuffering`: فعال کردن بافرینگ رویداد برای انتقال بهینه داده.
- `logLevel`: تنظیم سطح لاگ اولیه.
- `oaidEnabled`: نشان‌دهنده فعال بودن شناسه تبلیغاتی باز (OAID).
- `referrerEnabled`: نشان‌دهنده فعال بودن شناسه ارجاع.

مثال با پیکربندی پیشرفته:
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

## پروژه نمونه
یک پروژه نمونه که ادغام پلاگین فلاتر WiseTrack را نشان می‌دهد، در [مخزن گیت‌هاب](https://github.com/wisetrack-io/flutter-sdk/tree/main/example) در دسترس است. مخزن را کلون کرده و دستورالعمل‌های راه‌اندازی را دنبال کنید تا پلاگین را در عمل ببینید.

## عیب‌یابی
- **SDK راه‌اندازی نمی‌شود**: اطمینان حاصل کنید که `appToken` صحیح است و شبکه در دسترس است.
- **ردیابی کار نمی‌کند**: بررسی کنید که `setEnabled(true)` فراخوانی شده و مجوز ATT اعطا شده است (iOS).
- **لاگ‌ها نمایش داده نمی‌شوند**: سطح لاگ را به `WTLogLevel.debug` تنظیم کنید و مطمئن شوید که یک شنونده لاگ تنظیم شده است:
  ```dart
  WiseTrack.instance.listenOnLogs((message) => print('لاگ SDK: $message'));
  ```
- **IDFA/Ad ID در دسترس نیست**: اطمینان حاصل کنید که مجوز ATT اعطا شده است (iOS) یا Google Play Services گنجانده شده است (اندروید).
- **اعلان‌های پوش ردیابی نمی‌شوند**: بررسی کنید که توکن‌های APNS/FCM معتبر تنظیم شده‌اند.

برای کمک بیشتر، با پشتیبانی در [support@wisetrack.io](mailto:support@wisetrack.io) تماس بگیرید.

## مجوز
پلاگین فلاتر WiseTrack تحت توافق‌نامه مجوز SDK WiseTrack منتشر شده است. برای جزئیات، فایل [LICENSE](LICENSE) را ببینید.