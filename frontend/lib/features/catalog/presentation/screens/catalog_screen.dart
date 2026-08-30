/// BINISHOP — Catalog Screen
/// Grille produits avec recherche, filtres et pagination infinie.
library features.catalog.presentation.screens.catalog_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/states/empty_state.dart';
import '../../../../shared/states/error_state.dart';
import '../../../../shared/states/loading_state.dart';
import '../catalog_notifier.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Chargement initial des données réelles depuis Medusa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(catalogNotifierProvider.notifier).loadCatalog();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(catalogNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catalogue'),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: catalogAsync.when(
              loading: () => const LoadingState(useSkeleton: true),
              error: (error, stack) => ErrorState(
                message: 'Impossible de charger le catalogue.',
                onRetry: () =>
                    ref.read(catalogNotifierProvider.notifier).loadCatalog(),
              ),
              data: (catalogState) {
                final result = catalogState.result;
                if (result.products.isEmpty) {
                  return const EmptyState(
                    title: 'Aucun produit disponible.',
                    message:
                        'Les produits publiés par la boutique apparaîtront ici.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(catalogNotifierProvider.notifier).loadCatalog(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: result.products.length +
                        (catalogState.isLoadingMore ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= result.products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final product = result.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.go('/product/${product.id}'),
                        onWishlistToggle: () {},
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: TextField(
        controller: _searchController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Rechercher un produit...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(catalogNotifierProvider.notifier)
                        .loadCatalog();
                  },
                )
              : null,
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (value) {
          FocusScope.of(context).unfocus();
          ref.read(catalogNotifierProvider.notifier).loadCatalog(
                q: value.trim().isEmpty ? null : value.trim(),
              );
        },
      ),
    );
  }
}
