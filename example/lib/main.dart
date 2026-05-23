import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wisetrack/wisetrack.dart';
import 'package:wisetrack_example/firebase_messaging_handler.dart';
import 'package:wisetrack_example/sdk_logger.dart';
import 'package:wisetrack_example/tracking_observer.dart';
import 'package:wisetrack_example/views/home_screen.dart';
import 'package:wisetrack_example/views/logs_view.dart';

import 'firebase_options.dart';
import 'themes.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WTScreenTrackMixin.routeObserver = wtRouteObserver;
  FirebaseMessagingHandler.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;

  void _showLogs() {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => LogsView(
            logs: SdkLogger.instance.logs,
            logStreamController: SdkLogger.instance.controller,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [wtNavigatorObserver, wtRouteObserver],
      home: HomeScreen(
        onToggleTheme: () {
          setState(() {
            themeMode =
                themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
          });
        },
      ),
      debugShowCheckedModeBanner: false,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child!,
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).viewPadding.bottom + 80,
              child: FloatingActionButton.small(
                heroTag: 'wt-sdk-logs',
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                onPressed: _showLogs,
                child: const Icon(Icons.wrap_text, size: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}
