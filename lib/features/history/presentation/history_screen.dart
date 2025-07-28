import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String getEmoji(String emotion) {
    const emojis = {
      'Грусть': '😢',
      'Злость': '😠',
      'Спокойствие': '😐',
      'Радость': '🙂',
      'Вдохновение': '😍',
      'Стресс': '🤯',
      'Усталость': '😴',
      'Растерянность': '😶‍🌫️',
    };
    return emojis[emotion] ?? '🙂';
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) return 'Сегодня';
    if (entryDate == yesterday) return 'Вчера';
    return DateFormat('d MMMM', 'ru').format(date);
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
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: Text('Вы не вошли в систему'));
    }

    final historyStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: _buildBackground(isDark),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: historyStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(child: Text('Пока нет истории'));
              }

              final Map<String, List<QueryDocumentSnapshot>> grouped = {};
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'];
                if (timestamp == null || !(timestamp is Timestamp)) continue;

                final dateKey = formatDate(timestamp.toDate());
                grouped.putIfAbsent(dateKey, () => []).add(doc);
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: grouped.entries.map((entry) {
                  final dateTitle = entry.key;
                  final items = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...items.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final emotion = data['emotion'] ?? '';
                        final comment = data['comment'] ?? '';
                        final response = data['response'] ?? '';
                        final timestamp = data['timestamp'];
                        final isFavorite = data['isFavorite'] ?? false;

                        final timeStr = timestamp != null
                            ? DateFormat('HH:mm').format(timestamp.toDate())
                            : '';

                        return Dismissible(
                          key: ValueKey(doc.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            final deletedData = doc.data();
                            await doc.reference.delete();

                            // Показываем SnackBar с Undo
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Запись удалена'),
                                action: SnackBarAction(
                                  label: 'Отменить',
                                  onPressed: () async {
                                    await doc.reference.set(deletedData);
                                  },
                                ),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                            return true;
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(getEmoji(emotion), style: const TextStyle(fontSize: 22)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              emotion,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await doc.reference.update({'isFavorite': !isFavorite});
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(isFavorite
                                                      ? 'Удалено из избранного'
                                                      : 'Добавлено в избранное'),
                                                ),
                                              );
                                            },
                                            child: Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: Colors.pinkAccent,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            timeStr,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: isDark ? Colors.white54 : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      if (comment.isNotEmpty)
                                        Text(
                                          'Комментарий: $comment',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      if (comment.isNotEmpty) const SizedBox(height: 8),
                                      Text(
                                        response,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );


                      }),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
