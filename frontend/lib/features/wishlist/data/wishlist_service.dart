/// BINISHOP — Wishlist Service
library features.wishlist.data.wishlist_service;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class WishlistService {
  final ApiClient _api;

  WishlistService(this._api);

  Future<ApiResult<Map<String, dynamic>>> getWishlist() async {
    return _api.get<Map<String, dynamic>>(ApiConstants.storeWishlist);
  }

  Future<ApiResult<Map<String, dynamic>>> addToWishlist({
    required String variantId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiConstants.storeWishlist,
      data: {'variant_id': variantId},
    );
  }

  Future<ApiResult<Map<String, dynamic>>> removeFromWishlist(String itemId) async {
    return _api.delete<Map<String, dynamic>>(
      '${ApiConstants.storeWishlist}/$itemId',
    );
  }
}