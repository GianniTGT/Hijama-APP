import 'package:flutter/material.dart';
import 'today_screen.dart';
import 'calendar_screen.dart';
import 'guide_screen.dart';
import 'points_screen.dart';
import 'hadith_screen.dart';
import 'diary_screen.dart';
import '../services/localization_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TodayScreen(),
    CalendarScreen(),
    GuideScreen(),
    PointsScreen(),
    HadithScreen(),
    DiaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = localization;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.wb_sunny_outlined),
            activeIcon: const Icon(Icons.wb_sunny),
            label: t.t('tab_today'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: const Icon(Icons.calendar_month),
            label: t.t('tab_calendar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checklist_outlined),
            activeIcon: const Icon(Icons.checklist),
            label: t.t('tab_guide'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.accessibility_new_outlined),
            activeIcon: const Icon(Icons.accessibility_new),
            label: t.t('tab_points'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: t.t('tab_hadiths'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_outlined),
            activeIcon: const Icon(Icons.book),
            label: t.t('tab_diary'),
          ),
        ],
      ),
    );
  }
}
