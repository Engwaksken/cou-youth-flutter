import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/theme/app_colors.dart';
import '../services/course_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.initialCourse,
  });

  final int courseId;
  final Map<String, dynamic>? initialCourse;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final CourseService _service;
  late Future<Map<String, dynamic>> _future;
  bool _enrolling = false;

  bool get _signedIn =>
      ApiConfig.client.authToken != null &&
      ApiConfig.client.authToken!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _service = CourseService(ApiConfig.client);
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final response = await _service.show(widget.courseId);
    if (response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    return response;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _enrol() async {
    if (!_signedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to enrol in this course.')),
      );
      return;
    }
    if (_enrolling) return;
    setState(() => _enrolling = true);
    try {
      final response = await _service.enrol(widget.courseId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response['message'] ?? 'You are enrolled in this course.'}')),
      );
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  String _plain(dynamic value) => '${value ?? ''}'
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .trim();

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'Course details',
      subtitle: 'Learn, grow and track your discipleship journey.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          initialData: widget.initialCourse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
              return const YouthLoading(label: 'Loading course…');
            }
            if (snapshot.hasError && snapshot.data == null) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'This course could not be loaded.';
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .6,
                    child: YouthErrorState(message: message, onRetry: _refresh),
                  ),
                ],
              );
            }

            final course = snapshot.data ?? widget.initialCourse ?? <String, dynamic>{};
            final title = '${course['title'] ?? 'Discipleship course'}';
            final description = _plain(course['description']);
            final age = '${course['age_category'] ?? 'all'}'.replaceAll('_', ' ');
            final lessonsRaw = course['lessons'];
            final lessons = lessonsRaw is List
                ? lessonsRaw.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
                : <Map<String, dynamic>>[];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          avatar: const Icon(Icons.people_outline, size: 16),
                          label: Text(age == 'all' ? 'All ages' : age),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: const TextStyle(color: AppColors.textSecondary, height: 1.55),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _enrolling ? null : _enrol,
                            icon: _enrolling
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.school_outlined),
                            label: Text(_enrolling ? 'Enrolling...' : 'Enrol in course'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (lessons.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Text(
                    'Lessons',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  for (var index = 0; index < lessons.length; index++) ...[
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.primary,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          '${lessons[index]['title'] ?? 'Lesson ${index + 1}'}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: _plain(lessons[index]['description']).isEmpty
                            ? null
                            : Text(
                                _plain(lessons[index]['description']),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ),
                    if (index != lessons.length - 1) const SizedBox(height: 8),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
