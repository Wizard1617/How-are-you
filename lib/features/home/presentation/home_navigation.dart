import 'package:flutter/material.dart';

import '../../emotion/presentation/emotion_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currentIndex = 0; // Эмоции — первый экран

  final List<Widget> _screens = [
    EmotionScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),

        backgroundColor: const Color(0xFF8EC5FC), // светло-синий фон

        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),

        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),

        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // чтобы все 3 иконки были видны всегда

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: 'Эмоции',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'История',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
