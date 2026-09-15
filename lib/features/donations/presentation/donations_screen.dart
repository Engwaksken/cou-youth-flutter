import 'package:flutter/material.dart';
import '../data/donation_service.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key, required this.service});
  final DonationService service;

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() { super.initState(); _future = widget.service.campaigns(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donations')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('We could not load donation campaigns. Please try again.'));
          final items = snapshot.data ?? const [];
          if (items.isEmpty) return const Center(child: Text('No donation campaigns are available right now.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16), itemCount: items.length,
            itemBuilder: (_, i) {
              final c = Map<String, dynamic>.from(items[i]);
              return Card(child: ListTile(
                title: Text(c['title']?.toString() ?? 'Donation campaign'),
                subtitle: Text(c['description']?.toString() ?? ''),
                trailing: const Icon(Icons.volunteer_activism),
                onTap: () {}, // Wire to campaign detail + payment selection.
              ));
            },
          );
        },
      ),
    );
  }
}
