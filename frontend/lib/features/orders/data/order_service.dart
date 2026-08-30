/// BINISHOP — Order Service
library features.orders.data.order_service;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class OrderService {
  final ApiClient _api;

  OrderService(this._api);

  // --- Client ---
  Future<ApiResult<Map<String, dynamic>>> getOrders({
    int page = 1, int limit = 10,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.storeOrders,
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getOrder(String id) async {
    return _api.get<Map<String, dynamic>>('${ApiConstants.storeOrders}/$id');
  }

  // --- Admin ---
  Future<ApiResult<Map<String, dynamic>>> adminGetOrders({
    int page = 1, int limit = 20, String? status,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) params['status'] = status;
    return _api.get<Map<String, dynamic>>(ApiConstants.adminOrders, queryParameters: params);
  }

  Future<ApiResult<Map<String, dynamic>>> adminGetOrder(String id) async {
    return _api.get<Map<String, dynamic>>('${ApiConstants.adminOrders}/$id');
  }

  Future<ApiResult<Map<String, dynamic>>> updateOrderStatus(
    String id, Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>('${ApiConstants.adminOrders}/$id', data: data);
  }
}