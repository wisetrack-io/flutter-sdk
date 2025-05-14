import 'package:flutter/material.dart';

class Themes {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xfff0eff8),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xfff0eff8)),
        primaryColor: Colors.indigoAccent.shade400,
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.black)),
        ),
        dividerColor: Colors.grey.shade400,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade500),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 17, 21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 18, 17, 21),
        ),
        primaryColor: Colors.indigoAccent.shade400,
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.white)),
        ),
        dividerColor: const Color.fromARGB(255, 76, 73, 84),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 36, 32, 43),
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
        ),
      );
}
