import 'package:flutter/material.dart';
import 'package:wisetrack_example/views/home_screen.dart';

import 'themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
