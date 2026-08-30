/// BINISHOP — Product Service
library features.catalog.data.product_service;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class ProductService {
  final ApiClient _api;

  ProductService(this._api);

  /// Get published products with pagination
  Future<ApiResult<Map<String, dynamic>>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? collectionId,
    String? q,
    String? orderBy,
    Map<String, String>? filters,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (categoryId != null) 'category_id[]': categoryId,
      if (collectionId != null) 'collection_id[]': collectionId,
      if (q != null) 'q': q,
      if (orderBy != null) 'order': orderBy,
      ...?filters,
    };

    return _api.get<Map<String, dynamic>>(
      ApiConstants.storeProducts,
      queryParameters: params,
      authenticate: false,
    );
  }

  /// Get single product with variants
  Future<ApiResult<Map<String, dynamic>>> getProduct(String id) async {
    return _api.get<Map<String, dynamic>>(
      '${ApiConstants.storeProducts}/$id',
      authenticate: false,
    );
  }

  /// Get products by category
  Future<ApiResult<Map<String, dynamic>>> getProductsByCategory(
    String categoryHandle, {
    int page = 1,
    int limit = 20,
  }) async {
    return getProducts(
      page: page,
      limit: limit,
      categoryId: categoryHandle,
    );
  }

  /// Search products
  Future<ApiResult<Map<String, dynamic>>> searchProducts(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    return getProducts(page: page, limit: limit, q: query);
  }
}