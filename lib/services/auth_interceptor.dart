import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import '../core/navigation_service.dart';
import '../screens/login_screen.dart';
import 'token_refresh_service.dart';
import 'package:flutter/material.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check and refresh token before making the request
    if (!options.path.contains('/auth/login') &&
        !options.path.contains('/auth/refresh')) {
      await TokenRefreshService.checkAndRefreshToken(
          context: NavigationService.navigatorKey.currentContext);
    }

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
      final responseData = err.response?.data;
      String? serverMessage;
      if (responseData is Map) {
        serverMessage = responseData['message'] ??
            responseData['error'] ??
            responseData['detail'];
      } else if (responseData is String) {
        serverMessage = responseData;
      }

      // If session invalidated, force logout immediately
      if (serverMessage != null &&
          serverMessage.toLowerCase().contains('session invalidated')) {
        await StorageService.clearAll();
        _navigateToLogin();
        return handler.next(err);
      }

      // Skip refresh for auth endpoints
      if (requestOptions.path.contains('/auth/login') ||
          requestOptions.path.contains('/auth/refresh')) {
        return handler.next(err);
      }

      // Use centralized refresh logic
      await TokenRefreshService.checkAndRefreshToken(
          context: NavigationService.navigatorKey.currentContext);

      final newAccessToken = await StorageService.getAccessToken();
      if (newAccessToken != null) {
        // Retry the original request with new token
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        } catch (retryError) {
          // If retry fails, fall through to logout
        }
      }

      // If refresh failed, clear storage and redirect to login
      await StorageService.clearAll();
      _navigateToLogin();
      return handler.next(err);
    }

    handler.next(err);
  }

  /// Navigate to login screen when session expires
  void _navigateToLogin() {
    final context = NavigationService.navigatorKey.currentContext;
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
