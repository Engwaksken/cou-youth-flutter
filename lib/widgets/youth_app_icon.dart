import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class YouthAppIcon extends StatelessWidget {
  const YouthAppIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compact = textScale > 1.35;
    final iconExtent = compact ? 48.0 : 52.0;
    final iconSize = compact ? 24.0 : 26.0;

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  width: iconExtent,
                  height: iconExtent,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primaryLight,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(icon, size: iconSize, color: AppColors.primary),
                ),
                const SizedBox(height: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

int youthShortcutColumnCount(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  if (width < 360 || textScale > 1.25) return 3;
  return 4;
}

double youthShortcutTileHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  return (108 + ((textScale - 1).clamp(0, 2) * 44)).clamp(108, 190).toDouble();
}

SliverGridDelegateWithFixedCrossAxisCount youthShortcutGridDelegate(
  BuildContext context, {
  double mainAxisSpacing = 8,
  double crossAxisSpacing = 6,
}) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: youthShortcutColumnCount(context),
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    mainAxisExtent: youthShortcutTileHeight(context),
  );
}
