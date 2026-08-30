/// BINISHOP — Cart Notifier & Providers
/// Gestion d'état du panier via Medusa Store API.
library features.cart.presentation.cart_notifier;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';
import '../domain/entities/cart.dart';
import '../domain/entities/cart_item.dart';

/// Provider du service panier (déjà dans service_providers)
/// État du panier
class CartState {
  final Cart cart;
  final bool isLoading;
  final String? error;

  const CartState({
    this.cart = const Cart(id: ''),
    this.isLoading = false,
    this.error,
  });

  int get itemCount => cart.items.fold(0, (s, i) => s + i.quantity);

  bool get isEmpty => cart.items.isEmpty;

  CartState copyWith({
    Cart? cart,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider panier
final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(
    ref.watch(cartServiceProvider),
  );
});

class CartNotifier extends StateNotifier<CartState> {
  final dynamic _cartService;

  /// ID du panier persistant (localStorage côté client à venir)
  String? _cartId;

  CartNotifier(this._cartService) : super(const CartState());

  /// Crée un nouveau panier ou charge l'existant
  Future<void> ensureCart() async {
    if (_cartId != null) return;
    state = state.copyWith(isLoading: true);
    try {
      final result = await _cartService.createCart();
      final data = result.data;
      if (data != null && data['cart'] != null) {
        final cartData = data['cart'] as Map<String, dynamic>;
        _cartId = cartData['id']?.toString();
        // region_id est retourné par Medusa dans le cart
        // on le stocke dans metadata pour le checkout
        final regionId = cartData['region_id']?.toString();
        // on met à jour le Cart avec la région
        state = state.copyWith(
          cart: state.cart.copyWith(
            id: _cartId ?? '',
            regionId: regionId,
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error ?? 'Impossible de créer le panier.',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur réseau.');
    }
  }

  /// Ajoute une variante au panier
  Future<bool> addItem({
    required String variantId,
    required String productTitle,
    required String variantTitle,
    required double price,
    required int quantity,
    String? thumbnail,
    String? size,
    String? color,
  }) async {
    await ensureCart();
    if (_cartId == null) return false;

    // Optimistic UI : ajout local immédiat
    final items = [...state.cart.items];
    final existingIndex =
        items.indexWhere((i) => i.variantId == variantId);
    if (existingIndex >= 0) {
      final existing = items[existingIndex];
      items[existingIndex] = existing.copyWith(
          quantity: existing.quantity + quantity);
    } else {
      items.add(CartItem(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        variantId: variantId,
        productTitle: productTitle,
        variantTitle: variantTitle,
        price: price,
        quantity: quantity,
        thumbnail: thumbnail,
        size: size,
        color: color,
      ));
    }

    final subtotal = items.fold<double>(0, (s, i) => s + i.lineTotal);
    state = state.copyWith(
      cart: Cart(
        id: _cartId!,
        items: items,
        subtotal: subtotal,
        total: subtotal,
      ),
    );

    // Synchronisation Medusa
    try {
      final result = await _cartService.addLineItem(
        cartId: _cartId!,
        variantId: variantId,
        quantity: quantity,
      );
      if (result.data?['cart'] != null) {
        // Le serveur confirme — on garde l'état optimiste
        return true;
      }
      return true; // Mode dégradé local si API indisponible
    } catch (_) {
      return true; // L'ajout local reste valable
    }
  }

  /// Modifie la quantité d'un article
  Future<void> updateQuantity(String lineItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(lineItemId);
      return;
    }

    final items = [...state.cart.items];
    final idx = items.indexWhere((i) => i.id == lineItemId);
    if (idx < 0) return;

    items[idx] = items[idx].copyWith(quantity: quantity);
    final subtotal = items.fold<double>(0, (s, i) => s + i.lineTotal);
    state = state.copyWith(
      cart: Cart(id: _cartId ?? '', items: items, subtotal: subtotal, total: subtotal),
    );

    if (_cartId != null) {
      try {
        await _cartService.updateLineItem(
          cartId: _cartId!,
          lineItemId: lineItemId,
          quantity: quantity,
        );
      } catch (_) {}
    }
  }

  /// Supprime un article
  Future<void> removeItem(String lineItemId) async {
    final items = state.cart.items.where((i) => i.id != lineItemId).toList();
    final subtotal = items.fold<double>(0, (s, i) => s + i.lineTotal);
    state = state.copyWith(
      cart: Cart(id: _cartId ?? '', items: items, subtotal: subtotal, total: subtotal),
    );

    if (_cartId != null) {
      try {
        await _cartService.removeLineItem(
            cartId: _cartId!, lineItemId: lineItemId);
      } catch (_) {}
    }
  }

  void clearError() {
    state = state.copyWith();
  }
}