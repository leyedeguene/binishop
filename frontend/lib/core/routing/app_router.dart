/// BINISHOP — Application Router
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/screens/admin_categories_screen.dart';
import '../../features/admin/presentation/screens/admin_collections_screen.dart';
import '../../features/admin/presentation/screens/admin_customers_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_homepage_screen.dart';
import '../../features/admin/presentation/screens/admin_orders_screen.dart';
import '../../features/admin/presentation/screens/admin_products_screen.dart';
import '../../features/admin/presentation/screens/admin_promotions_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/home/presentation/screens/client_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../storage/secure_storage.dart';
import '../storage/token_manager.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final tokenManager = TokenManager(SecureStorage());
  return AppRouter.create(tokenManager: tokenManager);
});

class AppRouter {
  static GoRouter create({required TokenManager tokenManager}) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) async {
        final isAuth = await tokenManager.isAuthenticated();
        final isAdminRoute = state.matchedLocation.startsWith('/admin');
        final isLoginRoute = state.matchedLocation.startsWith('/auth');
        final isAdminLogin = state.uri.queryParameters['admin'] == 'true';
        if (isAdminRoute && !isAuth) return '/auth/login?admin=true';
        if (isAuth && isLoginRoute) {
          if (isAdminLogin || await tokenManager.isAdmin()) return '/admin';
          return '/';
        }
        if (state.matchedLocation.startsWith('/checkout') && !isAuth) {
          return '/auth/login';
        }
        return null;
      },
      routes: [
        // ========== CLIENT ==========
        GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/catalog',
          name: 'catalog',
          builder: (_, __) => const ClientShell(selectedIndex: 1, child: CatalogScreen()),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'productDetail',
          builder: (_, state) => ClientShell(
            selectedIndex: 1,
            child: ProductDetailScreen(productId: state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (_, __) => const ClientShell(selectedIndex: 4, child: CartScreen()),
        ),
        GoRoute(path: '/checkout', name: 'checkout', builder: (_, __) => const CheckoutScreen()),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (_, __) => const ClientShell(selectedIndex: 3, child: OrdersScreen()),
        ),
        GoRoute(
          path: '/wishlist',
          name: 'wishlist',
          builder: (_, __) => const ClientShell(selectedIndex: 2, child: WishlistScreen()),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (_, __) => const ClientShell(selectedIndex: 3, child: ProfileScreen()),
        ),
        // ========== AUTH ==========
        GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (_, state) => LoginScreen(
            isAdminMode: state.uri.queryParameters['admin'] == 'true',
          ),
        ),
        GoRoute(path: '/auth/register', name: 'register', builder: (_, __) => const RegisterScreen()),
        // ========== ADMIN ==========
        GoRoute(path: '/admin', name: 'admin', builder: (_, __) => const AdminRouteShell(path: '/admin', child: AdminDashboardScreen())),
        GoRoute(path: '/admin/products', name: 'adminProducts', builder: (_, __) => const AdminRouteShell(path: '/admin/products', child: AdminProductsScreen())),
        GoRoute(path: '/admin/categories', name: 'adminCategories', builder: (_, __) => const AdminRouteShell(path: '/admin/categories', child: AdminCategoriesScreen())),
        GoRoute(path: '/admin/collections', name: 'adminCollections', builder: (_, __) => const AdminRouteShell(path: '/admin/collections', child: AdminCollectionsScreen())),
        GoRoute(path: '/admin/orders', name: 'adminOrders', builder: (_, __) => const AdminRouteShell(path: '/admin/orders', child: AdminOrdersScreen())),
        GoRoute(path: '/admin/customers', name: 'adminCustomers', builder: (_, __) => const AdminRouteShell(path: '/admin/customers', child: AdminCustomersScreen())),
        GoRoute(path: '/admin/homepage', name: 'adminHomepage', builder: (_, __) => const AdminRouteShell(path: '/admin/homepage', child: AdminHomepageScreen())),
        GoRoute(path: '/admin/promotions', name: 'adminPromotions', builder: (_, __) => const AdminRouteShell(path: '/admin/promotions', child: AdminPromotionsScreen())),
        GoRoute(path: '/admin/settings', name: 'adminSettings', builder: (_, __) => const AdminRouteShell(path: '/admin/settings', child: AdminSettingsScreen())),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Color(0xFFDC2626)),
              const SizedBox(height: 16),
              Text('Page introuvable', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/'),
                child: const Text('Accueil'),
              ),
            ],
          ),
        ),
      ),
    );
    }
}

class AdminRouteShell extends StatelessWidget {
  final String path;
  final Widget child;
  const AdminRouteShell({super.key, required this.path, required this.child});

  @override
  Widget build(BuildContext context) => AdminShell(currentPath: path, child: child);
}
