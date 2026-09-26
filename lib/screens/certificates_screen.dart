import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_colors.dart';
import '../services/certificate_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key, this.service});

  final CertificateService? service;

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  late final CertificateService _service;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? CertificateService();
    _future = _service.list();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.list());
    await _future;
  }

  Future<void> _showCertificate(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id is! int) return;

    try {
      final certificate = await _service.show(id);
      if (!mounted) return;

      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) {
          final course = certificate['course'];
          final courseTitle = course is Map
              ? '${course['title'] ?? course['name'] ?? 'Course'}'
              : 'Course';

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          Icons.workspace_premium_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          courseTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Certificate number',
                    value: '${certificate['certificate_number'] ?? '—'}',
                  ),
                  _DetailRow(
                    label: 'Issued',
                    value:
                        '${certificate['issued_at'] ?? certificate['created_at'] ?? '—'}',
                  ),
                  if (certificate['verification_code'] != null)
                    _DetailRow(
                      label: 'Verification code',
                      value: '${certificate['verification_code']}',
                    ),
                ],
              ),
            ),
          );
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'My Certificates',
      subtitle: 'View certificates earned through completed youth courses.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const YouthLoading(label: 'Loading certificates…');
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Certificates could not be loaded.';
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .55,
                    child: YouthErrorState(message: message, onRetry: _refresh),
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
                      icon: Icons.workspace_premium_outlined,
                      title: 'No certificates yet',
                      message: 'Completed course certificates will appear here.',
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final course = item['course'];
                final title = course is Map
                    ? '${course['title'] ?? course['name'] ?? 'Course certificate'}'
                    : 'Course certificate';

                return Card(
                  child: ListTile(
                    minVerticalPadding: 14,
                    leading: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${item['certificate_number'] ?? 'Certificate'}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _showCertificate(item),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
