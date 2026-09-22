import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../services/prayer_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final PrayerService _service = PrayerService();
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  String _visibility = 'private';
  bool _submitting = false;
  late Future<List<Map<String, dynamic>>> _requests;

  @override
  void initState() {
    super.initState();
    _requests = _service.mine();
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _requests = _service.mine());
    await _requests;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final response = await _service.submit(
        subject: _subject.text,
        message: _message.text,
        visibility: _visibility,
      );

      if (!mounted) return;

      _subject.clear();
      _message.clear();

      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? strings.text('prayer_submitted'),
          ),
        ),
      );

      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _visibilityLabel(AppStrings strings, String visibility) {
    return switch (visibility) {
      'pastoral_team' => strings.text('pastoral_team'),
      'public_anonymous' => strings.text('public_anonymous'),
      _ => strings.text('private'),
    };
  }

  void _openForm() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final strings = AppStrings.of(context);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.volunteer_activism_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              strings.text('submit_prayer_request'),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _subject,
                        decoration: InputDecoration(
                          labelText: strings.text('subject'),
                          prefixIcon: const Icon(Icons.title_rounded),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? strings.text('enter_subject')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _message,
                        minLines: 5,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: strings.text('prayer_request_label'),
                          alignLabelWithHint: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 92),
                            child: Icon(Icons.edit_note_rounded),
                          ),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? strings.text('enter_prayer_request')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _visibility,
                        decoration: InputDecoration(
                          labelText: strings.text('who_can_see'),
                          prefixIcon: const Icon(Icons.visibility_outlined),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'private',
                            child: Text(strings.text('private')),
                          ),
                          DropdownMenuItem(
                            value: 'pastoral_team',
                            child: Text(strings.text('pastoral_team')),
                          ),
                          DropdownMenuItem(
                            value: 'public_anonymous',
                            child: Text(strings.text('public_anonymous')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => _visibility = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          strings.text('prayer_safeguarding_note'),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _submitting
                            ? null
                            : () async {
                                await _submit();
                                if (mounted && !_submitting) {
                                  Navigator.of(context).pop();
                                }
                              },
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_outlined),
                        label: Text(
                          _submitting
                              ? strings.text('submitting')
                              : strings.text('submit_request'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return YouthScreenScaffold(
      title: strings.text('prayer_support'),
      subtitle: 'Share a prayer request privately or with pastoral support.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add_rounded),
        label: Text(strings.text('prayer_request')),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _requests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const YouthLoading(label: 'Loading prayer requests…');
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .55,
                    child: YouthErrorState(
                      title: strings.text('prayer_load_failed'),
                      onRetry: _refresh,
                    ),
                  ),
                ],
              );
            }

            final requests = snapshot.data ?? const [];

            if (requests.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .55,
                    child: YouthEmptyState(
                      icon: Icons.volunteer_activism_outlined,
                      title: strings.text('no_prayer_requests'),
                      message: 'Your prayer requests will appear here after you submit them.',
                      actionLabel: strings.text('prayer_request'),
                      onAction: _openForm,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
              itemCount: requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];
                final visibility = request['visibility']?.toString() ?? 'private';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.volunteer_activism_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['subject']?.toString() ??
                                    strings.text('prayer_request'),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                request['message']?.toString() ?? '',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Chip(
                                label: Text(_visibilityLabel(strings, visibility)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
