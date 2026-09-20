import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/certificate_service.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key, CertificateService? service})
      : _service = service;

  final CertificateService? _service;

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  late final CertificateService _service;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _service = widget._service ?? CertificateService();
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
                  Text(
                    courseTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Certificate number',
                    value: '${certificate['certificate_number'] ?? '—'}',
                  ),
                  _DetailRow(
                    label: 'Issued',
                    value: '${certificate['issued_at'] ?? certificate['created_at'] ?? '—'}',
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Certificates')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Certificates could not be loaded. Pull down to try again.';

              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 42),
                        const SizedBox(height: 12),
                        Text(message, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              );
            }

            final items = snapshot.data ?? const <Map<String, dynamic>>[];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.workspace_premium_outlined, size: 48),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Completed course certificates will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final course = item['course'];
                final title = course is Map
                    ? '${course['title'] ?? course['name'] ?? 'Course certificate'}'
                    : 'Course certificate';

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.workspace_premium_outlined),
                    ),
                    title: Text(title),
                    subtitle: Text(
                      '${item['certificate_number'] ?? 'Certificate'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
