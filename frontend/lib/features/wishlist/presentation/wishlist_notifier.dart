/// BINISHOP — Wishlist Notifier
/// Gestion des favoris client.
///
/// NOTE : Medusa v2 n'a pas de wishlist native. Mode local :
/// persistance locale par device via SecureStorage.
/// Endpoint custom /store/custom/wishlist prévu pour version future.
library features.wishlist.presentation.wishlist_notifier;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';

/// Item de favori (variante produit).
/// Les champs title/price/thumbnail sont hydratés depuis Medusa à la lecture.
class WishlistItem {
  final String variantId;
  final String productId;
  final String title;
  final double? price;
  final String? thumbnail;

  const WishlistItem({
    required this.variantId,
    required this.productId,
    required this.title,
    this.price,
    this.thumbnail,
  });

  WishlistItem copyWith({
    String? variantId,
    String? productId,
    String? title,
    double? price,
    String? thumbnail,
  }) {
    return WishlistItem(
      variantId: variantId ?? this.variantId,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  Map<String, dynamic> toJson() => {
        'variant_id': variantId,
        'product_id': productId,
        'title': title,
        'price': price,
        'thumbnail': thumbnail,
      };

  static WishlistItem fromJson(Map<String, dynamic> j) => WishlistItem(
        variantId: j['variant_id']?.toString() ?? '',
        productId: j['product_id']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        price: (j['price'] as num?)?.toDouble(),
        thumbnail: j['thumbnail']?.toString(),
      );

  /// Prix formaté pour l'affichage (ex: "45,00 €")
  String? get formattedPrice {
    if (price == null) return null;
    return '${price!.toStringAsFixed(2)} €';
  }
}

final wishlistNotifierProvider =
    StateNotifierProvider<WishlistNotifier, List<WishlistItem>>((ref) {
  return WishlistNotifier(SecureStorage());
});

class WishlistNotifier extends StateNotifier<List<WishlistItem>> {
  static const _storageKey = 'wishlist_items';
  final SecureStorage _storage;

  WishlistNotifier(this._storage) : super(const []);

  /// Charge et **hydrate** les favoris depuis Medusa (données réelles).
  /// Retourne la liste enrichie (title, price, thumbnail).
  Future<List<WishlistItem>> loadAndHydrate(
    Future<List<WishlistItem>> Function(List<WishlistItem>) hydrate,
  ) async {
    final raw = await _storage.read(_storageKey);
    if (raw == null || raw.isEmpty) {
      state = const [];
      return const [];
    }

    try {
      final items = _decode(raw);
      final hydrated = await hydrate(items);
      state = hydrated;
      // Persiste la version hydratée (title/price/thumbnail à jour)
      await _persistFrom(hydrated);
      return hydrated;
    } catch (_) {
      state = const [];
      return const [];
    }
  }

  /// Charge uniquement depuis le stockage local (sans hydratation Medusa).
  Future<List<WishlistItem>> load() async {
    final raw = await _storage.read(_storageKey);
    if (raw == null || raw.isEmpty) {
      state = const [];
      return const [];
    }
    try {
      state = _decode(raw);
      return state;
    } catch (_) {
      state = const [];
      return const [];
    }
  }

  bool contains(String variantId) {
    return state.any((i) => i.variantId == variantId);
  }

  Future<void> toggle(WishlistItem item) async {
    if (contains(item.variantId)) {
      await remove(item.variantId);
    } else {
      state = [...state, item];
      await _persist();
    }
  }

  Future<void> remove(String variantId) async {
    state = state.where((i) => i.variantId != variantId).toList();
    await _persist();
  }

  Future<void> clear() async {
    state = const [];
    await _storage.delete(_storageKey);
  }

  Future<void> _persist() async {
    await _storage.write(_storageKey, _encode(state));
  }

  Future<void> _persistFrom(List<WishlistItem> items) async {
    await _storage.write(_storageKey, _encode(items));
  }

  String _encode(List<WishlistItem> items) {
    return jsonEncode(items.map((i) => i.toJson()).toList());
  }

  List<WishlistItem> _decode(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WishlistItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}