import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyQuoteCard extends StatelessWidget {
  DailyQuoteCard({super.key});

  final List<String> _quotes = [
    "Ты справишься — ты уже на пути.",
    "Сегодня — отличный день, чтобы начать.",
    "Не сдавайся, когда тяжело — ты растёшь.",
    "Каждый день — новая возможность.",
    "Ты достоин лучшего. И точка.",
    "Ошибки — это шаги к успеху.",
    "Главное — продолжать двигаться.",
    "Твоя энергия создаёт твой день.",
    "Ты сильнее, чем думаешь.",
    "Всё получится. Ты не один.",
  ];

  String _getTodayQuote() {
    final date = DateTime.now();
    final dayIndex = int.parse(DateFormat('yyyyMMdd').format(date)) % _quotes.length;
    return _quotes[dayIndex];
  }

  @override
  Widget build(BuildContext context) {
    final quote = _getTodayQuote();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Фон
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              height: 160,
              width: double.infinity,
            ),
            // Блюр и текст
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                height: 160,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                color: Colors.white.withOpacity(0.1),
                child: Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black26,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
