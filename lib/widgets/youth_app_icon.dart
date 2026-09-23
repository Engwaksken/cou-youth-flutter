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
    final iconExtent = compact ? 44.0 : 48.0;
    final iconSize = compact ? 22.0 : 24.0;

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .035),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
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
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.primaryLight,
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
                          fontSize: compact ? 10.5 : 11.5,
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

  if (width < 390 || textScale > 1.18) return 3;
  return 4;
}

double youthShortcutTileHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  return (112 + ((textScale - 1).clamp(0, 2) * 50)).clamp(112, 196).toDouble();
}

SliverGridDelegateWithFixedCrossAxisCount youthShortcutGridDelegate(
  BuildContext context, {
  double mainAxisSpacing = 10,
  double crossAxisSpacing = 10,
}) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: youthShortcutColumnCount(context),
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    mainAxisExtent: youthShortcutTileHeight(context),
  );
}
