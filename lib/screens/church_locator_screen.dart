import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/theme/app_colors.dart';
import '../services/church_locator_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

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
    FocusScope.of(context).unfocus();
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
    return YouthScreenScaffold(
      title: 'Church Locator',
      subtitle: 'Find Church of Uganda congregations and youth fellowship information.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search church, parish, diocese or location',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: _searchController.text.isEmpty ? 'Search' : 'Clear',
                  onPressed: () {
                    if (_searchController.text.isEmpty) {
                      _search();
                    } else {
                      _searchController.clear();
                      _search();
                    }
                  },
                  icon: Icon(
                    _searchController.text.isEmpty
                        ? Icons.arrow_forward_rounded
                        : Icons.close_rounded,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _results,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const YouthLoading(label: 'Loading church locations…');
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * .55,
                          child: YouthErrorState(
                            title: 'Church locations could not be loaded',
                            onRetry: _refresh,
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
                        SizedBox(
                          height: 420,
                          child: YouthEmptyState(
                            icon: Icons.church_outlined,
                            title: 'No church locations found',
                            message: 'Try another church name, parish, diocese or location.',
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
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
                                  Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Icon(
                                      Icons.church_outlined,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (address.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _InfoRow(
                                  icon: Icons.location_on_outlined,
                                  text: address,
                                ),
                              ],
                              if (serviceTimes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.schedule_rounded,
                                  text: 'Services: $serviceTimes',
                                ),
                              ],
                              if (youthTimes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.groups_outlined,
                                  text: 'Youth fellowship: $youthTimes',
                                ),
                              ],
                              if (phone.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.phone_outlined,
                                  text: phone,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
