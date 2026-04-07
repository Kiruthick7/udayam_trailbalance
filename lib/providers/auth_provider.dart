import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final Map<String, dynamic>? user;
  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  /// UPDATE USER ID (internally, without logout)
  Future<void> updateUserId(String newUserId) async {
    // Update user_id in storage and in-memory state
    final userData = await StorageService.getUserData();
    if (userData != null) {
      userData['user_id'] = newUserId;
      await StorageService.saveUserData(userData);
      state = state.copyWith(user: userData);
    }
  }

  late final ApiService api;

  @override
  AuthState build() {
    api = ref.read(apiServiceProvider);
    return AuthState();
  }

  /// LOGIN
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await api.login(email, password);

      // NEW: store BOTH tokens
      await StorageService.saveTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );

      // Save user data to storage
      await StorageService.saveUserData(data['user']);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: data['user'],
      );
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// LOGOUT
  Future<void> logout({bool revokeServerToken = true}) async {
    try {
      if (revokeServerToken) {
        // Avoid blocking UI flows (like app startup) on network issues.
        await api.logout().timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // ignore
    } finally {
      await StorageService.clearAll();
      state = AuthState();
    }
  }

  /// CHECK AUTH (on app start)
  Future<void> checkAuth() async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken != null) {
      final userData = await StorageService.getUserData();
      if (userData == null) {
        await logout(
          revokeServerToken: false,
        ); // Startup must not wait on network
        return;
      }
      state = state.copyWith(
        isAuthenticated: true,
        user: userData,
      );
    } else {
      await logout(
        revokeServerToken: false,
      ); // Startup must not wait on network
    }
  }

  /// REFRESH TOKEN (silent, without changing state)
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final data = await api.refreshToken(refreshToken);

      await StorageService.saveTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );

      return true;
    } catch (e) {
      // Token refresh failed - do not logout, just return false
      return false;
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
