import 'package:flutter/material.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/discover/presentation/discover_screen.dart';
import '../features/discipleship/presentation/discipleship_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../screens/events_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [
    HomeScreen(),
    DiscoverScreen(),
    DiscipleshipScreen(),
    EventsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Discipleship',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          label: 'Events',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    ),
  );
}
