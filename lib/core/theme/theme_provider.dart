import 'package:flutter/material.dart';
import 'package:pic_board/core/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeMode = lightMode;

  get themeMode => _themeMode;

  void changeToDarkMode() {
    _themeMode = _themeMode==lightMode?darkMode:lightMode;
    notifyListeners();
  }
}