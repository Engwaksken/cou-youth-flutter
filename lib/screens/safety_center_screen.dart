import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/localization/module_strings.dart';
import '../core/theme/app_colors.dart';
import '../services/moderation_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  final ModerationService _service = ModerationService();
  final _formKey = GlobalKey<FormState>();
  final _reportableId = TextEditingController();
  final _reason = TextEditingController();
  final _details = TextEditingController();

  String _type = 'content';
  bool _busy = false;
  String? _message;
  String? _error;
  late Future<List<Map<String, dynamic>>> _blockedFuture;

  bool get _signedIn =>
      ApiConfig.client.authToken != null &&
      ApiConfig.client.authToken!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _blockedFuture = _signedIn
        ? _service.blocked()
        : Future.value(const <Map<String, dynamic>>[]);
  }

  @override
  void dispose() {
    _reportableId.dispose();
    _reason.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_signedIn) {
      setState(() => _error = ModuleStrings.text(context, 'sign_in_report'));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final id = int.tryParse(_reportableId.text.trim());
    if (id == null || id < 1) return;

    setState(() {
      _busy = true;
      _message = null;
      _error = null;
    });

    try {
      final response = await _service.report(
        type: _type,
        id: id,
        reason: _reason.text,
        details: _details.text,
      );
      if (!mounted) return;
      setState(() {
        _message =
            '${response['message'] ?? ModuleStrings.text(context, 'report_submitted')}';
        _reportableId.clear();
        _reason.clear();
        _details.clear();
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = ModuleStrings.text(context, 'report_failed'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unblock(int userId) async {
    try {
      final response = await _service.unblock(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${response['message'] ?? ModuleStrings.text(context, 'user_unblocked')}',
          ),
        ),
      );
      setState(() => _blockedFuture = _service.blocked());
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  String _labelForType(String value) {
    return switch (value) {
      'content' => ModuleStrings.text(context, 'content'),
      'user' => ModuleStrings.text(context, 'user'),
      'life_group' => ModuleStrings.text(context, 'life_group'),
      'media_asset' => ModuleStrings.text(context, 'media_resource'),
      'prayer_request' => ModuleStrings.text(context, 'prayer_request'),
      _ => value,
    };
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: ModuleStrings.text(context, 'safety_center'),
      subtitle: 'Report concerns and manage your personal safety settings.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
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
                          Icons.shield_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ModuleStrings.text(context, 'report_safety_concern'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ModuleStrings.text(context, 'safety_intro'),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_message != null) ...[
                    _StatusBox(message: _message!, success: true),
                    const SizedBox(height: 12),
                  ],
                  if (_error != null) ...[
                    _StatusBox(message: _error!, success: false),
                    const SizedBox(height: 12),
                  ],
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _type,
                          decoration: InputDecoration(
                            labelText: ModuleStrings.text(
                              context,
                              'reporting_what',
                            ),
                            prefixIcon: const Icon(Icons.flag_outlined),
                          ),
                          items: [
                            for (final value in const [
                              'content',
                              'user',
                              'life_group',
                              'media_asset',
                              'prayer_request',
                            ])
                              DropdownMenuItem(
                                value: value,
                                child: Text(_labelForType(value)),
                              ),
                          ],
                          onChanged: _busy
                              ? null
                              : (value) =>
                                    setState(() => _type = value ?? 'content'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reportableId,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: ModuleStrings.text(
                              context,
                              'item_user_id',
                            ),
                            helperText: ModuleStrings.text(
                              context,
                              'item_user_id_help',
                            ),
                            prefixIcon: const Icon(Icons.tag_rounded),
                          ),
                          validator: (value) {
                            final id = int.tryParse((value ?? '').trim());
                            if (id == null || id < 1) {
                              return ModuleStrings.text(context, 'valid_id');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reason,
                          maxLength: 120,
                          decoration: InputDecoration(
                            labelText: ModuleStrings.text(context, 'reason'),
                            prefixIcon: const Icon(Icons.warning_amber_rounded),
                          ),
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? ModuleStrings.text(
                                  context,
                                  'report_reason_required',
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _details,
                          minLines: 3,
                          maxLines: 6,
                          maxLength: 3000,
                          decoration: InputDecoration(
                            labelText: ModuleStrings.text(
                              context,
                              'additional_details',
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _busy ? null : _submit,
                            icon: _busy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.report_outlined),
                            label: Text(
                              _busy
                                  ? ModuleStrings.text(context, 'submitting')
                                  : ModuleStrings.text(
                                      context,
                                      'submit_report',
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            ModuleStrings.text(context, 'blocked_accounts'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          if (!_signedIn)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  ModuleStrings.text(context, 'sign_in_blocked'),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _blockedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 180,
                    child: YouthLoading(label: 'Loading blocked accounts…'),
                  );
                }
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 220,
                    child: YouthErrorState(
                      title: ModuleStrings.text(
                        context,
                        'blocked_load_failed',
                      ),
                    ),
                  );
                }
                final rows = snapshot.data ?? const <Map<String, dynamic>>[];
                if (rows.isEmpty) {
                  return SizedBox(
                    height: 220,
                    child: YouthEmptyState(
                      icon: Icons.person_off_outlined,
                      title: ModuleStrings.text(
                        context,
                        'no_blocked_accounts',
                      ),
                      message: 'People you block will appear here for review.',
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final row in rows) ...[
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.primary,
                            child: Icon(Icons.person_off_outlined),
                          ),
                          title: Text(
                            '${row['blocked'] is Map ? (row['blocked'] as Map)['name'] ?? ModuleStrings.text(context, 'blocked_user') : ModuleStrings.text(context, 'blocked_user')}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: row['reason'] == null
                              ? null
                              : Text(
                                  '${row['reason']}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                          trailing: TextButton(
                            onPressed: () {
                              final blocked = row['blocked'];
                              final id = blocked is Map
                                  ? int.tryParse('${blocked['id'] ?? ''}')
                                  : int.tryParse('${row['blocked_id'] ?? ''}');
                              if (id != null) _unblock(id);
                            },
                            child: Text(ModuleStrings.text(context, 'unblock')),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success
            ? const Color(0xFFEAF7EE)
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success ? AppColors.success : Theme.of(context).colorScheme.error,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: success
              ? AppColors.success
              : Theme.of(context).colorScheme.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
