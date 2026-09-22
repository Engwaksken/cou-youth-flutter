import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import '../screens/courses_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/events_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/youth_app_drawer.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.onExitSession});

  final Future<void> Function() onExitSession;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final screens = <Widget>[
      HomeScreen(onOpenDrawer: _openDrawer),
      DiscoverScreen(onOpenDrawer: _openDrawer),
      CoursesScreen(onOpenDrawer: _openDrawer),
      EventsScreen(onOpenDrawer: _openDrawer),
      ProfileScreen(
        onExitSession: widget.onExitSession,
        onOpenDrawer: _openDrawer,
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: YouthAppDrawer(
        currentIndex: _currentIndex,
        onSelectMainTab: _selectTab,
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
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
