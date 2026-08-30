/// BINISHOP — Cart Service
library features.cart.data.cart_service;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class CartService {
  final ApiClient _api;

  CartService(this._api);

  Future<ApiResult<Map<String, dynamic>>> createCart() async {
    return _api.post<Map<String, dynamic>>(
      ApiConstants.storeCarts,
      data: {},
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getCart(String cartId) async {
    return _api.get<Map<String, dynamic>>(
      '${ApiConstants.storeCarts}/$cartId',
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> addLineItem({
    required String cartId,
    required String variantId,
    required int quantity,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.storeCarts}/$cartId/line-items',
      data: {
        'variant_id': variantId,
        'quantity': quantity,
      },
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> updateLineItem({
    required String cartId,
    required String lineItemId,
    required int quantity,
  }) async {
    return _api.put<Map<String, dynamic>>(
      '${ApiConstants.storeCarts}/$cartId/line-items/$lineItemId',
      data: {'quantity': quantity},
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> removeLineItem({
    required String cartId,
    required String lineItemId,
  }) async {
    return _api.delete<Map<String, dynamic>>(
      '${ApiConstants.storeCarts}/$cartId/line-items/$lineItemId',
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> setShippingMethod({
    required String cartId,
    required String shippingMethodId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.storeCarts}/$cartId/shipping-methods',
      data: {'option_id': shippingMethodId},
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> setPaymentSession({
    required String cartId,
    required String providerId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.storeCarts}/$cartId/payment-sessions',
      data: {'provider_id': providerId},
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> completeCheckout(String cartId) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.storeCarts}/$cartId/complete-checkout',
      authenticate: false,
    );
  }
}