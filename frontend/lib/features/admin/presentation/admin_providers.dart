/// BINISHOP — Admin Providers (Riverpod)
/// Gestion d'état des écrans d'administration.
library features.admin.presentation.admin_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';

/// Analytics dashboard, rafraîchi par période.
final adminAnalyticsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, period) async {
  final result = await ref
      .watch(adminServiceProvider)
      .getAnalytics(period: period);
  if (result.data != null) return result.data!;
  throw StateError(result.error ?? 'Impossible de charger les statistiques');
});

/// Liste des catégories (admin).
final adminCategoriesProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, refresh) async {
  final result = await ref.watch(adminServiceProvider).getCategories(limit: 200);
  if (result.data != null) return result.data!;
  throw StateError(result.error ?? 'Impossible de charger les catégories');
});

/// Liste des collections (admin).
final adminCollectionsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, refresh) async {
  final result = await ref.watch(adminServiceProvider).getCollections();
  if (result.data != null) return result.data!;
  throw StateError(result.error ?? 'Impossible de charger les collections');
});

/// Liste des commandes (admin).
final adminOrdersProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, refresh) async {
  final result = await ref.watch(adminServiceProvider).getOrders(limit: 100);
  if (result.data != null) return result.data!;
  throw StateError(result.error ?? 'Impossible de charger les commandes');
});

/// Liste des clients (admin).
final adminCustomersProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, refresh) async {
  final result = await ref.watch(adminServiceProvider).getCustomers(limit: 100);
  if (result.data != null) return result.data!;
  throw StateError(result.error ?? 'Impossible de charger les clients');
});

/// Blocs homepage (admin).
final adminHomepageProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, refresh) async {
  final result = await ref.watch(adminServiceProvider).getHomepageBlocks();
  if (result.data != null) return result.data!;
  throw StateError(result.error ?? 'Impossible de charger la homepage');
});

/// Produits (admin) via AdminProductService.
final adminProductsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, refresh) async {
  final result = await ref
      .watch(adminProductServiceProvider)
      .getProducts(limit: 100);
  if (result.data != null) return result.data!;
  throw StateError(result.error ?? 'Impossible de charger les produits');
});

/// Promotions (admin).
final adminPromotionsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, refresh) async {
  final result = await ref.watch(adminServiceProvider).getPromotions();
  if (result.data != null) return result.data!;
  throw StateError(result.error ?? 'Impossible de charger les promotions');
});