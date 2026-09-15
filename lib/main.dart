import 'package:flutter/material.dart';

void main() {
  runApp(const CouYouthApp());
}

class CouYouthApp extends StatelessWidget {
  const CouYouthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Church of Uganda Youth Platform',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4B2E83),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    DiscipleshipScreen(),
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
          setState(() {
            _currentIndex = index;
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church of Uganda Youth Platform'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Connecting Young People. Growing Disciples. Transforming Nations.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Word",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Daily Bible verse and devotion will appear here.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Quick Access',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: const [
              QuickAccessCard(
                icon: Icons.menu_book,
                title: 'Discipleship',
              ),
              QuickAccessCard(
                icon: Icons.event,
                title: 'Events',
              ),
              QuickAccessCard(
                icon: Icons.volunteer_activism,
                title: 'Prayer',
              ),
              QuickAccessCard(
                icon: Icons.school,
                title: 'Training',
              ),
              QuickAccessCard(
                icon: Icons.music_note,
                title: 'Talent Hub',
              ),
              QuickAccessCard(
                icon: Icons.work_outline,
                title: 'Opportunities',
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'Upcoming Events',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          const Card(
            child: ListTile(
              leading: Icon(Icons.event_available),
              title: Text('No upcoming events yet'),
              subtitle: Text(
                'Events from the Laravel API will appear here.',
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Latest News',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          const Card(
            child: ListTile(
              leading: Icon(Icons.campaign_outlined),
              title: Text('No announcements yet'),
              subtitle: Text(
                'Church news and announcements will appear here.',
              ),
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
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
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
    return const Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
      ),
      body: Center(
        child: Text(
          'News, opportunities, media and resources',
        ),
      ),
    );
  }
}

class DiscipleshipScreen extends StatelessWidget {
  const DiscipleshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(
        title: Text('Discipleship'),
      ),
      body: Center(
        child: Text(
          'Courses, Bible studies, devotions and Life Groups',
        ),
      ),
    );
  }
}

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: Center(
        child: Text(
          'Upcoming Church of Uganda youth events',
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text(
          'Profile, certificates, notifications and accessibility',
        ),
      ),
    );
  }
}