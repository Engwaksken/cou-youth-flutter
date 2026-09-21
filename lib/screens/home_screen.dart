import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import '../widgets/youth_app_icon.dart';
import 'accessibility_screen.dart';
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
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final columns = youthShortcutColumnCount(context);

    final shortcuts = <Widget>[
      YouthAppIcon(
        icon: Icons.event_outlined,
        label: strings.text('events'),
        onTap: () => _open(context, const EventsScreen()),
      ),
      YouthAppIcon(
        icon: Icons.menu_book_outlined,
        label: strings.text('discipleship'),
        onTap: () => _open(context, const CoursesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.location_on_outlined,
        label: strings.text('church_locator'),
        onTap: () => _open(context, const ChurchLocatorScreen()),
      ),
      YouthAppIcon(
        icon: Icons.groups_2_outlined,
        label: strings.text('life_groups'),
        onTap: () => _open(context, const LifeGroupsScreen()),
      ),
      YouthAppIcon(
        icon: Icons.handshake_outlined,
        label: strings.text('donate'),
        onTap: () => _open(context, const DonationCheckoutScreen()),
      ),
      YouthAppIcon(
        icon: Icons.volunteer_activism_outlined,
        label: strings.text('prayer'),
        onTap: () => _open(context, const PrayerScreen()),
      ),
      YouthAppIcon(
        icon: Icons.smart_toy_outlined,
        label: strings.text('youth_assistant'),
        onTap: () => _open(context, const ChatbotScreen()),
      ),
      YouthAppIcon(
        icon: Icons.notifications_active_outlined,
        label: strings.text('notifications'),
        onTap: () => _open(context, const NotificationsScreen()),
      ),
      YouthAppIcon(
        icon: Icons.folder_open_outlined,
        label: strings.text('media_resources'),
        onTap: () => _open(context, const MediaResourcesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.work_outline,
        label: strings.text('opportunities'),
        onTap: () => _open(context, const OpportunitiesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.public_outlined,
        label: strings.text('missions'),
        onTap: () =>
            _open(context, const YouthHubsScreen(initialType: 'mission')),
      ),
      YouthAppIcon(
        icon: Icons.auto_awesome_outlined,
        label: strings.text('talent_hub'),
        onTap: () =>
            _open(context, const YouthHubsScreen(initialType: 'talent')),
      ),
      YouthAppIcon(
        icon: Icons.storefront_outlined,
        label: strings.text('youth_businesses'),
        onTap: () => _open(
          context,
          const YouthHubsScreen(initialType: 'youth_business'),
        ),
      ),
      YouthAppIcon(
        icon: Icons.accessibility_new_outlined,
        label: 'Accessibility',
        semanticLabel: 'Open accessibility settings',
        onTap: () => _open(context, const AccessibilityScreen()),
      ),
      YouthAppIcon(
        icon: Icons.shield_outlined,
        label: strings.text('safe_support'),
        onTap: () => _open(context, const SafetyCenterScreen()),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('COU Youth Platform'),
        actions: [
          IconButton(
            tooltip: 'Accessibility',
            onPressed: () => _open(context, const AccessibilityScreen()),
            icon: const Icon(Icons.accessibility_new_outlined),
          ),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Semantics(
            header: true,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4B2E83), Color(0xFF204F78)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.church_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.text('welcome'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.text('tagline'),
                    style: const TextStyle(color: Colors.white, height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.text('quick_access'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  columns == 4 ? '4 per row' : 'Accessible layout',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: youthShortcutGridDelegate(context),
            itemCount: shortcuts.length,
            itemBuilder: (context, index) => shortcuts[index],
          ),
          const SizedBox(height: 20),
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
