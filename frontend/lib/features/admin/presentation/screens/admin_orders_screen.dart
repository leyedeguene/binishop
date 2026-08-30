/// BINISHOP — Admin Orders
/// Commandes réelles depuis /admin/orders (Medusa).
library features.admin.presentation.screens.admin_orders_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../admin_providers.dart';
import '../shared/admin_widgets.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(adminOrdersProvider(_refresh));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Commandes',
          subtitle: 'Commandes réelles passées par vos clients.',
        ),
        AppSpacing.gapLg,
        orders.when(
          loading: () => const LoadingState(useSkeleton: true),
          error: (e, _) => ErrorState(
            message: e.toString().replaceAll('StateError: ', ''),
            onRetry: () => setState(() => _refresh++),
          ),
          data: (data) {
            final list = (data['orders'] as List?) ?? [];
            if (list.isEmpty) {
              return const AdminEmpty(
                icon: Icons.receipt_long_outlined,
                message: 'Aucune commande pour le moment.',
              );
            }
            return Column(children: [for (final o in list) _tile(o)]);
          },
        ),
      ],
    );
  }

  Widget _tile(dynamic o) {
    final map = (o as Map).cast<String, dynamic>();
    final id = map['display_id']?.toString() ?? map['id']?.toString() ?? '—';
    final email = map['email']?.toString() ?? 'Client';
    final total = map['total'] ?? 0;
    final currency = map['currency_code']?.toString() ?? 'EUR';
    final status = map['status']?.toString() ?? '—';
    final createdAt = map['created_at']?.toString();
    return AdminListTile(
      title: 'Commande #$id',
      subtitle: '$email • ${Formatters.dateTime(createdAt)}',
      leading: Container(
        width: 40, height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.radiusSm,
        ),
        child: const Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(Formatters.currency(total, currencyCode: currency),
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          _statusBadge(status),
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
          style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }
}