import 'package:flutter/material.dart';
import 'package:emotion_gpt_app/features/auth/presentation/auth_screen.dart';
import 'package:emotion_gpt_app/features/home/presentation/home_navigation.dart';
import 'package:emotion_gpt_app/features/ai_response/presentation/ai_response_screen.dart';

/// Класс с маршрутами приложения.
/// Используется как централизованная точка маршрутизации.
class AppRoutes {
  static const String auth = '/';
  static const String home = '/home';
  static const String aiResponse = '/ai-response';

  /// Основные маршруты без передачи аргументов.
  static final Map<String, WidgetBuilder> routes = {
    auth: (_) => const AuthScreen(),
    home: (_) => const HomeNavigation(),
  };

  /// Обработка маршрутов с аргументами.
  /// Используется, например, для передачи эмоций и комментариев на экран ответа ИИ.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case aiResponse:
        final args = settings.arguments as Map<String, dynamic>;
        final emotion = args['emotion'] as String;
        final comment = args['comment'] as String;

        return MaterialPageRoute(
          builder: (_) => AiResponseScreen(
            emotion: emotion,
            comment: comment,
          ),
        );

      default:
        // Фолбэк: если путь не найден — показать сообщение.
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Страница не найдена')),
          ),
        );
    }
  }
}
