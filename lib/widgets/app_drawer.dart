import 'package:flutter/material.dart';

import '../screens/annual_theme_screen.dart';
import '../screens/church_locator_screen.dart';
import '../screens/courses_screen.dart';
import '../screens/events_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/prayer_screen.dart';
import '../screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4B2E83), Color(0xFF204F78)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.church_outlined,
                      color: Color(0xFF4B2E83),
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'COU Youth Platform',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Connect • Grow • Serve',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ListTile(
                    leading: Icon(Icons.home_outlined, color: scheme.primary),
                    title: const Text('Home'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  ListTile(
                    leading: Icon(Icons.auto_stories_outlined, color: scheme.primary),
                    title: const Text('Annual Theme'),
                    subtitle: const Text('Mission, vision and current theme'),
                    onTap: () => _open(context, const AnnualThemeScreen()),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: const Text('Discipleship'),
                    onTap: () => _open(context, const CoursesScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('Events'),
                    onTap: () => _open(context, const EventsScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.volunteer_activism_outlined),
                    title: const Text('Prayer'),
                    onTap: () => _open(context, const PrayerScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Church Locator'),
                    onTap: () => _open(context, const ChurchLocatorScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    onTap: () => _open(context, const NotificationsScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Profile'),
                    onTap: () => _open(context, const ProfileScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
