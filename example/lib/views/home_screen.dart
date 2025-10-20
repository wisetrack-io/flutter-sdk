import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisetrack/wisetrack.dart';
import 'package:wisetrack_example/views/logs_view.dart';

import '../app_platform.dart';
import '../widgets/button.dart';
import '../widgets/dropdown.dart';
import '../widgets/inputfield.dart';
import '../widgets/toggle_switch.dart';
import 'custom_event_view.dart';
import 'flutter_webview_screen.dart';
import 'inapp_webview_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  const HomeScreen({this.onToggleTheme, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final wisetrack = WiseTrack.instance;
  WTLogLevel logLevel = WTLogLevel.debug;
  // Color backgroundColor = const Color(0xfff0eff4);
  String appToken = '<AppToken here>';
  final List<String> logs = [];
  final _logStreamController = StreamController<List<String>>.broadcast();
  WTAndroidStore androidStore = WTAndroidStore.other;
  WTAndroidStore? androidCustomStore;
  WTIOSStore iosStore = WTIOSStore.other;
  WTIOSStore? iosCustomStore;
  bool autoStartTracker = true;
  int trackingWaitingTime = 0;
  bool initialLoading = false;
  bool isInitialized = false;
  bool isStarted = false;
  bool attRequestLoading = false;
  bool attAuthorized = false;

  @override
  void initState() {
    WiseTrack.instance.listenOnLogs((message) {
      logs.add(message);
      _logStreamController.add(List.from(logs));
      // log(message);
    });
    super.initState();
  }

  @override
  void dispose() {
    _logStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'WiseTrack App',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        titleSpacing: 24,
        actions: [
          IconButton(
            onPressed: _showLogsBottomSheet,
            icon: const Icon(CupertinoIcons.list_bullet_below_rectangle),
          ),
          IconButton(
            onPressed: () {
              WiseTrack.instance.clearAndStop();
              setState(() {
                initialLoading = false;
                isInitialized = false;
                isStarted = false;
              });
            },
            icon: const Icon(CupertinoIcons.refresh_thin),
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(CupertinoIcons.moon_stars_fill),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              CustomDropdown<WTLogLevel>(
                title: '🐞 Log Level',
                items: WTLogLevel.values,
                mapper: (level) => level.label.toUpperCase(),
                hint: 'Select Log Level',
                initialItem: logLevel,
                onChanged: (level) async {
                  if (level == null) return;
                  await WiseTrack.instance.setLogLevel(level);
                  setState(() => logLevel = level);
                },
              ),
              CustomInputField(
                title: '🔑 App Token',
                onChanged: (str) => appToken = str,
                initialValue: appToken,
                hint: 'Enter App token',
              ),
              Row(
                spacing: 16,
                children: [
                  if (AppPlatform.isAndroid)
                    Expanded(
                      child: CustomDropdown<WTAndroidStore>(
                        title: '📬 Android Store',
                        items:
                            WTAndroidStore.values
                              ..add(WTAndroidStore.custom('custom')),
                        mapper: (level) => level.name.toUpperCase(),
                        hint: 'Select Android Store',
                        initialItem: androidStore,
                        onChanged:
                            (p0) => setState(() {
                              androidCustomStore = null;
                              androidStore = p0!;
                            }),
                      ),
                    ),
                  if (AppPlatform.isIos)
                    Expanded(
                      child: CustomDropdown<WTIOSStore>(
                        title: '📬 iOS Store',
                        items:
                            WTIOSStore.values..add(WTIOSStore.custom('custom')),
                        mapper: (level) => level.name.toUpperCase(),
                        hint: 'Select iOS Store',
                        initialItem: iosStore,
                        onChanged:
                            (p0) => setState(() {
                              iosCustomStore = null;
                              iosStore = p0!;
                            }),
                      ),
                    ),
                ],
              ),
              if (androidStore.name == 'custom' || iosStore.name == 'custom')
                Row(
                  spacing: 16,
                  children: [
                    if (AppPlatform.isAndroid && androidStore.name == 'custom')
                      Expanded(
                        child: CustomInputField(
                          title: '📬 Android Custom Store',
                          hint: 'Select Android Store',
                          initialValue: androidCustomStore?.name,
                          onChanged:
                              (p0) =>
                                  androidCustomStore = WTAndroidStore.custom(
                                    p0,
                                  ),
                        ),
                      ),
                    if (AppPlatform.isIos && iosStore.name == 'custom')
                      Expanded(
                        child: CustomInputField(
                          title: '📬 iOS Custom Store',
                          hint: 'Select iOS Store',
                          initialValue: iosCustomStore?.name,
                          onChanged:
                              (p0) => iosCustomStore = WTIOSStore.custom(p0),
                        ),
                      ),
                  ],
                ),
              CustomToggleSwitch(
                title: 'Start Tracker Automatically',
                initialValue: autoStartTracker,
                onChanged:
                    (b) => setState(() {
                      autoStartTracker = b;
                    }),
              ),
              if (autoStartTracker && AppPlatform.isIos)
                CustomInputField(
                  title: '⏳ Tracking Watting Time',
                  onChanged:
                      (str) => trackingWaitingTime = int.tryParse(str) ?? 5,
                  initialValue: trackingWaitingTime.toString(),
                  hint: 'Enter App token',
                  inputType: TextInputType.number,
                ),
              if (AppPlatform.isIos)
                OutlineButton(
                  title:
                      attAuthorized
                          ? 'ATT Authorized'
                          : '🎯 Request for iOS IDFA (ATT)',
                  isLoading: attRequestLoading,
                  onPressed:
                      attAuthorized
                          ? null
                          : () async {
                            setState(() => attRequestLoading = true);
                            final isAuthorized =
                                await WiseTrack.instance.iOSRequestForATT();
                            setState(() {
                              attRequestLoading = false;
                              attAuthorized = isAuthorized;
                            });
                          },
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      title: '⚡️ Default Event',
                      onPressed: () {
                        WiseTrack.instance.logEvent(
                          WTEvent.defaultEvent(
                            name: "flutter_default_event",
                            params: {
                              'key-1': EventParameter.string('value'),
                              'key-2': EventParameter.number(2.3),
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlineButton(
                      title: '💵 Revenue Event',
                      onPressed: () {
                        WiseTrack.instance.logEvent(
                          WTEvent.revenueEvent(
                            name: "flutter_revenue_event",
                            amount: 120000,
                            currency: RevenueCurrency.IRR,
                            params: {'key': EventParameter.string('value')},
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: OutlineButton(
                      title: '🔈 Set FCM Token',
                      onPressed: () {
                        FirebaseMessaging.instance.getToken().then((token) {
                          if (token != null) {
                            WiseTrack.instance.setFCMToken(token);
                          }
                        });
                      },
                    ),
                  ),
                  if (AppPlatform.isIos)
                    Expanded(
                      child: OutlineButton(
                        title: '🔈 Set APNS Token',
                        onPressed: () {
                          WiseTrack.instance.setAPNSToken(
                            "my_flutter_apns_token",
                          );
                        },
                      ),
                    ),
                ],
              ),
              if (AppPlatform.isAndroid)
                OutlineButton(
                  title: '📦 Set Packages Info',
                  onPressed: () {
                    WiseTrack.instance.setPackgesInfo();
                  },
                ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: OutlineButton(
                      title: 'WebView Flutter',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WebViewFlutterScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: OutlineButton(
                      title: 'InApp WebView',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => InAppWebViewScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              CustomEventView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        child: Container(
          alignment: Alignment.center,
          child: SizedBox(width: double.infinity, child: _bottomBtn()),
        ),
      ),
    );
  }

  Widget _bottomBtn() {
    if (!isInitialized) {
      return ContainedButton(
        title: 'Initialize SDK${autoStartTracker ? ' + Start SDK' : ''}',
        isLoading: initialLoading,
        onPressed: () async {
          try {
            setState(() {
              initialLoading = true;
            });
            await WiseTrack.instance.init(
              WTInitialConfig(
                appToken: appToken,
                iOSStore: iosCustomStore ?? iosStore,
                androidStore: androidCustomStore ?? androidStore,
                startTrackerAutomatically: autoStartTracker,
                trackingWaitingTime: trackingWaitingTime,
                logLevel: logLevel,
                webAppVersion: '1.0.0',
              ),
            );
          } finally {
            setState(() {
              initialLoading = false;
              isInitialized = true;
              isStarted = autoStartTracker;
            });
          }
        },
      );
    }
    if (isStarted) {
      return OutlineButton(
        title: 'Stop Tracking',
        onPressed: () async {
          await WiseTrack.instance.stopTracking();
          setState(() {
            isStarted = false;
          });
        },
      );
    }
    return ContainedButton(
      title: 'Start Tracking',
      backgroundColor: Colors.tealAccent.shade700,
      onPressed: () async {
        await WiseTrack.instance.startTracking();
        setState(() {
          isStarted = true;
        });
      },
    );
  }

  void _showLogsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              LogsView(logs: logs, logStreamController: _logStreamController),
    );
  }
}
