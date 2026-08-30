/// BINISHOP — API Interceptor
/// Gère l'authentification et le refresh token.
library core.network.api_interceptor;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../storage/token_manager.dart';

class ApiInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  final Logger _logger;

  ApiInterceptor(this._tokenManager, this._logger);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Ne pas ajouter de token pour les requêtes d'auth
    if (!options.path.contains('/auth/') && !options.path.contains('/store/auth')) {
      final token = await _tokenManager.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Capturer le token JWT dans la réponse d'auth
    if (response.data is Map && response.data?['access_token'] != null) {
      _tokenManager.saveAccessToken(response.data['access_token']);
    }
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expiré — tenter un refresh
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Réessayer la requête originale
        try {
          final options = err.requestOptions;
          final token = await _tokenManager.getAccessToken();
          options.headers['Authorization'] = 'Bearer $token';
          final response = await Dio().fetch(options);
          handler.resolve(response);
          return;
        } catch (_) {
          // Refresh failed — déconnexion
          await _tokenManager.clearTokens();
        }
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${_tokenManager.baseUrl}/auth/token/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data?['access_token'] != null) {
        await _tokenManager.saveAccessToken(response.data['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Token refresh failed: $e');
      return false;
    }
  }
}