import 'package:flutter/material.dart';

import '../models/annual_theme_content.dart';
import '../screens/annual_theme_screen.dart';
import '../screens/church_locator_screen.dart';
import '../screens/courses_screen.dart';
import '../screens/events_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/prayer_screen.dart';
import '../screens/profile_screen.dart';
import '../services/annual_theme_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AnnualThemeService _service = AnnualThemeService();
  AnnualThemeBranding _branding = const AnnualThemeBranding();

  @override
  void initState() {
    super.initState();
    _loadBranding();
  }

  Future<void> _loadBranding() async {
    final cached = await _service.readCached();
    if (mounted && cached != null) {
      setState(() => _branding = cached.branding);
    }

    try {
      final live = await _service.fetch();
      if (mounted) setState(() => _branding = live.branding);
    } catch (_) {
      // Keep the default or cached branding when offline.
    }
  }

  Color _parseColor(String value, Color fallback) {
    final clean = value.replaceFirst('#', '').trim();
    final hex = clean.length == 6 ? 'FF$clean' : clean;
    final parsed = int.tryParse(hex, radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = _parseColor(_branding.primaryColor, scheme.primary);
    final secondary = _parseColor(
      _branding.secondaryColor,
      const Color(0xFF204F78),
    );

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, secondary]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _branding.logoUrl != null
                        ? Image.network(
                            _branding.logoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.church_outlined,
                              color: primary,
                              size: 30,
                            ),
                          )
                        : Icon(
                            Icons.church_outlined,
                            color: primary,
                            size: 30,
                          ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _branding.shortName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _branding.tagline,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ListTile(
                    leading: Icon(Icons.home_outlined, color: primary),
                    title: const Text('Home'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  ListTile(
                    leading: Icon(Icons.auto_stories_outlined, color: primary),
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
