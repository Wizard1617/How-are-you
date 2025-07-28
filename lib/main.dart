import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/routes/app_routes.dart';
import 'firebase_options.dart';
import 'features/auth/data/auth_service.dart';

/// Основная функция, с которой начинается выполнение приложения.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Подключение локализации (для отображения дат, времени и пр.).
  await initializeDateFormatting('ru', null);

  // Инициализация Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Проверка, авторизован ли пользователь.
  final authService = AuthService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(isLoggedIn: authService.isLoggedIn()),
    ),
  );
}

/// Основной виджет приложения.
class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.auth,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
