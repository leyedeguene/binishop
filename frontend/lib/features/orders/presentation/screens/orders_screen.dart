/// Écran des commandes client — données réelles Medusa.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/states/empty_state.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';

/// Notifier chargeant les commandes du client authentifié.
class OrdersNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final api = ref.watch(apiClientProvider);
    final result = await api.get<Map<String, dynamic>>(
      '/store/customers/me/orders',
      queryParameters: {'limit': '20'},
    );
    if (result.error != null) {
      throw Exception(result.error);
    }
    final data = result.data;
    final list = data?['orders'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final ordersProvider =
    AsyncNotifierProvider<OrdersNotifier, List<Map<String, dynamic>>>(
        OrdersNotifier.new);

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: ordersAsync.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          message: 'Impossible de charger vos commandes.',
          onRetry: () => ref.read(ordersProvider.notifier).refresh(),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Aucune commande',
              message: 'Vos commandes apparaîtront ici après votre premier achat.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  String get _displayId {
    final id = order['display_id'] ?? order['id'] ?? '';
    return '#$id';
  }

  String get _status {
    final s = (order['status'] ?? 'pending').toString();
    switch (s) {
      case 'completed':
        return 'Livrée';
      case 'canceled':
        return 'Annulée';
      default:
        return 'En cours';
    }
  }

  Color get _statusColor {
    final s = (order['status'] ?? 'pending').toString();
    if (s == 'completed') return AppColors.success;
    if (s == 'canceled') return AppColors.error;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final total = order['total'];
    final totalDouble = total is num ? total / 100.0 : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _status,
                style: TextStyle(color: _statusColor, fontSize: 12),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_displayId, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${totalDouble.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
