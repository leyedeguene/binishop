/// BINISHOP — Category Service
library features.catalog.data.category_service;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class CategoryService {
  final ApiClient _api;

  CategoryService(this._api);

  Future<ApiResult<Map<String, dynamic>>> getCategories() async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.storeCategories,
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getCategory(String id) async {
    return _api.get<Map<String, dynamic>>(
      '${ApiConstants.storeCategories}/$id',
      authenticate: false,
    );
  }

  // --- Admin ---
  Future<ApiResult<Map<String, dynamic>>> adminGetCategories() async {
    return _api.get<Map<String, dynamic>>(ApiConstants.adminCategories);
  }

  Future<ApiResult<Map<String, dynamic>>> createCategory(Map<String, dynamic> data) async {
    return _api.post<Map<String, dynamic>>(ApiConstants.adminCategories, data: data);
  }

  Future<ApiResult<Map<String, dynamic>>> updateCategory(
    String id, Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      '${ApiConstants.adminCategories}/$id', data: data,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> deleteCategory(String id) async {
    return _api.delete<Map<String, dynamic>>(
      '${ApiConstants.adminCategories}/$id',
    );
  }
}