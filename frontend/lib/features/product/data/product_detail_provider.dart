/// BINISHOP — Product Detail Provider
library features.product.data.product_detail_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/service_providers.dart';
import '../../catalog/domain/entities/product.dart';
import '../../catalog/domain/entities/product_option.dart';
import '../../catalog/domain/entities/product_variant.dart';

/// Provider d'un produit détaillé (données réelles Medusa)
final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, productId) async {
  final service = ref.watch(productServiceProvider);
  final result = await service.getProduct(productId);

  if (result.data == null || result.data!['product'] == null) {
    throw Exception(result.error ?? 'Produit introuvable');
  }

  return _parseProduct(
    Map<String, dynamic>.from(result.data!['product'] as Map),
  );
});

/// Parse un produit Medusa → entité Product
Product _parseProduct(Map<String, dynamic> item) {
  final variants = ((item['variants'] as List?) ?? const [])
      .map((v) => Map<String, dynamic>.from(v as Map))
      .map((v) {
        // Prix depuis les price sets
        double? price;
        double? compareAtPrice;
        final prices = v['prices'] as List?;
        if (prices != null && prices.isNotEmpty) {
          final p = Map<String, dynamic>.from(prices.first as Map);
          price = (p['amount'] as num?)?.toDouble();
        }
        final originalPrice = v['original_price'];
        if (originalPrice is num) compareAtPrice = originalPrice.toDouble();

        // Option values (size / color)
        String? size;
        String? color;
        final options = v['options'] as List?;
        if (options != null) {
          for (final o in options) {
            final om = Map<String, dynamic>.from(o as Map);
            final title = om['option']?['title']?.toString() ??
                om['title']?.toString() ??
                '';
            final value = om['value']?.toString();
            if (title.toLowerCase().contains('taille') ||
                title.toLowerCase().contains('size')) {
              size = value;
            } else if (title.toLowerCase().contains('couleur') ||
                title.toLowerCase().contains('color')) {
              color = value;
            }
          }
        }

        return ProductVariant(
          id: v['id']?.toString() ?? '',
          title: v['title']?.toString() ?? '',
          sku: v['sku']?.toString(),
          barcode: v['barcode']?.toString(),
          price: price,
          compareAtPrice: compareAtPrice,
          inventoryQuantity:
              (v['inventory_quantity'] as num?)?.toInt() ?? 0,
          manageStock: v['manage_inventory'] ?? false,
          allowBackorder: v['allow_backorder'] ?? false,
          size: size,
          color: color,
        );
      })
      .toList();

  final options = ((item['options'] as List?) ?? const [])
      .map((o) => Map<String, dynamic>.from(o as Map))
      .map((o) => ProductOption(
            id: o['id']?.toString() ?? '',
            title: o['title']?.toString() ?? '',
            values: ((o['values'] as List?) ?? const [])
                .map((v) => v is Map ? (v['value'] ?? '').toString() : v.toString())
                .toList(),
          ))
      .toList();

  final images = <String>[];
  final rawImages = item['images'] as List?;
  if (rawImages != null) {
    for (final img in rawImages) {
      if (img is Map) {
        images.add(img['url']?.toString() ?? '');
      } else {
        images.add(img.toString());
      }
    }
  }

  return Product(
    id: item['id']?.toString() ?? '',
    title: item['title']?.toString() ?? '',
    subtitle: item['subtitle']?.toString(),
    description: _stripHtml(item['description']?.toString()),
    handle: item['handle']?.toString() ?? '',
    status: item['status']?.toString() ?? 'published',
    thumbnail: item['thumbnail']?.toString(),
    images: images,
    variants: variants,
    options: options,
    collectionId: item['collection_id']?.toString(),
    brand: item['brand'] is Map
        ? item['brand']['name']?.toString()
        : null,
    createdAt: DateTime.tryParse(item['created_at']?.toString() ?? ''),
    updatedAt: DateTime.tryParse(item['updated_at']?.toString() ?? ''),
  );
}

String? _stripHtml(String? html) {
  if (html == null || html.isEmpty) return html;
  return html
      .replaceAll(RegExp(r'<[^>]*>'), '\n')
      .replaceAll(RegExp(r'\n{2,}'), '\n\n')
      .trim();
}