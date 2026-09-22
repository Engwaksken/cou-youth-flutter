import 'package:flutter/material.dart';

import '../services/branding_service.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.compact = false,
    this.showTagline = true,
    this.alignment = TextAlign.center,
  });

  final bool compact;
  final bool showTagline;
  final TextAlign alignment;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BrandingData>(
      future: BrandingService.load(),
      builder: (context, snapshot) {
        final brand = snapshot.data ?? BrandingData.fallback;
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final logoHeight = compact ? 58.0 : (scale > 1.2 ? 72.0 : 86.0);

        return Semantics(
          header: true,
          label: '${brand.shortName}. ${brand.tagline}',
          child: Column(
            crossAxisAlignment: alignment == TextAlign.center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (brand.logoUrl != null)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: compact ? 48 : 60,
                    maxHeight: logoHeight,
                    maxWidth: compact ? 150 : 210,
                  ),
                  child: Image.network(
                    brand.logoUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => _FallbackMark(compact: compact),
                  ),
                )
              else
                _FallbackMark(compact: compact),
              SizedBox(height: compact ? 10 : 14),
              Text(
                brand.shortName,
                textAlign: alignment,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: (compact
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.headlineSmall)
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (showTagline) ...[
                const SizedBox(height: 6),
                Text(
                  brand.tagline,
                  textAlign: alignment,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FallbackMark extends StatelessWidget {
  const _FallbackMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extent = compact ? 54.0 : 72.0;

    return Container(
      width: extent,
      height: extent,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.church_outlined,
        size: compact ? 30 : 40,
        color: scheme.primary,
      ),
    );
  }
}
