import 'package:flutter/material.dart';

import '../models/annual_theme_content.dart';
import '../services/annual_theme_service.dart';

class AnnualThemeScreen extends StatefulWidget {
  const AnnualThemeScreen({super.key});

  @override
  State<AnnualThemeScreen> createState() => _AnnualThemeScreenState();
}

class _AnnualThemeScreenState extends State<AnnualThemeScreen> {
  final AnnualThemeService _service = AnnualThemeService();

  AnnualThemeContent? _content;
  bool _loading = true;
  bool _showingCached = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (!refresh) {
      final cached = await _service.readCached();
      if (mounted && cached != null) {
        setState(() {
          _content = cached;
          _showingCached = true;
          _loading = false;
        });
      }
    }

    if (mounted && _content == null) {
      setState(() => _loading = true);
    }

    try {
      final content = await _service.fetch(allowCachedFallback: false);
      if (!mounted) return;

      setState(() {
        _content = content;
        _showingCached = false;
        _error = null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = _content == null
            ? 'Annual Theme could not be loaded. Check your connection and try again.'
            : 'You are viewing the latest saved Annual Theme. Pull down to try synchronising again.';
        _loading = false;
        _showingCached = _content != null;
      });
    }
  }

  Color _parseColor(String value, Color fallback) {
    final clean = value.replaceFirst('#', '').trim();
    final hex = clean.length == 6 ? 'FF$clean' : clean;
    final parsed = int.tryParse(hex, radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final branding = content?.branding ?? const AnnualThemeBranding();
    final primary = _parseColor(
      branding.primaryColor,
      Theme.of(context).colorScheme.primary,
    );
    final secondary = _parseColor(
      branding.secondaryColor,
      const Color(0xFF204F78),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Annual Theme'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        child: _loading && content == null
            ? const ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 220),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : content == null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 100),
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 56,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error ?? 'Annual Theme is unavailable.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _load(refresh: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _BrandHeader(
                        branding: branding,
                        primary: primary,
                        secondary: secondary,
                      ),
                      if (_showingCached || _error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.offline_bolt_outlined, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _error ??
                                      'Saved content is available offline and will synchronise when you refresh online.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _InfoCard(
                        icon: Icons.flag_outlined,
                        title: 'Mission',
                        text: content.mission ??
                            'The mission statement has not been published yet.',
                        accent: primary,
                      ),
                      const SizedBox(height: 14),
                      _InfoCard(
                        icon: Icons.visibility_outlined,
                        title: 'Vision',
                        text: content.vision ??
                            'The vision statement has not been published yet.',
                        accent: secondary,
                      ),
                      const SizedBox(height: 20),
                      _ThemeCard(
                        theme: content.theme,
                        primary: primary,
                        secondary: secondary,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.branding,
    required this.primary,
    required this.secondary,
  });

  final AnnualThemeBranding branding;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: [primary, secondary]),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: branding.logoUrl != null
                ? Image.network(
                    branding.logoUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.church_outlined,
                      color: primary,
                      size: 34,
                    ),
                  )
                : Icon(Icons.church_outlined, color: primary, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branding.shortName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  branding.tagline,
                  style: const TextStyle(color: Colors.white, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: accent.withValues(alpha: .12),
              foregroundColor: accent,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(text, style: const TextStyle(height: 1.55)),
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
  const _ThemeCard({
    required this.theme,
    required this.primary,
    required this.secondary,
  });

  final AnnualThemeData? theme;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    if (theme == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Icon(Icons.auto_stories_outlined, size: 42, color: primary),
              const SizedBox(height: 12),
              Text(
                'Annual Theme',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The current annual theme has not been published yet.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (theme!.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 8,
              child: Image.network(
                theme!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: primary.withValues(alpha: .08),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.auto_stories_outlined,
                    size: 48,
                    color: primary,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        theme!.year?.toString() ?? 'Annual Theme',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  theme!.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: secondary,
                      ),
                ),
                if (theme!.scriptureReference != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 19, color: primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          theme!.scriptureReference!,
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (theme!.description != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    theme!.description!,
                    style: const TextStyle(height: 1.6),
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
