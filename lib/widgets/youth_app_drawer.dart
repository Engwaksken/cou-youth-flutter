import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../screens/accessibility_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/church_locator_screen.dart';
import '../screens/donation_checkout_screen.dart';
import '../screens/life_groups_screen.dart';
import '../screens/media_resources_screen.dart';
import '../screens/notifications_screen.dart';
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
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: AppColors.primary,
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    child: Icon(Icons.church_outlined, size: 28),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COU Youth',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Faith • Community • Opportunity',
                          style: TextStyle(
                            color: Color(0xFFE7DFF5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const _SectionLabel('Main'),
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
                  const _SectionLabel('Faith'),
                  _DrawerItem(
                    icon: Icons.menu_book_outlined,
                    label: 'Discipleship',
                    selected: currentIndex == 2,
                    onTap: () => _selectMain(context, 2),
                  ),
                  _DrawerItem(
                    icon: Icons.groups_2_outlined,
                    label: 'Life Groups',
                    onTap: () => _open(context, const LifeGroupsScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.volunteer_activism_outlined,
                    label: 'Prayer & Support',
                    onTap: () => _open(context, const PrayerScreen()),
                  ),
                  const _SectionLabel('Community'),
                  _DrawerItem(
                    icon: Icons.event_outlined,
                    label: 'Events',
                    selected: currentIndex == 3,
                    onTap: () => _selectMain(context, 3),
                  ),
                  _DrawerItem(
                    icon: Icons.location_on_outlined,
                    label: 'Church Locator',
                    onTap: () => _open(context, const ChurchLocatorScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.folder_open_outlined,
                    label: 'Media & Resources',
                    onTap: () => _open(context, const MediaResourcesScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.work_outline,
                    label: 'Opportunities',
                    onTap: () => _open(context, const OpportunitiesScreen()),
                  ),
                  const _SectionLabel('Support'),
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
                  _DrawerItem(
                    icon: Icons.shield_outlined,
                    label: 'Safety Centre',
                    onTap: () => _open(context, const SafetyCenterScreen()),
                  ),
                  const _SectionLabel('Account'),
                  _DrawerItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    onTap: () => _open(context, const NotificationsScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    selected: currentIndex == 4,
                    onTap: () => _selectMain(context, 4),
                  ),
                  _DrawerItem(
                    icon: Icons.accessibility_new_outlined,
                    label: 'Accessibility',
                    onTap: () => _open(context, const AccessibilityScreen()),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        child: ListTile(
          selected: selected,
          selectedTileColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Icon(
            icon,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
