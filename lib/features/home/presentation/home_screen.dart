import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Church of Uganda Youth')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Connecting Young People. Growing Disciples. Transforming Nations.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          const _Tile(
            icon: Icons.menu_book,
            title: "Today's Word",
            subtitle: 'Daily Bible verse and devotion',
          ),
          const _Tile(
            icon: Icons.event,
            title: 'Upcoming Events',
            subtitle: 'Provincial, diocesan and local events',
          ),
          const _Tile(
            icon: Icons.school,
            title: 'Discipleship',
            subtitle: 'Courses, Bible studies and resources',
          ),
          const _Tile(
            icon: Icons.volunteer_activism,
            title: 'Donate',
            subtitle: 'Support approved youth ministry causes',
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
