import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/localization/module_strings.dart';
import '../services/course_service.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late final CourseService _service;
  late Future<List<Map<String, dynamic>>> _courses;

  @override
  void initState() {
    super.initState();
    _service = CourseService(ApiConfig.client);
    _courses = _service.list();
  }

  Future<void> _refresh() async {
    final future = _service.list();
    setState(() => _courses = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ModuleStrings.text(context, 'courses')),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _courses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        ModuleStrings.text(context, 'courses_load_failed'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            final courses = snapshot.data ?? const <Map<String, dynamic>>[];

            if (courses.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(ModuleStrings.text(context, 'no_courses')),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = courses[index];
                final title = (course['title'] ??
                        ModuleStrings.text(context, 'discipleship_course'))
                    .toString();
                final description = (course['description'] ?? '').toString().trim();
                final age = (course['age_category'] ?? 'all')
                    .toString()
                    .replaceAll('_', ' ');
                final audience = age == 'all'
                    ? ModuleStrings.text(context, 'for_all_ages')
                    : ModuleStrings.text(context, 'for_age')
                        .replaceFirst('{age}', age);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              child: Icon(Icons.menu_book_outlined),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    audience,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(description),
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
    );
  }
}
