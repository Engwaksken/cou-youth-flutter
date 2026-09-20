import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import 'chatbot_screen.dart';
import 'church_locator_screen.dart';
import 'courses_screen.dart';
import 'donation_checkout_screen.dart';
import 'events_screen.dart';
import 'life_groups_screen.dart';
import 'media_resources_screen.dart';
import 'notifications_screen.dart';
import 'opportunities_screen.dart';
import 'prayer_screen.dart';
import 'safety_center_screen.dart';
import 'youth_hubs_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('COU Youth Platform'),
        actions: [
          IconButton(
            tooltip: strings.text('youth_assistant'),
            onPressed: () => _open(context, const ChatbotScreen()),
            icon: const Icon(Icons.smart_toy_outlined),
          ),
          IconButton(
            tooltip: strings.text('notifications'),
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
                  strings.text('welcome'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.text('tagline'),
                  style: const TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            strings.text('quick_access'),
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
              _QuickAccessCard(
                icon: Icons.menu_book_outlined,
                title: strings.text('discipleship'),
                onTap: () => _open(context, const CoursesScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.groups_2_outlined,
                title: strings.text('life_groups'),
                onTap: () => _open(context, const LifeGroupsScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.event_outlined,
                title: strings.text('events'),
                onTap: () => _open(context, const EventsScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.volunteer_activism_outlined,
                title: strings.text('prayer'),
                onTap: () => _open(context, const PrayerScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.work_outline,
                title: strings.text('opportunities'),
                onTap: () => _open(context, const OpportunitiesScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.public_outlined,
                title: strings.text('missions'),
                onTap: () => _open(
                  context,
                  const YouthHubsScreen(initialType: 'mission'),
                ),
              ),
              _QuickAccessCard(
                icon: Icons.auto_awesome_outlined,
                title: strings.text('talent_hub'),
                onTap: () => _open(
                  context,
                  const YouthHubsScreen(initialType: 'talent'),
                ),
              ),
              _QuickAccessCard(
                icon: Icons.storefront_outlined,
                title: strings.text('youth_businesses'),
                onTap: () => _open(
                  context,
                  const YouthHubsScreen(initialType: 'youth_business'),
                ),
              ),
              _QuickAccessCard(
                icon: Icons.folder_open_outlined,
                title: strings.text('media_resources'),
                onTap: () => _open(context, const MediaResourcesScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.location_on_outlined,
                title: strings.text('church_locator'),
                onTap: () => _open(context, const ChurchLocatorScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.handshake_outlined,
                title: strings.text('donate'),
                onTap: () => _open(context, const DonationCheckoutScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.smart_toy_outlined,
                title: strings.text('youth_assistant'),
                onTap: () => _open(context, const ChatbotScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.notifications_active_outlined,
                title: strings.text('notifications'),
                onTap: () => _open(context, const NotificationsScreen()),
              ),
              _QuickAccessCard(
                icon: Icons.shield_outlined,
                title: strings.text('safe_support'),
                onTap: () => _open(context, const SafetyCenterScreen()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.shield_outlined)),
              title: const Text('Safe and inclusive youth community'),
              subtitle: const Text(
                'Prayer, pastoral support, safeguarding and accessibility are built into the platform.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(context, const SafetyCenterScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
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
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
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
