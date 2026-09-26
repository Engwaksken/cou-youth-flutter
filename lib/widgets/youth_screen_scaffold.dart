import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/connectivity_service.dart';

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
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: _Header(
              title: title,
              subtitle: subtitle,
              leading: leading,
              actions: actions,
            ),
          ),
        const _OfflineBanner(),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.transparent),
            child: child,
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: useSafeArea ? SafeArea(child: content) : content,
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.instance.statusChanges.handleError((_) {}),
      initialData: true,
      builder: (context, snapshot) {
        if (snapshot.data != false) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          color: const Color(0xFFFFF3CD),
          child: const Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 18,
                color: Color(0xFF7A5200),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Offline mode — cached information remains available. Connect to mobile data or Wi-Fi to sync updates and use online actions.',
                  style: TextStyle(
                    color: Color(0xFF654600),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          const SizedBox(width: 8),
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
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFEDE7F6),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (actions != null) ...[
          const SizedBox(width: 6),
          ...actions!,
        ],
      ],
    );
  }
}
