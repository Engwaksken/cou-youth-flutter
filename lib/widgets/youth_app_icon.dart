import 'package:flutter/material.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactIcon = textScale > 1.35;
    final iconExtent = compactIcon ? 50.0 : 58.0;
    final iconSize = compactIcon ? 27.0 : 30.0;

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: iconExtent,
                height: iconExtent,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: scheme.primaryContainer,
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int youthShortcutColumnCount(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final textScale = MediaQuery.textScalerOf(context).scale(1);

  if (width < 360 || textScale > 1.25) {
    return 3;
  }

  return 4;
}

double youthShortcutTileHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);

  // 58 icon + 12 vertical padding + 6 gap + up to two label lines.
  // Keep extra room so normal text does not trigger RenderFlex bottom overflows.
  return (120 + ((textScale - 1).clamp(0, 2) * 46)).clamp(120, 196).toDouble();
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
