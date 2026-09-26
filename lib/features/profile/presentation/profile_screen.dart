import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.person_outline),
          title: Text('My Profile'),
        ),
        ListTile(
          leading: Icon(Icons.groups_outlined),
          title: Text('My Groups'),
        ),
        ListTile(
          leading: Icon(Icons.school_outlined),
          title: Text('My Courses'),
        ),
        ListTile(
          leading: Icon(Icons.event_available_outlined),
          title: Text('My Events'),
        ),
        ListTile(
          leading: Icon(Icons.workspace_premium_outlined),
          title: Text('My Certificates'),
        ),
        ListTile(
          leading: Icon(Icons.accessibility_new),
          title: Text('Accessibility'),
        ),
        ListTile(
          leading: Icon(Icons.settings_outlined),
          title: Text('Settings'),
        ),
      ],
    ),
  );
}
