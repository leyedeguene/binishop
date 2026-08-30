/// BINISHOP — Admin Service
/// Regroupe tous les appels aux endpoints admin Medusa.jS.
/// Les widgets ne font JAMAIS d'appels HTTP directement (règle #56).
/// Le backend reste l'unique source de vérité (règles ZÉRO FAUSSE DONNÉE).
library features.admin.data.admin_service;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class AdminService {
  final ApiClient _api;

  AdminService(this._api);

  // ---- Analytics / Dashboard ----

  Future<ApiResult<Map<String, dynamic>>> getAnalytics({
    String period = '30d',
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.adminAnalytics,
      queryParameters: {'period': period},
    );
  }

  // ---- Catégories ----

  Future<ApiResult<Map<String, dynamic>>> getCategories({
    int? limit,
    int? offset,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.adminCategories,
      queryParameters: {'limit': limit, 'offset': offset},
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getCategory(String id) async {
    return _api.get<Map<String, dynamic>>(
      '${ApiConstants.adminCategory}$id',
    );
  }

  Future<ApiResult<Map<String, dynamic>>> createCategory(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiConstants.adminCategories,
      data: data,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.adminCategory}$id',
      data: data,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> deleteCategory(String id) async {
    return _api.delete<Map<String, dynamic>>(
      '${ApiConstants.adminCategory}$id',
    );
  }

  // ---- Collections ----

  Future<ApiResult<Map<String, dynamic>>> getCollections() async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.adminCollections,
      queryParameters: {'limit': 100},
    );
  }

  Future<ApiResult<Map<String, dynamic>>> createCollection(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiConstants.adminCollections,
      data: data,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> updateCollection(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.adminCollection}$id',
      data: data,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> deleteCollection(String id) async {
    return _api.delete<Map<String, dynamic>>(
      '${ApiConstants.adminCollection}$id',
    );
  }

  // ---- Commandes ----

  Future<ApiResult<Map<String, dynamic>>> getOrders({
    int limit = 20,
    int offset = 0,
    String? status,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.adminOrders,
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (status != null) 'status': status,
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getOrder(String id) async {
    return _api.get<Map<String, dynamic>>(
      '${ApiConstants.adminOrder}$id',
    );
  }

  // ---- Clients ----

  Future<ApiResult<Map<String, dynamic>>> getCustomers({
    int limit = 20,
    int offset = 0,
    String? q,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.adminCustomers,
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (q != null) 'q': q,
      },
    );
  }

  // ---- Homepage ----

  Future<ApiResult<Map<String, dynamic>>> getHomepageBlocks() async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.adminHomepage,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> createHomepageBlock(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiConstants.adminHomepage,
      data: data,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> updateHomepageBlock(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      '${ApiConstants.adminHomepage}/$id',
      data: data,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> deleteHomepageBlock(String id) async {
    return _api.delete<Map<String, dynamic>>(
      '${ApiConstants.adminHomepage}/$id',
    );
  }

  Future<ApiResult<Map<String, dynamic>>> reorderHomepageBlocks(
    List<Map<String, dynamic>> items,
  ) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.adminHomepage}/reorder',
      data: {'items': items},
    );
  }

  // ---- Promotions / Discounts ----

  Future<ApiResult<Map<String, dynamic>>> getPromotions() async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.adminPromotions,
      queryParameters: {'limit': 100},
    );
  }
}