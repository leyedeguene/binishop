/// BINISHOP — Cart Entity (agrégat panier)
///
/// Les lignes de panier ([CartItem]) sont définies dans `cart_item.dart`,
/// qui reste la source canonique unique de ce modèle.
library features.cart.domain.entities.cart;

import 'package:equatable/equatable.dart';

import 'cart_item.dart';

class Cart extends Equatable {
  final String id;
  final String? customerId;
  final String? email;
  final List<CartItem> items;
  final String? regionId;
  final String? currencyCode;
  final double? subtotal;
  final double? discountTotal;
  final double? shippingTotal;
  final double? taxTotal;
  final double? total;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Cart({
    required this.id,
    this.customerId,
    this.email,
    this.items = const [],
    this.regionId,
    this.currencyCode,
    this.subtotal,
    this.discountTotal,
    this.shippingTotal,
    this.taxTotal,
    this.total,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Nombre total d'articles (somme des quantités).
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Cart copyWith({
    String? id,
    String? customerId,
    String? email,
    List<CartItem>? items,
    String? regionId,
    String? currencyCode,
    double? subtotal,
    double? discountTotal,
    double? shippingTotal,
    double? taxTotal,
    double? total,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      email: email ?? this.email,
      items: items ?? this.items,
      regionId: regionId ?? this.regionId,
      currencyCode: currencyCode ?? this.currencyCode,
      subtotal: subtotal ?? this.subtotal,
      discountTotal: discountTotal ?? this.discountTotal,
      shippingTotal: shippingTotal ?? this.shippingTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      total: total ?? this.total,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        email,
        items,
        currencyCode,
        subtotal,
        discountTotal,
        shippingTotal,
        total,
      ];
}