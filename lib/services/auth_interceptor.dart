import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import '../main.dart';
import '../screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _queue = [];

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check and refresh token before making the request
    if (!options.path.contains('/auth/login') &&
        !options.path.contains('/auth/refresh')) {
      await _checkAndRefreshTokenIfNeeded();
    }

    final token = await StorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Check if token needs refresh before making request
  Future<void> _checkAndRefreshTokenIfNeeded() async {
    if (_isRefreshing) return;

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) return;

      // Decode JWT to check if expiring within 2 minutes
      if (_isTokenExpiringSoon(accessToken)) {
        final refreshToken = await StorageService.getRefreshToken();
        if (refreshToken == null) return;

        _isRefreshing = true;

        final response = await dio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        await StorageService.saveTokens(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token'],
        );

        _isRefreshing = false;
      }
    } catch (e) {
      _isRefreshing = false;
    }
  }

  /// Check if token is expiring within 2 minutes
  bool _isTokenExpiringSoon(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = payload.padRight(
        (payload.length + 3) ~/ 4 * 4,
        '=',
      );
      final decoded = utf8.decode(base64.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Refresh if expiring within 2 minutes
      return expiryDate.isBefore(now.add(const Duration(minutes: 2)));
    } catch (e) {
      // If decoding fails, assume token is expiring to trigger refresh
      return true;
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Skip refresh for auth endpoints
      if (requestOptions.path.contains('/auth/login') ||
          requestOptions.path.contains('/auth/refresh')) {
        return handler.next(err);
      }

      if (_isRefreshing) {
        _queue.add(requestOptions);
        return;
      }

      _isRefreshing = true;

      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        _isRefreshing = false;
        await StorageService.clearAll();
        _navigateToLogin();
        return handler.next(err);
      }

      try {
        final response = await dio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        await StorageService.saveTokens(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token'],
        );

        final newAccessToken = await StorageService.getAccessToken();

        // Retry queued requests
        for (final req in _queue) {
          req.headers['Authorization'] = 'Bearer $newAccessToken';
          try {
            await dio.fetch(req);
          } catch (e) {
            // Ignore errors from queued requests
          }
        }
        _queue.clear();

        // Retry the original request
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        _isRefreshing = false;

        // Automatically retry the request without showing error to user
        try {
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        } catch (retryError) {
          return handler.next(err);
        }
      } catch (refreshError) {
        // Token refresh failed - clear storage and redirect to login
        _isRefreshing = false;
        _queue.clear();
        await StorageService.clearAll();

        // Navigate to login screen
        _navigateToLogin();

        return handler.next(err);
      }
    }

    handler.next(err);
  }

  /// Navigate to login screen when session expires
  void _navigateToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Show session expired message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      });

      // Navigate to login and clear all routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
