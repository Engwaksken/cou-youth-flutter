import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_colors.dart';
import '../models/annual_theme_content.dart';
import '../services/annual_theme_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class AnnualThemeScreen extends StatefulWidget {
  const AnnualThemeScreen({super.key});

  @override
  State<AnnualThemeScreen> createState() => _AnnualThemeScreenState();
}

class _AnnualThemeScreenState extends State<AnnualThemeScreen> {
  final AnnualThemeService _service = AnnualThemeService();
  late Future<AnnualThemeContent> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetch();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.fetch(allowCachedFallback: true));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'Annual Theme',
      subtitle: 'Mission • Vision • Annual Theme',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<AnnualThemeContent>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 260),
                  YouthLoading(label: 'Loading annual theme…'),
                ],
              );
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Annual theme could not be loaded.';
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 120),
                  YouthErrorState(message: message, onRetry: _refresh),
                ],
              );
            }

            final content = snapshot.data;
            if (content == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  YouthEmptyState(
                    icon: Icons.auto_stories_outlined,
                    title: 'Annual Theme',
                    message: 'Annual theme information has not been published yet.',
                  ),
                ],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                _InfoCard(
                  icon: Icons.flag_outlined,
                  title: 'Mission',
                  text: content.mission ?? 'Mission has not been published yet.',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.visibility_outlined,
                  title: 'Vision',
                  text: content.vision ?? 'Vision has not been published yet.',
                ),
                const SizedBox(height: 18),
                _ThemeCard(theme: content.theme),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
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

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.theme});

  final AnnualThemeData? theme;

  @override
  Widget build(BuildContext context) {
    if (theme == null) {
      return const YouthEmptyState(
        icon: Icons.auto_stories_outlined,
        title: 'Annual Theme',
        message: 'The current annual theme has not been published yet.',
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (theme!.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 8,
              child: Image.network(
                theme!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primaryLight,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_stories_outlined,
                    color: AppColors.primary,
                    size: 46,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (theme!.year != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${theme!.year}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  theme!.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (theme!.scriptureReference != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          theme!.scriptureReference!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (theme!.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    theme!.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
