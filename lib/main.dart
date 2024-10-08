import 'app.dart';
import 'package:flutter/material.dart';
import 'common/theme_model.dart';
import 'common/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final themeModel = ThemeModel();
  await themeModel.loadThemePreference();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeModel),
        ChangeNotifierProvider(create: (_) => ThemeProvider(themeModel))
      ],
      child: const App(),
    ),
  );
}
