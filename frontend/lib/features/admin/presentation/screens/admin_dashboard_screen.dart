/// BINISHOP — Admin Dashboard
/// Statistiques UNIQUEMENT réelles provenant de /admin/analytics.
/// Aucune donnée fictive (règles ZÉRO FAUSSE DONNÉE).
library features.admin.presentation.screens.admin_dashboard_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../../../../shared/widgets/app_card.dart';
import '../admin_providers.dart';

const _periods = [
  ('today', 'Aujourd\'hui'),
  ('7d', '7 jours'),
  ('30d', '30 jours'),
  ('3m', '3 mois'),
  ('12m', '12 mois'),
  ('all', 'Tout'),
];

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _period = '30d';

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(adminAnalyticsProvider(_period));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        AppSpacing.gapXxl,
        analytics.when(
          loading: () => const LoadingState(useSkeleton: true),
          error: (e, _) => ErrorState(
            message: e.toString().replaceAll('StateError: ', ''),
            onRetry: () => ref.invalidate(adminAnalyticsProvider(_period)),
          ),
          data: (data) => _content(context, data),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, Map<String, dynamic> data) {
    final overview = (data['overview'] as Map?) ?? {};
    final topProducts = (data['top_products'] as List?) ?? [];
    final recentOrders = (data['recent_orders'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return GridView.count(
              crossAxisCount: wide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: wide ? 1.9 : 1.4,
              children: [
                _kpiCard('Chiffre d\'affaires', overview['revenue'],
                    Icons.payments_outlined, AppColors.success, isMoney: true),
                _kpiCard('Commandes', overview['orders_count'],
                    Icons.receipt_long_outlined, AppColors.info),
                _kpiCard('Clients', overview['customers_total'],
                    Icons.people_outline, AppColors.secondary),
                _kpiCard('Produits publiés', overview['products_published'],
                    Icons.inventory_2_outlined, AppColors.warning),
              ],
            );
          },
        ),
        AppSpacing.gapXxl,
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return GridView.count(
              crossAxisCount: wide ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: wide ? 2.1 : 1.1,
              children: [
                _recentOrdersSection(recentOrders),
                _topProductsSection(topProducts),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _kpiCard(String label, dynamic value, IconData icon, Color color,
      {bool isMoney = false}) {
    final num v = value is num ? value : double.tryParse('$value') ?? 0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            isMoney ? Formatters.currency(v) : Formatters.compactNumber(v),
            style: AppTypography.priceMedium.copyWith(color: AppColors.textPrimary),
          ),
          AppSpacing.gapXs,
          Text(label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard',
            style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary)),
        AppSpacing.gapSm,
        Text('Vue d\'ensemble de votre boutique — données réelles uniquement.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        AppSpacing.gapLg,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in _periods)
              ChoiceChip(
                label: Text(p.$2),
                selected: _period == p.$1,
                onSelected: (_) => setState(() => _period = p.$1),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _period == p.$1
                      ? AppColors.textOnPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _recentOrdersSection(List<dynamic> orders) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Commandes récentes', style: AppTypography.titleLarge),
          AppSpacing.gapSm,
          if (orders.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Aucune commande.',
                    style: TextStyle(color: AppColors.textTertiary)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length.clamp(0, 6),
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, i) => _orderRow(orders[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _orderRow(dynamic o) {
    final map = (o as Map).cast<String, dynamic>();
    final id = map['display_id']?.toString() ?? map['id']?.toString() ?? '—';
    final total = (map['total'] is num) ? (map['total'] as num) : 0;
    final status = map['status']?.toString() ?? '—';
    final email = map['email']?.toString() ?? 'Client';
    final currency = map['currency_code']?.toString() ?? 'EUR';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text('#$id',
                style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(email,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          Text(
            '${(total / 100).toStringAsFixed(2)} $currency',
            style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _topProductsSection(List<dynamic> products) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Meilleures ventes', style: AppTypography.titleLarge),
          AppSpacing.gapSm,
          if (products.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Aucune donnée de vente disponible.',
                    style: TextStyle(color: AppColors.textTertiary)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length.clamp(0, 6),
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, i) => _topProductRow(products[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topProductRow(dynamic p) {
    final map = (p as Map).cast<String, dynamic>();
    final title = map['title']?.toString() ?? 'Produit';
    final units = map['units'] ?? 0;
    final rev = map['revenue'] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.badgeSale.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text('$units vendus',
                style: AppTypography.labelSmall.copyWith(color: AppColors.badgeSale)),
          ),
          const SizedBox(width: 12),
          Text(Formatters.currency(rev),
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final (bg, fg) = switch (status) {
      'pending' => (const Color(0xFFFEF3C7), const Color(0xFFB45309)),
      'confirmed' => (const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
      'canceled' => (const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
      _ => (const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.radiusSm),
      child: Text(status,
          style: AppTypography.labelSmall.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}