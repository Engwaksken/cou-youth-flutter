import 'package:flutter/material.dart';

import 'screens/church_locator_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/events_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/prayer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CouYouthApp());
}

class CouYouthApp extends StatelessWidget {
  const CouYouthApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4B2E83);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Church of Uganda Youth Platform',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F2937),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFEDE9FE),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    CoursesScreen(),
    EventsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Discipleship',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COU Youth Platform'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _open(context, const NotificationsScreen()),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF4B2E83), Color(0xFF204F78)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.church_outlined, color: Colors.white, size: 36),
                const SizedBox(height: 16),
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connecting Young People. Growing Disciples. Transforming Nations.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Access',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              QuickAccessCard(
                icon: Icons.menu_book_outlined,
                title: 'Discipleship',
                onTap: () => _open(context, const CoursesScreen()),
              ),
              QuickAccessCard(
                icon: Icons.event_outlined,
                title: 'Events',
                onTap: () => _open(context, const EventsScreen()),
              ),
              QuickAccessCard(
                icon: Icons.volunteer_activism_outlined,
                title: 'Prayer',
                onTap: () => _open(context, const PrayerScreen()),
              ),
              QuickAccessCard(
                icon: Icons.location_on_outlined,
                title: 'Church Locator',
                onTap: () => _open(context, const ChurchLocatorScreen()),
              ),
              QuickAccessCard(
                icon: Icons.notifications_active_outlined,
                title: 'Notifications',
                onTap: () => _open(context, const NotificationsScreen()),
              ),
              QuickAccessCard(
                icon: Icons.work_outline,
                title: 'Opportunities',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opportunities module is being connected.'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.shield_outlined),
              ),
              title: const Text('Safe and inclusive youth community'),
              subtitle: const Text(
                'Prayer, pastoral support, safeguarding and accessibility are built into the platform.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(context, const PrayerScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String title, String subtitle})>[
      (
        icon: Icons.campaign_outlined,
        title: 'News & Announcements',
        subtitle: 'Church and youth ministry updates',
      ),
      (
        icon: Icons.work_outline,
        title: 'Opportunities',
        subtitle: 'Jobs, scholarships, training and volunteering',
      ),
      (
        icon: Icons.music_note_outlined,
        title: 'Talent Hub',
        subtitle: 'Music, arts, sports, media and technology',
      ),
      (
        icon: Icons.photo_library_outlined,
        title: 'Media & Resources',
        subtitle: 'Videos, audio, documents and ministry resources',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(item.icon)),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person_outline, size: 30),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Youth Member',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text('Sign in to view your full profile and progress.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: const Text('Certificates'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notification preferences'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.accessibility_new_outlined),
                  title: const Text('Accessibility'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
