/// BINISHOP — Auth Service
library features.auth.data.auth_service;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiConstants.storeAuth}/token',
      data: {
        'email': email,
        'password': password,
      },
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiConstants.storeCustomers,
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      },
      authenticate: false,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getProfile() async {
    return _api.get<Map<String, dynamic>>(
      '${ApiConstants.storeCustomers}/me',
    );
  }

  Future<ApiResult<Map<String, dynamic>>> adminLogin({
    required String email,
    required String password,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/admin/auth/token',
      data: {
        'email': email,
        'password': password,
      },
      authenticate: false,
    );
  }
}