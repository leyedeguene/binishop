/// BINISHOP — Service Providers (Riverpod)
/// Centralise la création des services applicatifs.
library core.providers.service_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/admin/data/admin_service.dart';
import '../../features/admin/products/admin_product_service.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/cart/data/cart_service.dart';
import '../../features/catalog/data/category_service.dart';
import '../../features/catalog/data/product_service.dart';
import '../../features/checkout/data/checkout_service.dart';
import '../../features/orders/data/order_service.dart';
import '../../features/wishlist/data/wishlist_service.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../storage/token_manager.dart';

// --- Core ---
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager(ref.watch(secureStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenManager = ref.watch(tokenManagerProvider);
  return ApiClient(tokenManager);
});

// --- Feature Services ---
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.watch(apiClientProvider));
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.watch(apiClientProvider));
});

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService(ref.watch(apiClientProvider));
});

final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService(ref.watch(apiClientProvider));
});

final wishlistServiceProvider = Provider<WishlistService>((ref) {
  return WishlistService(ref.watch(apiClientProvider));
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(apiClientProvider));
});

final adminProductServiceProvider = Provider<AdminProductService>((ref) {
  return AdminProductService(ref.watch(apiClientProvider));
});

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.watch(apiClientProvider));
});