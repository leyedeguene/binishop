/// BINISHOP — Cart Screen
library features.cart.presentation.screens.cart_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/states/empty_state.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/cart_item.dart';
import '../cart_notifier.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Panier')),
      body: cartState.isEmpty
          ? _buildEmpty(context)
          : Column(
              children: [
                Expanded(child: _buildItems(context, ref, cartState)),
                _buildSummary(context, ref, cartState),
              ],
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyState(
      icon: Icons.shopping_bag_outlined,
      title: 'Votre panier est vide',
      message: 'Parcourez le catalogue pour découvrir nos produits.',
      actionLabel: 'Voir le catalogue',
      onAction: () => context.go('/catalog'),
    );
  }

  Widget _buildItems(BuildContext context, WidgetRef ref, CartState state) {
    final items = state.cart.items;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, __) => AppSpacing.gapMd,
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: AppColors.error,
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) =>
              ref.read(cartNotifierProvider.notifier).removeItem(item.id),
          child: _CartItemTile(
            item: item,
            onQuantityChange: (qty) =>
                ref.read(cartNotifierProvider.notifier).updateQuantity(item.id, qty),
          ),
        );
      },
    );
  }

  Widget _buildSummary(BuildContext context, WidgetRef ref, CartState state) {
    final subtotal = state.cart.subtotal ?? 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        borderRadius: AppRadius.topLg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total', style: AppTypography.bodyMedium),
                Text('${subtotal.toStringAsFixed(2)} €',
                    style: AppTypography.titleLarge),
              ],
            ),
            AppSpacing.gapSm,
            Text(
              'Frais de livraison calculés au checkout.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.gapLg,
            AppButton(
              label: 'Passer commande',
              expanded: true,
              size: AppButtonSize.large,
              onPressed: () => context.go('/checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChange;

  const _CartItemTile({required this.item, required this.onQuantityChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.radiusSm,
            child: (item.thumbnail ?? '').isNotEmpty
                ? Image.network(item.thumbnail!,
                    width: 72,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium),
                if (item.variantTitle.isNotEmpty)
                  Text(item.variantTitle,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                AppSpacing.gapXs,
                Text('${item.price.toStringAsFixed(2)} €',
                    style:
                        AppTypography.titleMedium.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _QtyButton(
                      icon: Icons.remove_outlined,
                      onTap: () => onQuantityChange(item.quantity - 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child:
                        Text('${item.quantity}', style: AppTypography.titleMedium),
                  ),
                  _QtyButton(
                      icon: Icons.add_outlined,
                      onTap: () => onQuantityChange(item.quantity + 1)),
                ],
              ),
              AppSpacing.gapSm,
              Text('${item.lineTotal.toStringAsFixed(2)} €',
                  style: AppTypography.labelLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 72,
        height: 90,
        color: AppColors.surfaceDark,
        child: const Icon(Icons.image_outlined, color: AppColors.textTertiary),
      );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}