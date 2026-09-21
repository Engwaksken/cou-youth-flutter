import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Discover')),
    body: ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.campaign),
          title: Text('News & Announcements'),
        ),
        ListTile(
          leading: Icon(Icons.work_outline),
          title: Text('Opportunities'),
        ),
        ListTile(leading: Icon(Icons.church), title: Text('Church Locator')),
        ListTile(leading: Icon(Icons.groups), title: Text('Life Groups')),
        ListTile(
          leading: Icon(Icons.smart_toy_outlined),
          title: Text('Ask the Youth Assistant'),
        ),
      ],
    ),
  );
}
