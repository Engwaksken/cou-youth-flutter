import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quizId, required this.service});
  final int quizId;
  final QuizService service;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  dynamic data;
  String? error;
  bool loading = true;
  final Map<String, dynamic> answers = {};
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final v = await widget.service.show(widget.quizId);
      if (mounted)
        setState(() {
          data = v;
          loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          error = e.toString();
          loading = false;
        });
    }
  }

  Future<void> _submit() async {
    try {
      final v = await widget.service.submit(widget.quizId, answers);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(v['message'] ?? 'Quiz submitted.')),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null)
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(child: Text(error!)),
      );
    final questions = (data?['quiz']?['questions'] as List? ?? const []);
    return Scaffold(
      appBar: AppBar(title: Text(data?['quiz']?['title'] ?? 'Quiz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final q in questions) ...[
            Text(
              q['question'] ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: answers[q['id'].toString()]?.toString(),
              onChanged: (v) => setState(() => answers[q['id'].toString()] = v),
              child: Column(
                children: [
                  for (final o in (q['options'] as List? ?? const []))
                    RadioListTile<String>(
                      value: o.toString(),
                      title: Text(o.toString()),
                    ),
                ],
              ),
            ),
            const Divider(),
          ],
          FilledButton(onPressed: _submit, child: const Text('Submit quiz')),
        ],
      ),
    );
  }
}
