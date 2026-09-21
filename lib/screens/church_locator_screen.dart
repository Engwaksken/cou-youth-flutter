import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../services/church_locator_service.dart';

class ChurchLocatorScreen extends StatefulWidget {
  const ChurchLocatorScreen({super.key});

  @override
  State<ChurchLocatorScreen> createState() => _ChurchLocatorScreenState();
}

class _ChurchLocatorScreenState extends State<ChurchLocatorScreen> {
  late final ChurchLocatorService _service;
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _results;

  @override
  void initState() {
    super.initState();
    _service = ChurchLocatorService(ApiConfig.client);
    _results = _service.search('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _results = _service.search(_searchController.text);
    });
  }

  Future<void> _refresh() async {
    final future = _service.search(_searchController.text);
    setState(() => _results = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Church Locator')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search church, parish, diocese or location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: _search,
                  icon: const Icon(Icons.arrow_forward),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _results,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Church locations could not be loaded. Pull down to try again.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final items = snapshot.data ?? const <Map<String, dynamic>>[];

                  if (items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No church locations found.')),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final church = items[index];
                      final name =
                          (church['name'] ??
                                  church['organisation_unit']?['name'] ??
                                  'Church of Uganda')
                              .toString();
                      final address =
                          (church['address'] ??
                                  church['organisation_unit']?['address'] ??
                                  '')
                              .toString()
                              .trim();
                      final phone =
                          (church['contact_phone'] ??
                                  church['organisation_unit']?['phone'] ??
                                  '')
                              .toString()
                              .trim();
                      final serviceTimes = (church['service_times'] ?? '')
                          .toString()
                          .trim();
                      final youthTimes =
                          (church['youth_fellowship_times'] ?? '')
                              .toString()
                              .trim();

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    child: Icon(Icons.church_outlined),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (address.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(address),
                              ],
                              if (serviceTimes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.schedule, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Services: $serviceTimes'),
                                    ),
                                  ],
                                ),
                              ],
                              if (youthTimes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.groups_outlined, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Youth fellowship: $youthTimes',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (phone.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(phone)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
