import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';
import 'dart:convert';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final Map<String, dynamic>? user;
  final bool needsPinEntry;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.user,
    this.needsPinEntry = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    Map<String, dynamic>? user,
    bool? needsPinEntry,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      user: user ?? this.user,
      needsPinEntry: needsPinEntry ?? this.needsPinEntry,
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
  Future<void> logout() async {
    try {
      await api.logout(); // optional backend revoke
    } catch (_) {
      // ignore
    } finally {
      await StorageService.clearAll();
      await StorageService.clearPin();
      state = AuthState();
    }
  }

  /// CHECK AUTH (on app start)
  Future<void> checkAuth() async {
    final accessToken = await StorageService.getAccessToken();
    final refreshToken = await StorageService.getRefreshToken();
    if (accessToken != null) {
      // Optionally: Check if token is expired (decode JWT or use expiry timestamp)
      bool isExpired = false;
      try {
        // If your access token is a JWT, decode and check exp
        final parts = accessToken.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final payloadMap = json.decode(decoded);
          if (payloadMap is Map<String, dynamic> &&
              payloadMap.containsKey('exp')) {
            final exp = payloadMap['exp'];
            final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
            isExpired = DateTime.now().isAfter(expiry);
          }
        }
      } catch (e) {
        isExpired = true;
      }

      if (isExpired && refreshToken != null) {
        state = state.copyWith(needsPinEntry: true);
        return;
      } else if (isExpired) {
        await logout();
        return;
      }

      final userData = await StorageService.getUserData();
      if (userData == null) {
        await logout();
        return;
      }
      state = state.copyWith(
        isAuthenticated: true,
        user: userData,
        needsPinEntry: false,
      );
    } else {
      await logout();
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
      // Token refresh failed - logout
      await logout();
      return false;
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
