import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class YouthScreenScaffold extends StatelessWidget {
  const YouthScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.showHeader = true,
    this.useSafeArea = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final bool showHeader;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: _Header(
              title: title,
              subtitle: subtitle,
              leading: leading,
              actions: actions,
            ),
          ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: child,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: useSafeArea ? SafeArea(child: content) : content,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: const IconThemeData(color: Colors.white),
            child: leading!,
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .82),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (actions != null) ...[
          const SizedBox(width: 8),
          ...actions!,
        ],
      ],
    );
  }
}
