import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/quiz_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.quizId,
    required this.service,
  });

  final int quizId;
  final QuizService service;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  dynamic data;
  String? error;
  bool loading = true;
  bool submitting = false;
  final Map<String, dynamic> answers = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final value = await widget.service.show(widget.quizId);
      if (!mounted) return;
      setState(() {
        data = value;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (submitting) return;
    setState(() => submitting = true);

    try {
      final value = await widget.service.submit(widget.quizId, answers);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${value['message'] ?? 'Quiz submitted.'}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The quiz could not be submitted. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = '${data?['quiz']?['title'] ?? 'Quiz'}';

    return YouthScreenScaffold(
      title: title,
      subtitle: 'Complete the questions and submit your answers when ready.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (loading) {
      return const YouthLoading(label: 'Loading quiz…');
    }

    if (error != null) {
      return YouthErrorState(
        title: 'Quiz could not be loaded',
        message: 'Please check your connection and try again.',
        onRetry: _load,
      );
    }

    final questions = data?['quiz']?['questions'] as List? ?? const [];

    if (questions.isEmpty) {
      return const YouthEmptyState(
        icon: Icons.quiz_outlined,
        title: 'No quiz questions yet',
        message: 'Questions will appear here when they are available.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.quiz_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${questions.length} ${questions.length == 1 ? 'question' : 'questions'}',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < questions.length; index++) ...[
          _QuestionCard(
            number: index + 1,
            question: questions[index],
            selected: answers['${questions[index]['id']}']?.toString(),
            onChanged: (value) {
              setState(() {
                answers['${questions[index]['id']}'] = value;
              });
            },
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 6),
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            onPressed: submitting ? null : _submit,
            icon: submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(submitting ? 'Submitting…' : 'Submit quiz'),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.selected,
    required this.onChanged,
  });

  final int number;
  final dynamic question;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = question['options'] as List? ?? const [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${question['question'] ?? ''}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RadioGroup<String>(
              groupValue: selected,
              onChanged: onChanged,
              child: Column(
                children: [
                  for (final option in options)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: option.toString(),
                      title: Text(
                        option.toString(),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
