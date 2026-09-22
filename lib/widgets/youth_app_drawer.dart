import 'package:flutter/material.dart';

import '../screens/accessibility_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/church_locator_screen.dart';
import '../screens/donation_checkout_screen.dart';
import '../screens/life_groups_screen.dart';
import '../screens/media_resources_screen.dart';
import '../screens/opportunities_screen.dart';
import '../screens/prayer_screen.dart';
import '../screens/safety_center_screen.dart';

class YouthAppDrawer extends StatelessWidget {
  const YouthAppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectMainTab,
  });

  final int currentIndex;
  final ValueChanged<int> onSelectMainTab;

  void _selectMain(BuildContext context, int index) {
    Navigator.of(context).pop();
    onSelectMainTab(index);
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

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.secondary],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.church_outlined, color: Colors.white, size: 38),
                  SizedBox(height: 12),
                  Text(
                    'COU Youth Platform',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    selected: currentIndex == 0,
                    onTap: () => _selectMain(context, 0),
                  ),
                  _DrawerItem(
                    icon: Icons.explore_outlined,
                    label: 'Discover',
                    selected: currentIndex == 1,
                    onTap: () => _selectMain(context, 1),
                  ),
                  _DrawerItem(
                    icon: Icons.menu_book_outlined,
                    label: 'Discipleship',
                    selected: currentIndex == 2,
                    onTap: () => _selectMain(context, 2),
                  ),
                  _DrawerItem(
                    icon: Icons.event_outlined,
                    label: 'Events',
                    selected: currentIndex == 3,
                    onTap: () => _selectMain(context, 3),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    selected: currentIndex == 4,
                    onTap: () => _selectMain(context, 4),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Text(
                      'Youth services',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.groups_2_outlined,
                    label: 'Life Groups',
                    onTap: () => _open(context, const LifeGroupsScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.location_on_outlined,
                    label: 'Church Locator',
                    onTap: () => _open(context, const ChurchLocatorScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.work_outline,
                    label: 'Opportunities',
                    onTap: () => _open(context, const OpportunitiesScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.folder_open_outlined,
                    label: 'Media & Resources',
                    onTap: () => _open(context, const MediaResourcesScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.volunteer_activism_outlined,
                    label: 'Prayer & Support',
                    onTap: () => _open(context, const PrayerScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.handshake_outlined,
                    label: 'Donate',
                    onTap: () => _open(context, const DonationCheckoutScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.smart_toy_outlined,
                    label: 'Youth Assistant',
                    onTap: () => _open(context, const ChatbotScreen()),
                  ),
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.accessibility_new_outlined,
                    label: 'Accessibility',
                    onTap: () => _open(context, const AccessibilityScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.shield_outlined,
                    label: 'Safety Centre',
                    onTap: () => _open(context, const SafetyCenterScreen()),
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

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ListTile(
        selected: selected,
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
