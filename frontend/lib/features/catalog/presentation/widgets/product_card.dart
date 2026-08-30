/// BINISHOP — Product Card Widget
library features.catalog.presentation.widgets.product_card;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistToggle;
  final bool isFavorite;
  final double? aspectRatio;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistToggle,
    this.isFavorite = false,
    this.aspectRatio = 0.78,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.radiusMd,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
            border: Border.all(color: AppColors.borderLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _buildDetails(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = widget.product.primaryImage;
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: widget.aspectRatio ?? 0.78,
          child: Container(
            color: AppColors.surfaceDark,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondary.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) =>
                        const _ImagePlaceholder(),
                  )
                : const _ImagePlaceholder(),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _buildBadges(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _buildWishlistButton(),
        ),
      ],
    );
  }

  Widget _buildBadges() {
    final badges = <Widget>[];
    final product = widget.product;
    if (product.hasPromotion && product.compareAtPrice != null) {
      final pct = _discountPercent(
        product.displayPrice ?? 0,
        product.compareAtPrice ?? 0,
      );
      badges.add(AppBadge(label: '-$pct%', type: BadgeType.sale));
    }
    if (product.isNew) {
      badges.add(const AppBadge(label: 'NEW', type: BadgeType.new_));
    }
    if (badges.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < badges.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          badges[i],
        ],
      ],
    );
  }

  int _discountPercent(double price, double compare) {
    if (compare <= 0) return 0;
    return ((1 - price / compare) * 100).round();
  }

  Widget _buildWishlistButton() {
    return GestureDetector(
      onTap: widget.onWishlistToggle,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: widget.isFavorite ? AppColors.secondary : AppColors.textSecondary,
        ),
      ),
    );
  }
  Widget _buildDetails(BuildContext context) {
    final product = widget.product;
    final price = product.displayPrice;
    final comparePrice = product.compareAtPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleMedium,
        ),
        AppSpacing.gapXs,
        if (product.subtitle != null && product.subtitle!.isNotEmpty)
          Text(
            product.subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        AppSpacing.gapSm,
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (price != null)
              Text(
                '${price.toStringAsFixed(2)} €',
                style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
              )
            else
              Text(
                '—',
                style: AppTypography.titleLarge.copyWith(color: AppColors.textTertiary),
              ),
            if (comparePrice != null && comparePrice > price!) ...[
              const SizedBox(width: 6),
              Text('${comparePrice.toStringAsFixed(2)} €', style: AppTypography.priceSmall),
            ],
          ],
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: AppColors.textTertiary.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Extension convenance : produit considéré "nouveau" si créé il y a ≤ 14 jours
extension on Product {
  bool get isNew {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!) <= const Duration(days: 14);
  }
}