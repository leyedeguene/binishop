/// BINISHOP — Catalog Controller & Notifier
library features.catalog.presentation.catalog_notifier;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/service_providers.dart';
import '../domain/entities/category.dart';
import '../domain/entities/product.dart';
import '../domain/entities/product_option.dart';
import '../domain/entities/product_variant.dart';

/// Paginated catalog result
class CatalogResult {
  final List<Product> products;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  const CatalogResult({
    this.products = const [],
    this.totalCount = 0,
    this.page = 1,
    this.limit = 20,
    this.hasMore = false,
  });

  static CatalogResult empty() => const CatalogResult();

  CatalogResult copyWith({
    List<Product>? products,
    int? totalCount,
    int? page,
    int? limit,
    bool? hasMore,
  }) {
    return CatalogResult(
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Result for category listings
class CategoryResult {
  final List<Category> categories;
  const CategoryResult({this.categories = const []});
}

/// Catalog query parameters
class CatalogQuery {
  final int page;
  final int limit;
  final String? categoryId;
  final String? collectionId;
  final String? searchQuery;
  final String? sortBy;
  final Map<String, String>? filters;

  const CatalogQuery({
    this.page = 1,
    this.limit = 20,
    this.categoryId,
    this.collectionId,
    this.searchQuery,
    this.sortBy,
    this.filters,
  });

  CatalogQuery copyWith({
    int? page,
    int? limit,
    String? categoryId,
    String? collectionId,
    String? searchQuery,
    String? sortBy,
    Map<String, String>? filters,
    bool clearCategory = false,
    bool clearFilters = false,
  }) {
    return CatalogQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      collectionId: collectionId ?? this.collectionId,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      filters: clearFilters ? null : (filters ?? this.filters),
    );
  }
}

/// State du catalogue (pagination + liste)
class CatalogState {
  final CatalogResult result;
  final CatalogQuery query;
  final bool isLoadingMore;

  const CatalogState({
    this.result = const CatalogResult(),
    this.query = const CatalogQuery(),
    this.isLoadingMore = false,
  });

  CatalogState copyWith({
    CatalogResult? result,
    CatalogQuery? query,
    bool? isLoadingMore,
  }) {
    return CatalogState(
      result: result ?? this.result,
      query: query ?? this.query,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Provider du catalogue — AsyncNotifier
final catalogNotifierProvider =
    AsyncNotifierProvider<CatalogNotifier, CatalogState>(CatalogNotifier.new);

class CatalogNotifier extends AsyncNotifier<CatalogState> {
  @override
  Future<CatalogState> build() async {
    return const CatalogState();
  }

  /// Charge la première page du catalogue
  Future<void> loadCatalog({
    String? categoryId,
    String? collectionId,
    String? q,
    String? sortBy,
  }) async {
    final query = CatalogQuery(
      categoryId: categoryId,
      collectionId: collectionId,
      searchQuery: q,
      sortBy: sortBy,
    );
    state = AsyncData(state.value?.copyWith(query: query) ?? CatalogState(query: query));
    await _loadPage(query);
  }

  /// Charge la page suivante (infinite scroll)
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore) return;
    if (!current.result.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.result.page + 1;
    await _loadPage(current.query.copyWith(page: nextPage), append: true);
  }

  Future<void> _loadPage(CatalogQuery query, {bool append = false}) async {
    try {
      final productService = ref.read(productServiceProvider);
      final result = await productService.getProducts(
        page: query.page,
        limit: query.limit,
        categoryId: query.categoryId,
        collectionId: query.collectionId,
        q: query.searchQuery,
        orderBy: query.sortBy,
      );

      if (result.data == null) {
        state = AsyncError(
          result.error ?? 'Impossible de charger le catalogue',
          StackTrace.current,
        );
        return;
      }

      final products = _parseProducts(result.data?['products'] ?? const []);
      final totalCount = result.data?['count'] ?? 0;
      final newResult = CatalogResult(
        products: append ? [...state.value?.result.products ?? [], ...products] : products,
        totalCount: totalCount,
        page: query.page,
        limit: query.limit,
        hasMore: (query.page * query.limit) < totalCount,
      );

      state = AsyncData(
        state.value?.copyWith(result: newResult, isLoadingMore: false) ??
            CatalogState(result: newResult, query: query),
      );
    } catch (e) {
      state = AsyncError('Erreur lors du chargement du catalogue', StackTrace.current);
    }
  }

  /// Parse les produits venant de l'API Medusa
  List<Product> _parseProducts(List<dynamic>? items) {
    if (items == null) return const [];
    return items.map((raw) {
      final item = Map<String, dynamic>.from(raw as Map);
      final variants = (item['variants'] as List? ?? const [])
          .map((v) => Map<String, dynamic>.from(v as Map))
          .map((v) => ProductVariant(
                id: v['id']?.toString() ?? '',
                title: v['title']?.toString() ?? '',
                sku: v['sku']?.toString(),
                inventoryQuantity: (v['inventory_quantity'] as num?)?.toInt(),
                manageStock: v['manage_stock'] ?? false,
                price: (v['prices'] as List?)?.isNotEmpty ?? false
                    ? ((v['prices'][0]['amount'] as num?)?.toDouble())
                    : null,
              ))
          .toList();
      final options = (item['options'] as List? ?? const [])
          .map((o) => Map<String, dynamic>.from(o as Map))
          .map((o) => ProductOption(
                id: o['id']?.toString() ?? '',
                title: o['title']?.toString() ?? '',
                values:
                    (o['values'] as List? ?? const []).map((v) => v.toString()).toList(),
              ))
          .toList();
      final images = (item['images'] as List? ?? const [])
          .map((i) => i.toString())
          .toList();

      return Product(
        id: item['id']?.toString() ?? '',
        title: item['title']?.toString() ?? '',
        subtitle: item['subtitle']?.toString(),
        description: item['description']?.toString(),
        handle: item['handle']?.toString() ?? '',
        thumbnail: item['thumbnail']?.toString(),
        images: images,
        variants: variants,
        options: options,
        collectionId: item['collection_id']?.toString(),
      );
    }).toList();
  }
}

/// Provider pour lister les catégories store
final categoriesProvider = FutureProvider<CategoryResult>((ref) async {
  final categories = await ref.watch(categoryServiceProvider).getCategories();
  final items = categories.data?['product_categories'] ??
      categories.data?['categories'] ??
      const <dynamic>[];
  return CategoryResult(
    categories: items
        .map((item) => Map<String, dynamic>.from(item as Map))
        .map((item) => Category(
              id: item['id']?.toString() ?? '',
              name: item['name']?.toString() ?? '',
              handle: item['handle']?.toString() ?? '',
              description: item['description']?.toString(),
              image: item['image']?.toString(),
              parentId: item['parent_category_id']?.toString(),
              isActive: item['is_active'] ?? true,
            ))
        .toList(),
  );
});