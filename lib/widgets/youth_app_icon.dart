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
    final compact = textScale > 1.30;
    final iconExtent = compact ? 44.0 : 50.0;
    final iconSize = compact ? 22.0 : 25.0;

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: AppColors.borderStrong),
            ),
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
                  ),
                  child: Icon(icon, size: iconSize, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: compact ? 10.5 : 11.5,
                          fontWeight: FontWeight.w700,
                          height: 1.18,
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

  if (width < 390 || textScale > 1.18) return 3;
  return 4;
}

double youthShortcutTileHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  return (114 + ((textScale - 1).clamp(0, 2) * 50)).clamp(114, 198).toDouble();
}

SliverGridDelegateWithFixedCrossAxisCount youthShortcutGridDelegate(
  BuildContext context, {
  double mainAxisSpacing = 12,
  double crossAxisSpacing = 12,
}) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: youthShortcutColumnCount(context),
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    mainAxisExtent: youthShortcutTileHeight(context),
  );
}
