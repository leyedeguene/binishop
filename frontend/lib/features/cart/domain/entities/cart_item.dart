/// BINISHOP — CartItem Entity
library features.cart.domain.entities.cart_item;

import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String variantId;
  final String productTitle;
  final String variantTitle;
  final String? thumbnail;
  final double price;
  final int quantity;
  final String? size;
  final String? color;
  final int? inventoryQuantity;
  final bool allowBackorder;

  const CartItem({
    required this.id,
    required this.variantId,
    required this.productTitle,
    required this.variantTitle,
    this.thumbnail,
    required this.price,
    this.quantity = 1,
    this.size,
    this.color,
    this.inventoryQuantity,
    this.allowBackorder = false,
  });

  double get lineTotal => price * quantity;

  CartItem copyWith({
    String? id,
    String? variantId,
    String? productTitle,
    String? variantTitle,
    String? thumbnail,
    double? price,
    int? quantity,
    String? size,
    String? color,
    int? inventoryQuantity,
    bool? allowBackorder,
  }) {
    return CartItem(
      id: id ?? this.id,
      variantId: variantId ?? this.variantId,
      productTitle: productTitle ?? this.productTitle,
      variantTitle: variantTitle ?? this.variantTitle,
      thumbnail: thumbnail ?? this.thumbnail,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
      inventoryQuantity: inventoryQuantity ?? this.inventoryQuantity,
      allowBackorder: allowBackorder ?? this.allowBackorder,
    );
  }

  @override
  List<Object?> get props => [id, variantId, quantity];
}
