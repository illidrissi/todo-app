// import 'package:flutter/material.dart';

// class ThemeProvider extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.light;

//   ThemeMode get themeMode => _themeMode;
//   bool get isDarkMode => _themeMode == ThemeMode.dark;

//   void toggleTheme(bool isOn) {
//     _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }

//   ThemeData get currentTheme => isDarkMode ? _darkTheme : _lightTheme;

//   static final ThemeData _lightTheme = ThemeData.light().copyWith(
//     colorScheme: const ColorScheme.light(
//       primary: tdBlue,
//       secondary: tdBlue,
//       surface: Colors.white,
//       background: Colors.white,
//     ),
//     scaffoldBackgroundColor: Colors.white,
//   );

//   static final ThemeData _darkTheme = ThemeData.dark().copyWith(
//     colorScheme: const ColorScheme.dark(
//       primary: tdBlue,
//       secondary: tdBlue,
//       surface: Colors.grey,
//       background: Color(0xFF121212),
//     ),
//     scaffoldBackgroundColor: const Color(0xFF121212),
//   );
// }