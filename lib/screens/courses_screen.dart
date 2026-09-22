import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/localization/module_strings.dart';
import '../core/theme/app_colors.dart';
import '../services/course_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

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
    final title = ModuleStrings.text(context, 'courses');

    return YouthScreenScaffold(
      title: title,
      subtitle: 'Grow in faith through youth discipleship and learning.',
      leading: widget.onOpenDrawer == null
          ? null
          : IconButton(
              tooltip: 'Open menu',
              onPressed: widget.onOpenDrawer,
              icon: const Icon(Icons.menu_rounded),
            ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _courses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const YouthLoading(label: 'Loading courses…');
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .55,
                    child: YouthErrorState(
                      title: ModuleStrings.text(context, 'courses_load_failed'),
                      onRetry: _refresh,
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
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .55,
                    child: YouthEmptyState(
                      icon: Icons.menu_book_outlined,
                      title: ModuleStrings.text(context, 'no_courses'),
                      message: 'Published discipleship courses will appear here.',
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = courses[index];
                final courseTitle = (course['title'] ??
                        ModuleStrings.text(context, 'discipleship_course'))
                    .toString();
                final description = (course['description'] ?? '').toString().trim();
                final age = (course['age_category'] ?? 'all')
                    .toString()
                    .replaceAll('_', ' ');
                final audience = age == 'all'
                    ? ModuleStrings.text(context, 'for_all_ages')
                    : ModuleStrings.text(context, 'for_age').replaceFirst('{age}', age);

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.menu_book_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  courseTitle,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  audience,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 9),
                                  Text(
                                    description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
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
