import 'package:flutter/material.dart';
import 'theme_model.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeModel _themeModel;

  ThemeProvider(this._themeModel) {
    _themeModel.addListener(() {
      notifyListeners();
    });
  }

  ThemeMode get theme => _themeModel.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDark => _themeModel.isDarkMode ? true : false;
}