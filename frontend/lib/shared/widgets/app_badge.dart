/// BINISHOP — Application Badge
library shared.widgets.app_badge;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

enum BadgeType { new_, bestseller, sale, outOfStock, info, success, warning, error, custom }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final Color? customColor;

  const AppBadge({
    super.key,
    required this.label,
    this.type = BadgeType.info,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: colors.$2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _getColors() {
    switch (type) {
      case BadgeType.new_:
        return const (Color(0xFFE0F2FE), Color(0xFF0369A1));
      case BadgeType.bestseller:
        return const (Color(0xFFFEF3C7), Color(0xFFB45309));
      case BadgeType.sale:
        return const (Color(0xFFFEE2E2), Color(0xFFDC2626));
      case BadgeType.outOfStock:
        return const (Color(0xFFF3F4F6), Color(0xFF6B7280));
      case BadgeType.success:
        return const (Color(0xFFDCFCE7), Color(0xFF16A34A));
      case BadgeType.warning:
        return const (Color(0xFFFEF3C7), Color(0xFFB45309));
      case BadgeType.error:
        return const (Color(0xFFFEE2E2), Color(0xFFDC2626));
      case BadgeType.info:
        return const (Color(0xFFE0F2FE), Color(0xFF0369A1));
      case BadgeType.custom:
        final c = customColor ?? AppColors.primary;
        return (c.withValues(alpha: 0.1), c);
    }
  }
}