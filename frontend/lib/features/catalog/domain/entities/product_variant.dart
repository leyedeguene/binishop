/// BINISHOP — Product Variant Entity
library features.catalog.domain.entities.product_variant;

import 'package:equatable/equatable.dart';

class ProductVariant extends Equatable {
  final String id;
  final String title;
  final String? sku;
  final String? barcode;
  final double? price;
  final double? compareAtPrice;
  final int? inventoryQuantity;
  final bool manageStock;
  final bool allowBackorder;
  final String? weight;
  final String? size;
  final String? color;
  final String? image;
  final List<ProductOptionValue> optionValues;
  final Map<String, dynamic>? metadata;

  const ProductVariant({
    required this.id,
    required this.title,
    this.sku,
    this.barcode,
    this.price,
    this.compareAtPrice,
    this.inventoryQuantity,
    this.manageStock = false,
    this.allowBackorder = false,
    this.weight,
    this.size,
    this.color,
    this.image,
    this.optionValues = const [],
    this.metadata,
  });

  bool get isAvailable {
    if (!manageStock) return true;
    return (inventoryQuantity ?? 0) > 0 || allowBackorder;
  }

  bool get isOutOfStock => manageStock && (inventoryQuantity ?? 0) <= 0 && !allowBackorder;

  bool get isInStock => (inventoryQuantity ?? 0) > 0;

  /// Short display of options (e.g. "Noir / M")
  String get optionLabel {
    if (optionValues.isNotEmpty) {
      return optionValues.map((o) => o.value).join(' / ');
    }
    return title;
  }

  @override
  List<Object?> get props => [id, title, sku];
}

class ProductOptionValue extends Equatable {
  final String id;
  final String optionId;
  final String value;

  const ProductOptionValue({
    required this.id,
    required this.optionId,
    required this.value,
  });

  @override
  List<Object?> get props => [id, optionId, value];
}