import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import '../main.dart';
import '../screens/login_screen.dart';
import 'package:flutter/material.dart';

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
    final token = await StorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
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
