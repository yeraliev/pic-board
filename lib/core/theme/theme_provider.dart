import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pic_board/core/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  ThemeData _themeMode = lightMode;

  ThemeData get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _storage.read(key: 'isDarkTheme');
    _themeMode = (isDark == 'true') ? darkMode : lightMode;
    notifyListeners();
  }

  Future<void> changeToDarkMode() async {
    if (_themeMode == lightMode) {
      _themeMode = darkMode;
      await _storage.write(key: 'isDarkTheme', value: 'true');
    } else {
      _themeMode = lightMode;
      await _storage.write(key: 'isDarkTheme', value: 'false');
    }
    notifyListeners();
  }
}
