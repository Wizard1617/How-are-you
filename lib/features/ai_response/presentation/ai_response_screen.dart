import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emotion_gpt_app/features/ai_response/data/ai_response_api.dart';
import 'package:emotion_gpt_app/features/ai_response/domain/ai_response_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Экран, отображающий ответ от ИИ и сохраняющий его в Firebase Firestore
class AiResponseScreen extends StatefulWidget {
  final String emotion;
  final String comment;

  const AiResponseScreen({
    super.key,
    required this.emotion,
    required this.comment,
  });

  @override
  State<AiResponseScreen> createState() => _AiResponseScreenState();
}

class _AiResponseScreenState extends State<AiResponseScreen>
    with SingleTickerProviderStateMixin {
  late Future<AiResponseModel> _futureResponse;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFavorite = false; // Состояние избранного
  DocumentReference? _savedDocRef; // Ссылка на сохранённый документ Firestore

  @override
  void initState() {
    super.initState();

    // Инициализация анимации ожидания
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Получение ответа и сохранение истории
    _futureResponse = _fetchAndSaveResponse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Получение AI-ответа + сохранение его в Firestore
  Future<AiResponseModel> _fetchAndSaveResponse() async {
    final api = AiResponseApi();
    final response =
        await api.fetchAiResponse(widget.emotion, widget.comment);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'emotion': widget.emotion,
      'comment': widget.comment,
      'response': response.response,
      'timestamp': FieldValue.serverTimestamp(),
      'isFavorite': false,
    });

    _savedDocRef = docRef;
    _controller.stop();

    return response;
  }

  /// Эмодзи по эмоции
  String getEmoji(String emotion) {
    final emotions = {
      'Грусть': '😢',
      'Злость': '😠',
      'Спокойствие': '😐',
      'Радость': '🙂',
      'Вдохновение': '😍',
      'Стресс': '🤯',
      'Усталость': '😴',
      'Растерянность': '😶‍🌫️',
    };
    return emotions[emotion] ?? '🙂';
  }

  /// Фон с градиентом в зависимости от темы
  BoxDecoration _buildBackground(bool isDark) {
    return BoxDecoration(
      gradient: isDark
          ? const LinearGradient(
              colors: [Color(0xFF1E1E2E), Color(0xFF121212)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: _buildBackground(isDark),
        child: SafeArea(
          child: FutureBuilder<AiResponseModel>(
            future: _futureResponse,
            builder: (context, snapshot) {
              // Загрузка
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          getEmoji(widget.emotion),
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Генерирую ответ...',
                        style: TextStyle(
                          fontSize: 18,
                          color: textColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Ошибка
              else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Ошибка:\n${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              // Готовый ответ
              final aiResponse = snapshot.data!.response;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // Заголовок
                    Text(
                      '${getEmoji(widget.emotion)} ${widget.emotion}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Карточка с ответом ИИ + блюр
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Text(
                            aiResponse,
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),

                    const Spacer(),

                    // Нижние кнопки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Избранное
                        IconButton(
                          onPressed: () async {
                            if (_savedDocRef != null) {
                              setState(() => _isFavorite = !_isFavorite);
                              await _savedDocRef!.update({'isFavorite': _isFavorite});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_isFavorite
                                      ? 'Добавлено в избранное'
                                      : 'Удалено из избранного'),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.pinkAccent,
                          ),
                          tooltip: 'Избранное',
                        ),

                        // Поделиться (реализация TODO)
                        IconButton(
                          onPressed: () {
                            // TODO: реализация шаринга
                          },
                          icon: Icon(Icons.share, color: textColor),
                          tooltip: 'Поделиться',
                        ),

                        // Назад на экран "Сегодня"
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.today),
                          label: const Text('Сегодня'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: textColor,
                            elevation: 4,
                            shadowColor: Colors.black26,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
