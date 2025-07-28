import 'dart:ui';
import 'package:emotion_gpt_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmotionScreen extends StatefulWidget {
  const EmotionScreen({super.key});

  @override
  State<EmotionScreen> createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? selectedEmotion;

  final emotions = [
    {'emoji': '😢', 'label': 'Грусть'},
    {'emoji': '😠', 'label': 'Злость'},
    {'emoji': '😐', 'label': 'Спокойствие'},
    {'emoji': '🙂', 'label': 'Радость'},
    {'emoji': '😍', 'label': 'Вдохновение'},
    {'emoji': '🤯', 'label': 'Стресс'},
    {'emoji': '😴', 'label': 'Усталость'},
    {'emoji': '😶‍🌫️', 'label': 'Растерянность'},
  ];

  void _onSend() {
    if (selectedEmotion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выбери эмоцию')),
      );
      return;
    }

    final comment = _commentController.text.trim();

    Navigator.pushNamed(
      context,
      AppRoutes.aiResponse,
      arguments: {
        'emotion': selectedEmotion,
        'comment': comment,
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  BoxDecoration _buildBackground(bool isDark) {
    return BoxDecoration(
      gradient: isDark
          ? const LinearGradient(
        colors: [Color(0xFF2D2D3A), Color(0xFF1C1C25)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
          : const LinearGradient(
        colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: _buildBackground(isDark),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Заголовок с анимацией
                          Text(
                            'Как ты сегодня?',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),

                          const SizedBox(height: 24),

                          // Эмоции с анимацией
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: emotions.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, index) {
                              final item = emotions[index];
                              final isSelected = selectedEmotion == item['label'];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedEmotion = item['label'];
                                  });
                                },
                                child: AnimatedScale(
                                  scale: isSelected ? 1.2 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.elasticOut,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? textColor.withOpacity(0.2)
                                          : textColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: isSelected
                                          ? Border.all(color: textColor.withOpacity(0.7), width: 2)
                                          : null,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(item['emoji']!, style: const TextStyle(fontSize: 28)),
                                        const SizedBox(height: 6),
                                        Text(
                                          item['label']!,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: textColor,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate(delay: (index * 100).ms).fadeIn().scale();

                            },
                          ),

                          const SizedBox(height: 24),

                          // Поле ввода с блюром + анимация
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: _commentController,
                                  maxLines: 4,
                                  style: TextStyle(color: textColor),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    hintText: 'Хочешь рассказать, что случилось?',
                                    hintStyle: TextStyle(color: hintColor),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Кнопка
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                    child: GestureDetector(
                      onTap: _onSend,
                      child: Animate(
                        effects: const [
                          ScaleEffect(
                            duration: Duration(milliseconds: 100),
                            begin: Offset(1.0, 1.0),
                            end: Offset(0.96, 0.96),
                          ),
                        ],
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            'Отправить',
                           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                ],
              );

            },
          ),
        ),
      ),
    );
  }
}
