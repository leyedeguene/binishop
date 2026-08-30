/// BINISHOP — Admin Customers
/// Clients réels depuis /admin/customers (Medusa).
library features.admin.presentation.screens.admin_customers_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../admin_providers.dart';
import '../shared/admin_widgets.dart';

class AdminCustomersScreen extends ConsumerStatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  ConsumerState<AdminCustomersScreen> createState() =>
      _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends ConsumerState<AdminCustomersScreen> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(adminCustomersProvider(_refresh));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Clients',
          subtitle: 'Clients réellement inscrits dans votre boutique.',
        ),
        AppSpacing.gapLg,
        customers.when(
          loading: () => const LoadingState(useSkeleton: true),
          error: (e, _) => ErrorState(
            message: e.toString().replaceAll('StateError: ', ''),
            onRetry: () => setState(() => _refresh++),
          ),
          data: (data) {
            final list = (data['customers'] as List?) ?? [];
            if (list.isEmpty) {
              return const AdminEmpty(
                icon: Icons.people_outline,
                message: 'Aucun client inscrit pour le moment.',
              );
            }
            return Column(children: [for (final c in list) _tile(c)]);
          },
        ),
      ],
    );
  }

  Widget _tile(dynamic c) {
    final map = (c as Map).cast<String, dynamic>();
    final email = map['email']?.toString() ?? '—';
    final first = map['first_name']?.toString() ?? '';
    final last = map['last_name']?.toString() ?? '';
    final name = '$first $last'.trim().isEmpty ? email : '$first $last';
    final createdAt = map['created_at']?.toString();
    return AdminListTile(
      title: name,
      subtitle: email,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(
          (name.isNotEmpty ? name[0].toUpperCase() : '?'),
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: Text(
        createdAt == null ? '' : 'depuis ${createdAt.split('T').first}',
        style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
      ),
    );
  }
}