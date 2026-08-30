/// BINISHOP — Application Button
/// Composant bouton unifié avec variantes.
library shared.widgets.app_button;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool expanded;
  final Widget? prefix;
  final Widget? suffix;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.expanded = false,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyle(context);
    final content = _buildContent(context);

    if (expanded) {
      return SizedBox(width: double.infinity, child: _buildButton(style, content));
    }
    return _buildButton(style, content);
  }

  Widget _buildButton(ButtonStyle style, Widget content) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20, height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefix != null) prefix!,
        if (icon != null && prefix == null) ...[
          Icon(icon, size: _iconSize),
          AppSpacing.gapWSm,
        ],
        Text(label, style: _textStyle),
        if (suffix != null) ...[
          AppSpacing.gapWSm,
          suffix!,
        ],
      ],
    );
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small: return 16;
      case AppButtonSize.medium: return 20;
      case AppButtonSize.large: return 24;
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case AppButtonSize.small: return AppTypography.labelMedium;
      case AppButtonSize.medium: return AppTypography.labelLarge;
      case AppButtonSize.large: return AppTypography.titleMedium;
    }
  }

  ButtonStyle _getStyle(BuildContext context) {
    final base = ElevatedButton.styleFrom(
      padding: _padding,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
      elevation: 0,
    );

    switch (variant) {
      case AppButtonVariant.primary:
        return base.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return AppColors.textTertiary;
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        );
      case AppButtonVariant.secondary:
        return base.copyWith(
          backgroundColor: WidgetStateProperty.all(AppColors.secondary),
          foregroundColor: WidgetStateProperty.all(AppColors.textOnSecondary),
        );
      case AppButtonVariant.outline:
        return base.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(AppColors.primary),
          side: WidgetStateProperty.all(const BorderSide(color: AppColors.border)),
        );
      case AppButtonVariant.ghost:
        return base.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(AppColors.primary),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        );
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }
}