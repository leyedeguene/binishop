/// BINISHOP — Admin Promotions
/// Promotions/codes promo réels depuis /admin/discounts (Medusa).
library features.admin.presentation.screens.admin_promotions_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../admin_providers.dart';
import '../shared/admin_widgets.dart';

class AdminPromotionsScreen extends ConsumerStatefulWidget {
  const AdminPromotionsScreen({super.key});

  @override
  ConsumerState<AdminPromotionsScreen> createState() =>
      _AdminPromotionsScreenState();
}

class _AdminPromotionsScreenState extends ConsumerState<AdminPromotionsScreen> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    final promotions = ref.watch(adminPromotionsProvider(_refresh));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Promotions',
          subtitle: 'Coupons et promotions réelles (source Medusa).',
        ),
        AppSpacing.gapLg,
        promotions.when(
          loading: () => const LoadingState(useSkeleton: true),
          error: (e, _) => ErrorState(
            message: e.toString().replaceAll('StateError: ', ''),
            onRetry: () => setState(() => _refresh++),
          ),
          data: (data) {
            final list = (data['discounts'] as List?) ?? [];
            if (list.isEmpty) {
              return const AdminEmpty(
                icon: Icons.local_offer_outlined,
                message: 'Aucune promotion active.\nCréez une promotion pour commencer.',
              );
            }
            return Column(children: [for (final p in list) _tile(p)]);
          },
        ),
      ],
    );
  }

  Widget _tile(dynamic p) {
    final map = (p as Map).cast<String, dynamic>();
    final code = map['code']?.toString() ?? '—';
    final isDynamic = map['is_dynamic'] == true;
    final usageCount = map['usage_count'] ?? 0;
    final usageLimit = map['usage_limit'];
    final rule = (map['rule'] as Map?)?.cast<String, dynamic>() ?? {};
    final value = rule['value'] ?? 0;
    final type = rule['type']?.toString() ?? 'percentage';
    return AdminListTile(
      title: code,
      subtitle: isDynamic
          ? 'Code dynamique'
          : '${_label(type, value)} • $usageCount usage(s)${
              usageLimit != null ? ' / $usageLimit' : ''}',
      leading: Container(
        width: 40, height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.radiusSm,
        ),
        child: const Icon(Icons.local_offer_outlined, color: AppColors.secondary),
      ),
      trailing: const AppBadge(
        label: 'Actif',
        type: BadgeType.success,
      ),
    );
  }

  String _label(String type, dynamic value) {
    final num v = value is num ? value : double.tryParse('$value') ?? 0;
    return switch (type) {
      'percentage' => '−$v %',
      'fixed' => Formatters.currency(v),
      _ => type,
    };
  }
}