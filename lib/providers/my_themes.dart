import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF242430),
      centerTitle: true,
    ),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.lightBlue))),
    colorScheme: const ColorScheme.dark(
        primary: Color(0xFF242430), secondary: Color(0xFF88888D)),
  );
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(centerTitle: true),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.blue))),
    colorScheme: ColorScheme.light(
        primary: Colors.blue.shade200, secondary: Colors.blue.shade400),
  );
}
