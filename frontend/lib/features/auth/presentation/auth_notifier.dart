/// BINISHOP — Auth Notifier & Providers
/// Gestion d'état de l'authentification (client + admin).
library features.auth.presentation.auth_notifier;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/storage/token_manager.dart';

/// État d'authentification
class AuthState {
  final bool isAuthenticated;
  final bool isAdmin;
  final bool isLoading;
  final String? error;
  final String? email;
  final String role;

  const AuthState({
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.isLoading = false,
    this.error,
    this.email,
    this.role = 'customer',
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isAdmin,
    bool? isLoading,
    String? error,
    String? email,
    String? role,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin: isAdmin ?? this.isAdmin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

/// Provider d'authentification
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(tokenManagerProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final dynamic _authService;
  final TokenManager _tokenManager;

  AuthNotifier(this._authService, this._tokenManager)
      : super(const AuthState());

  /// Connexion client
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result.data == null) {
        state = state.copyWith(
          isLoading: false,
          error: result.error ?? 'Identifiants invalides.',
        );
        return false;
      }

      final data = result.data!;
      await _tokenManager.saveSession(
        accessToken: data['access_token']?.toString() ?? '',
        refreshToken: data['refresh_token']?.toString() ?? '',
        role: 'customer',
        userId: data['id']?.toString() ?? '',
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isAdmin: false,
        role: 'customer',
        email: email,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la connexion.',
      );
      return false;
    }
  }

  /// Connexion administrateur
  Future<bool> adminLogin({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authService.adminLogin(
        email: email,
        password: password,
      );

      if (result.data == null) {
        state = state.copyWith(
          isLoading: false,
          error: result.error ?? 'Accès refusé.',
        );
        return false;
      }

      final data = result.data!;
      await _tokenManager.saveSession(
        accessToken: data['access_token']?.toString() ?? '',
        refreshToken: data['refresh_token']?.toString() ?? '',
        role: 'admin',
        userId: data['user']?['id']?.toString() ?? '',
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isAdmin: true,
        role: 'admin',
        email: email,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la connexion admin.',
      );
      return false;
    }
  }

  /// Inscription client
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (result.error != null) {
        state = state.copyWith(isLoading: false, error: result.error);
        return false;
      }

      // Après inscription, connexion automatique
      return await login(email: email, password: password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de l\'inscription.',
      );
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _tokenManager.clearTokens();
    state = const AuthState();
  }

  /// Restaure une session existante au démarrage
  Future<void> restoreSession() async {
    final isAuth = await _tokenManager.isAuthenticated();
    if (!isAuth) return;
    final role = await _tokenManager.getUserRole();
    state = state.copyWith(
      isAuthenticated: true,
      isAdmin: role == 'admin' || role == 'super_admin',
      role: role ?? 'customer',
    );
  }

  void clearError() {
    state = state.copyWith();
  }
}