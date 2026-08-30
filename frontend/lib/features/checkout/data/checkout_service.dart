/// BINISHOP — Checkout Service
/// Workflow checkout Medusa v2 :
/// adresses -> shipping -> paiement TEST -> completion.
library features.checkout.data.checkout_service;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class CheckoutService {
  final ApiClient _api;

  CheckoutService(this._api);

  /// 1. Email client + adresse de livraison/facturation
  Future<ApiResult<Map<String, dynamic>>> updateCartAddresses({
    required String cartId,
    required String email,
    required Map<String, dynamic> shippingAddress,
    Map<String, dynamic>? billingAddress,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.storeCarts}/$cartId/addresses',
      data: {
        'email': email,
        'shipping_address': shippingAddress,
        if (billingAddress != null) 'billing_address': billingAddress,
      },
    );
  }

  /// 2. Options de livraison disponibles pour le panier
  Future<ApiResult<Map<String, dynamic>>> getShippingOptions({
    required String cartId,
  }) async {
    return _api.get<Map<String, dynamic>>(
      '/store/shipping-options',
      queryParameters: {'cart_id': cartId},
    );
  }

  /// 3. Choisir la methode de livraison
  Future<ApiResult<Map<String, dynamic>>> addShippingMethod({
    required String cartId,
    required String optionId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.storeCarts}/$cartId/shipping-methods',
      data: {'option_id': optionId},
    );
  }

  /// 4. Creer une payment collection (Medusa v2)
  Future<ApiResult<Map<String, dynamic>>> createPaymentCollection({
    required String cartId,
    required String regionId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/store/payment-collections',
      data: {'cart_id': cartId, 'region_id': regionId},
    );
  }

  /// 5. Creer une session de paiement via provider TEST
  Future<ApiResult<Map<String, dynamic>>> createPaymentSession({
    required String collectionId,
    required String providerId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/store/payment-collections/$collectionId/payment-sessions',
      data: {'provider_id': providerId},
    );
  }

  /// 6. Autoriser le paiement (provider TEST : auto-autorise)
  Future<ApiResult<Map<String, dynamic>>> authorizePaymentSession({
    required String collectionId,
    required String sessionId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/store/payment-collections/$collectionId/payment-sessions/$sessionId/authorize',
    );
  }

  /// 7. Finaliser la commande
  Future<ApiResult<dynamic>> completeCart(String cartId) async {
    return _api.post<dynamic>(
      '${ApiConstants.storeCarts}/$cartId/complete',
    );
  }
}