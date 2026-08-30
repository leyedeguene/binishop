/// BINISHOP — Administration Shell
/// Layout de l'espace admin : sidebar (desktop/tablet) + drawer (mobile)
/// + topbar. Toutes les rubriques du menu (MB specs section 9) y figurent.
library features.admin.presentation.admin_shell;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Une entrée de navigation de la sidebar.
class AdminNavItem {
  final String label;
  final String path;
  final IconData icon;
  const AdminNavItem({
    required this.label,
    required this.path,
    required this.icon,
  });
}

class AdminShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AdminShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  static const List<AdminNavItem> navItems = [
    AdminNavItem(label: 'Dashboard', path: '/admin', icon: Icons.dashboard_outlined),
    AdminNavItem(label: 'Produits', path: '/admin/products', icon: Icons.inventory_2_outlined),
    AdminNavItem(label: 'Catégories', path: '/admin/categories', icon: Icons.category_outlined),
    AdminNavItem(label: 'Collections', path: '/admin/collections', icon: Icons.collections_bookmark_outlined),
    AdminNavItem(label: 'Commandes', path: '/admin/orders', icon: Icons.receipt_long_outlined),
    AdminNavItem(label: 'Clients', path: '/admin/customers', icon: Icons.people_outline),
    AdminNavItem(label: 'Homepage', path: '/admin/homepage', icon: Icons.home_outlined),
    AdminNavItem(label: 'Promotions', path: '/admin/promotions', icon: Icons.local_offer_outlined),
    AdminNavItem(label: 'Paramètres', path: '/admin/settings', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) return _buildDesktop(context);
    if (width >= 600) return _buildSidebar(context, width: 220);
    return _buildMobile(context);
  }

  // --- Desktop : sidebar fixe à gauche + topbar ---
  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSidebar(context, width: 260),
          Expanded(
            child: Column(
              children: [
                _topbar(context),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPaddingDesktop,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Tablet : sidebar réduite ---
  Widget _buildSidebar(BuildContext context, {required double width}) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: width,
            color: AppColors.adminSidebar,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSpacing.gapLg,
                  _logo(),
                  AppSpacing.gapXxl,
                  for (final item in navItems) _navTile(context, item),
                  const Spacer(),
                  _logoutTile(context),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _topbar(context),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPaddingTablet,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Mobile : drawer + topbar ---
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.adminTopbar,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.storefront, color: AppColors.secondary),
            AppSpacing.gapWSm,
            Text('Admin', style: AppTypography.titleLarge),
          ],
        ),
        actions: [_storeAction(context)],
      ),
      drawer: Drawer(
        width: 280,
        child: Container(
          color: AppColors.adminSidebar,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.gapLg,
                _logo(),
                AppSpacing.gapXxl,
                for (final item in navItems) _navTile(context, item),
                const Spacer(),
                _logoutTile(context),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingMobile,
        child: child,
      ),
    );
  }

  Widget _navTile(BuildContext context, AdminNavItem item) {
    final selected = currentPath == item.path ||
        (item.path != '/admin' && currentPath.startsWith(item.path));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.radiusMd,
          onTap: () {
            Navigator.of(context).popUntil((_) => true);
            context.go(item.path);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.adminSidebarActive : Colors.transparent,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              children: [
                Icon(item.icon,
                    size: 20,
                    color: selected
                        ? Colors.white
                        : AppColors.adminSidebarText.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Text(item.label,
                    style: AppTypography.labelLarge.copyWith(
                      color: selected
                          ? Colors.white
                          : AppColors.adminSidebarText.withValues(alpha: 0.85),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.radiusMd,
          onTap: () => context.go('/'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.logout, size: 20, color: AppColors.adminSidebarText),
                const SizedBox(width: 12),
                Text('Retour à la boutique',
                    style: AppTypography.labelLarge.copyWith(
                        color: AppColors.adminSidebarText)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topbar(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.adminTopbar,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.dashboard_customize_outlined, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text('Administration',
              style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary)),
          const Spacer(),
          _storeAction(context),
        ],
      ),
    );
  }

  Widget _storeAction(BuildContext context) {
    return IconButton(
      tooltip: 'Retour à la boutique',
      onPressed: () => context.go('/'),
      icon: const Icon(Icons.storefront, color: AppColors.textPrimary),
    );
  }

  Widget _logo() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.storefront, color: AppColors.adminSidebarText),
          SizedBox(width: 8),
          Text('BINISHOP Admin',
              style: TextStyle(
                color: AppColors.adminSidebarText,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              )),
        ],
      ),
    );
  }
}