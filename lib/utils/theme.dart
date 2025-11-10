import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Fredoka',
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Color(0xFFF5F5F3),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.blue),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.white,
    hourMinuteTextColor: Colors.blue,
    dialHandColor: Colors.blue,
    dialBackgroundColor: Colors.blue.shade50,
    entryModeIconColor: Colors.blue,
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.white,
    headerBackgroundColor: Colors.blue,
    headerForegroundColor: Colors.white,
    todayBorder: const BorderSide(color: Colors.blue),
    todayForegroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected) ? Colors.white : Colors.black),
    todayBackgroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.blue
            : Colors.transparent),
    dayForegroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected) ? Colors.white : Colors.black),
    dayBackgroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.blue
            : Colors.transparent),
    yearForegroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected) ? Colors.white : Colors.black),
    yearBackgroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.blue
            : Colors.transparent),
  ),
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFF5F5F3),
    primary: Colors.white,
    secondary: Colors.black,
    tertiary: Colors.grey,
    primaryContainer: Color(0xFFE5E5E4),
    secondaryContainer: Colors.black54,
    tertiaryContainer: Colors.white,
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blue,
    selectionHandleColor: Colors.blue,
    selectionColor: Colors.blue.withOpacity(0.4),
  ),
  iconButtonTheme: IconButtonThemeData(
      style:
          ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.black))),
  useMaterial3: true,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Fredoka',
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.black,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.blue),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.grey[900],
    hourMinuteTextColor: Colors.blue,
    dialHandColor: Colors.blue,
    dialBackgroundColor: Colors.black12,
    entryModeIconColor: Colors.blue,
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.grey[900],
    headerBackgroundColor: Colors.blue,
    headerForegroundColor: Colors.white,
    todayBorder: const BorderSide(color: Colors.blue),
    todayForegroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.white
            : Colors.grey.shade300),
    todayBackgroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.blue
            : Colors.transparent),
    dayForegroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.white
            : Colors.grey.shade300),
    dayBackgroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.blue
            : Colors.transparent),
    yearForegroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.white
            : Colors.grey.shade300),
    yearBackgroundColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.blue
            : Colors.transparent),
  ),
  colorScheme: ColorScheme.dark(
    surface: Colors.black,
    primary: Colors.grey.shade900,
    secondary: Colors.white,
    tertiary: Colors.grey.shade600,
    primaryContainer: const Color(0xFF1C1C1F),
    secondaryContainer: const Color(0xFF636366),
    tertiaryContainer: const Color(0xFF636366),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blue,
    selectionHandleColor: Colors.blue,
    selectionColor: Colors.blue.withOpacity(0.4),
  ),
  iconButtonTheme: IconButtonThemeData(
      style:
          ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.white))),
  useMaterial3: true,
);
