/// BINISHOP — Client Shell
/// Structure commune de l'application client :
/// header, navigation, footer responsive.
library features.home.presentation.screens.client_shell;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ClientShell extends StatefulWidget {
  final Widget child;
  final int selectedIndex;

  const ClientShell({
    super.key,
    required this.child,
    this.selectedIndex = 0,
  });

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isMobile),
            Expanded(child: widget.child),
            if (!isMobile) _buildFooter(context),
          ],
        ),
      ),
      bottomNavigationBar: isMobile ? _buildMobileNav(context) : null,
    );
  }

  /// --- Header commun ---
  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          if (isMobile) _buildMobileMenu(context),
          _buildLogo(context),
          if (!isMobile) ...[
            AppSpacing.gapWXl,
            Expanded(child: _buildNavLinks(context)),
            _buildSearchIcon(context),
            AppSpacing.gapWSm,
            _buildFavoritesIcon(context),
            AppSpacing.gapWSm,
            _buildAccountIcon(context),
            AppSpacing.gapWSm,
            _buildCartIcon(context),
          ] else ...[
            const Spacer(),
            _buildSearchIcon(context),
            AppSpacing.gapWSm,
            _buildFavoritesIcon(context),
            AppSpacing.gapWSm,
            _buildCartIcon(context),
          ],
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/'),
      child: Text(
        'BINISHOP',
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        onPressed: () => _openDrawer(context),
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
  Widget _buildNavLinks(BuildContext context) {
    const links = <(String, String)>[
      ('Accueil', '/'),
      ('Catégories', '/catalog'),
      ('Nouveautés', '/catalog'),
      ('Bestsellers', '/catalog'),
      ('Promotions', '/catalog'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (label, path) in links)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextButton(
              onPressed: () => context.go(path),
              child: Text(label, style: AppTypography.labelMedium),
            ),
          ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    String? badge,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: badge != null
          ? Badge(
              label: Text(badge),
              child: Icon(icon, color: AppColors.textPrimary),
            )
          : Icon(icon, color: AppColors.textPrimary),
    );
  }

  Widget _buildSearchIcon(BuildContext context) =>
      _buildIconButton(icon: Icons.search, onPressed: () => context.go('/catalog'));

  Widget _buildFavoritesIcon(BuildContext context) =>
      _buildIconButton(icon: Icons.favorite_border, onPressed: () => context.go('/wishlist'));

  Widget _buildAccountIcon(BuildContext context) =>
      _buildIconButton(icon: Icons.person_outline, onPressed: () => context.go('/profile'));

  Widget _buildCartIcon(BuildContext context) =>
      _buildIconButton(icon: Icons.shopping_bag_outlined, badge: '0', onPressed: () => context.go('/cart'));

  Widget _buildMobileNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
          case 1:
            context.go('/catalog');
          case 2:
            context.go('/wishlist');
          case 3:
            context.go('/profile');
          case 4:
            context.go('/cart');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Catalogue'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: 'Favoris'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Compte'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Panier'),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BINISHOP',
                style: AppTypography.titleLarge.copyWith(color: AppColors.textOnPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Mode e-commerce premium',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('Catalogue', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => context.go('/orders'),
                child: const Text('Commandes', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => context.go('/profile'),
                child: const Text('Compte', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}