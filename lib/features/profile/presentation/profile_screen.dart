import 'dart:ui';
import 'package:emotion_gpt_app/core/theme/theme_notifier.dart';
import 'package:emotion_gpt_app/core/routes/app_routes.dart';
import 'package:emotion_gpt_app/features/profile/data/profile_repository.dart';
import 'package:emotion_gpt_app/features/profile/domain/profile_use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

/// Экран профиля с настройками, очисткой истории и выходом.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmAndClearHistory(BuildContext context, ProfileUseCases useCases) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить историю'),
        content: const Text('Вы точно хотите очистить историю?'),
        actions: [
          TextButton(child: const Text('Отмена'), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: const Text('Очистить'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirmed != true) return;

    await useCases.clearHistory();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('История очищена')),
      );
    }
  }

  Future<void> _signOut(BuildContext context, ProfileUseCases useCases) async {
    await useCases.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.auth, (_) => false);
    }
  }

  Future<void> _launchTelegram(BuildContext context, ProfileUseCases useCases) async {
    final success = await useCases.openTelegram('https://t.me/sashailcnuk');
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть Telegram')),
      );
    }
  }

  BoxDecoration _buildBackground(bool isDark) {
    return BoxDecoration(
      gradient: isDark
          ? const LinearGradient(colors: [Color(0xFF2D2D3A), Color(0xFF1C1C25)])
          : const LinearGradient(colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final useCases = ProfileUseCases(ProfileRepository());

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: _buildBackground(isDark),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Заголовок с аватаркой и телефоном
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: const Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        useCases.getCurrentUserPhone(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _signOut(context, useCases),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                    ),
                  ],
                ).animate().fade(duration: 500.ms).slide(),

                const SizedBox(height: 24),

                // Основной блок с настройками
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          _profileOption(
                            context,
                            icon: isDark ? Icons.dark_mode : Icons.light_mode,
                            label: 'Тема оформления',
                            trailing: Switch(
                              value: isDark,
                              onChanged: (value) {
                                final mode = value ? ThemeMode.dark : ThemeMode.light;
                                Provider.of<ThemeNotifier>(context, listen: false).setTheme(mode);
                              },
                            ),
                          ),
                          _profileOption(
                            context,
                            icon: Icons.delete_outline,
                            label: 'Очистить историю',
                            onTap: () => _confirmAndClearHistory(context, useCases),
                          ),
                          _profileOption(
                            context,
                            icon: Icons.info_outline,
                            label: 'О приложении',
                            onTap: () => showAboutDialog(
                              context: context,
                              applicationName: 'Как ты?',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2025 Emotion GPT',
                            ),
                          ),
                          _profileOption(
                            context,
                            icon: Icons.telegram,
                            label: 'Обратная связь',
                            onTap: () => _launchTelegram(context, useCases),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fade().slideY(begin: 0.2),

                const Spacer(),
                Text(
                  'Как ты? © 2025',
                  style: theme.textTheme.bodySmall?.copyWith(color: textColor.withOpacity(0.5)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Виджет для одного пункта профиля.
  Widget _profileOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
    );
  }
}
