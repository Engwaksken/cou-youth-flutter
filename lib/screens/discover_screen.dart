import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.campaign_outlined, 'News & Announcements', 'Church and youth ministry updates'),
      (Icons.work_outline, 'Opportunities', 'Jobs, scholarships, training and volunteering'),
      (Icons.music_note_outlined, 'Talent Hub', 'Music, arts, sports, media and technology'),
      (Icons.photo_library_outlined, 'Media & Resources', 'Videos, audio, documents and ministry resources'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(item.$1)),
              title: Text(item.$2),
              subtitle: Text(item.$3),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
