/// BINISHOP — Product Detail Screen
/// Fiche produit : galerie, variantes, prix, stock, panier.
library features.product.presentation.screens.product_detail_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/product_detail_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Produit'),
      ),
      body: productAsync.when(
        loading: () => const LoadingState(useSkeleton: true),
        error: (error, stack) => ErrorState(
          message: 'Impossible de charger ce produit.',
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        data: (product) => _ProductDetailBody(productId: productId),
      ),
    );
  }
}

class _ProductDetailBody extends ConsumerStatefulWidget {
  final String productId;

  const _ProductDetailBody({required this.productId});

  @override
  ConsumerState<_ProductDetailBody> createState() => _ProductDetailBodyState();
}

class _ProductDetailBodyState extends ConsumerState<_ProductDetailBody> {
  int _selectedImageIndex = 0;
  String? _selectedVariantId;

  @override
  Widget build(BuildContext context) {
    final product =
        ref.watch(productDetailProvider(widget.productId)).value;
    if (product == null) return const SizedBox.shrink();

    // Sélectionner la première variante disponible par défaut
    if (_selectedVariantId == null && product.variants.isNotEmpty) {
      final firstAvailable = product.variants
          .firstWhere((v) => v.isAvailable, orElse: () => product.variants.first);
      _selectedVariantId = firstAvailable.id;
    }

    final selectedVariant = product.variants.isEmpty
        ? null
        : product.variants.firstWhere(
            (v) => v.id == _selectedVariantId,
            orElse: () => product.variants.first,
          );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGallery(product),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, product, selectedVariant),
                AppSpacing.gapLg,
                _buildPrice(selectedVariant),
                AppSpacing.gapLg,
                if (product.options.isNotEmpty) ...[
                  _buildOptions(product),
                  AppSpacing.gapLg,
                ],
                _buildStockInfo(selectedVariant),
                AppSpacing.gapXl,
                _buildAddToCartButton(selectedVariant),
                AppSpacing.gapXl,
                if ((product.description ?? '').isNotEmpty) ...[
                  const Text('Description', style: AppTypography.headlineSmall),
                  AppSpacing.gapSm,
                  Text(
                    product.description!,
                    style: AppTypography.bodyMedium.copyWith(height: 1.6),
                  ),
                  AppSpacing.gapXl,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGallery(dynamic product) {
    final images = product.allImages;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: AppColors.surfaceDark,
            child: images.isNotEmpty
                ? Image.network(images[_selectedImageIndex.clamp(0, images.length - 1)],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported_outlined, size: 64)))
                : const Center(
                    child: Icon(Icons.image_outlined, size: 64, color: AppColors.textTertiary)),
          ),
        ),
        if (images.length > 1)
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppSpacing.sm),
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => _selectedImageIndex = index),
                child: Container(
                  width: 64,
                  height: 64,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusSm,
                    border: Border.all(
                      color: index == _selectedImageIndex
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: 2,
                    ),
                  ),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AppColors.surfaceDark),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, dynamic product, dynamic variant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (product.hasPromotion) ...[
              const AppBadge(label: 'PROMO', type: BadgeType.sale),
              const SizedBox(width: 8),
            ],
            if (product.isNew) const AppBadge(label: 'NEW', type: BadgeType.new_),
          ],
        ),
        if (product.hasPromotion || product.isNew) AppSpacing.gapSm,
        Text(product.title, style: AppTypography.headlineMedium),
        if ((product.subtitle ?? '').isNotEmpty) ...[
          AppSpacing.gapXs,
          Text(product.subtitle!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ],
    );
  }

  Widget _buildPrice(dynamic variant) {
    final price = variant?.price;
    final compare = variant?.compareAtPrice;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          price != null ? '${price.toStringAsFixed(2)} €' : 'Prix non disponible',
          style: AppTypography.priceLarge.copyWith(
            color: price != null ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
        if (compare != null && compare > (price ?? 0)) ...[
          const SizedBox(width: 12),
          Text('${compare.toStringAsFixed(2)} €', style: AppTypography.priceSmall),
        ],
      ],
    );
  }

  Widget _buildOptions(dynamic product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: product.options.map<Widget>((option) {
        final values = option.values;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(option.title, style: AppTypography.titleSmall),
            AppSpacing.gapSm,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: values.map<Widget>((value) => _optionChip(option.title, value)).toList(),
            ),
          ],
        );
      }).toList(),
    );
  }
  Widget _optionChip(String optionTitle, String value) {
    return ChoiceChip(
      label: Text(value),
      selected: false,
      onSelected: (_) {
        // TODO P9: sélection de variante par combinaison d'options
      },
      selectedColor: AppColors.primary,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStockInfo(dynamic variant) {
    if (variant == null) return const SizedBox.shrink();
    final inStock = variant.isAvailable;
    final qty = variant.inventoryQuantity ?? 0;
    return Row(
      children: [
        Icon(
          inStock ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: inStock ? AppColors.success : AppColors.error,
        ),
        const SizedBox(width: 6),
        Text(
          variant.isOutOfStock
              ? 'Rupture de stock'
              : (qty > 0 && qty <= 5 ? 'Plus que $qty en stock' : 'En stock'),
          style: AppTypography.bodySmall.copyWith(
            color: inStock ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(dynamic variant) {
    final disabled = variant == null || variant.isOutOfStock;
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: 'Ajouter au panier',
        icon: Icons.shopping_bag_outlined,
        expanded: true,
        onPressed: disabled
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ajout au panier — intégration checkout Phase 9'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
      ),
    );
  }
}