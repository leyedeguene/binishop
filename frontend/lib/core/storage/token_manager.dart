/// BINISHOP — Token Manager
/// Gestion sécurisée des tokens JWT.
library core.storage.token_manager;

import '../config/environment.dart';
import 'secure_storage.dart';

class TokenManager {
  final SecureStorage _storage;

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userRoleKey = 'auth_user_role';
  static const _userIdKey = 'auth_user_id';

  TokenManager(this._storage);

  String get baseUrl => Environment.apiBaseUrl;

  // --- Access Token ---
  Future<void> saveAccessToken(String token) async {
    await _storage.write(_accessTokenKey, token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(_accessTokenKey);
  }

  // --- Refresh Token ---
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(_refreshTokenKey);
  }

  // --- User Role ---
  Future<void> saveUserRole(String role) async {
    await _storage.write(_userRoleKey, role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(_userRoleKey);
  }

  // --- User ID ---
  Future<void> saveUserId(String id) async {
    await _storage.write(_userIdKey, id);
  }

  Future<String?> getUserId() async {
    return await _storage.read(_userIdKey);
  }

  // --- Session ---
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin' || role == 'super_admin';
  }

  Future<void> clearTokens() async {
    await _storage.delete(_accessTokenKey);
    await _storage.delete(_refreshTokenKey);
    await _storage.delete(_userRoleKey);
    await _storage.delete(_userIdKey);
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String userId,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    await saveUserRole(role);
    await saveUserId(userId);
  }
}