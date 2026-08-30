/// BINISHOP — Product Entity
/// Modèle métier produit (source : Medusa).
library features.catalog.domain.entities.product;

import 'package:equatable/equatable.dart';

import 'product_option.dart';
import 'product_variant.dart';

class Product extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final String handle;
  final String status;
  final String? thumbnail;
  final List<String> images;
  final List<ProductVariant> variants;
  final List<ProductOption> options;
  final String? collectionId;
  final List<String> categories;
  final String? brand;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.handle,
    this.status = 'published',
    this.thumbnail,
    this.images = const [],
    this.variants = const [],
    this.options = const [],
    this.collectionId,
    this.categories = const [],
    this.brand,
    this.tags = const [],
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  // --- Convenience getters ---

  bool get isPublished => status == 'published';
  bool get isDraft => status == 'draft';
  bool get isArchived => status == 'archived';

  String? get primaryImage {
    if (images.isNotEmpty) return images.first;
    return thumbnail;
  }

  List<String> get allImages => images;

  /// Find the cheapest variant price
  double? get displayPrice {
    final prices = variants
        .where((v) => v.price != null)
        .map((v) => v.price!)
        .toList();
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  /// Compare-at price if any variant has one
  double? get compareAtPrice {
    final prices = variants
        .where((v) => v.compareAtPrice != null)
        .map((v) => v.compareAtPrice!)
        .toList();
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  bool get hasPromotion {
    return compareAtPrice != null && compareAtPrice! > (displayPrice ?? 0);
  }

  @override
  List<Object?> get props => [id, title, handle, status];
}