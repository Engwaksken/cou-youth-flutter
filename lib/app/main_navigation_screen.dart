import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import '../screens/courses_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/events_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.onExitSession,
  });

  final Future<void> Function() onExitSession;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final screens = <Widget>[
      const HomeScreen(),
      const DiscoverScreen(),
      const CoursesScreen(),
      const EventsScreen(),
      ProfileScreen(onExitSession: widget.onExitSession),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: strings.text('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore),
            label: strings.text('discover'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: strings.text('discipleship'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: strings.text('events'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: strings.text('profile'),
          ),
        ],
      ),
    );
  }
}
