/// BINISHOP — Admin Settings
/// Paramètres de la boutique. Les éléments (régions, devises, livraison,
/// paiement, utilisateurs) sont gérés au niveau Medusa. Cet écran documente
/// les rubriques et centralise les informations système réelles.
library features.admin.presentation.screens.admin_settings_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../shared/admin_widgets.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = [
      (
        icon: Icons.public_outlined,
        title: 'Régions & Devises',
        subtitle: 'Devises et régions de livraison configurées dans Medusa.',
      ),
      (
        icon: Icons.local_shipping_outlined,
        title: 'Livraison',
        subtitle: 'Options et frais de livraison (gérés dans Medusa).',
      ),
      (
        icon: Icons.payment_outlined,
        title: 'Paiement',
        subtitle: 'Provider TEST actif — aucune transaction réelle en local.',
      ),
      (
        icon: Icons.admin_panel_settings_outlined,
        title: 'Utilisateurs & Rôles',
        subtitle: 'SUPER_ADMIN / ADMIN / MANAGER — permissions vérifiées côté backend.',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Paramètres',
          subtitle: 'Configuration générale de votre boutique.',
        ),
        AppSpacing.gapLg,
        Column(
          children: [
            for (final s in sections)
              AdminListTile(
                title: s.title,
                subtitle: s.subtitle,
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(s.icon, color: AppColors.secondary),
                ),
              ),
          ],
        ),
        AppSpacing.gapLg,
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.secondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'La gestion fine des régions, devises, livraison et paiements '
                  's\'effectue dans Medusa. Les permissions admin sont contrôlées '
                  'côté backend (règle #94) : Flutter ne fait que présenter l\'UI.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}