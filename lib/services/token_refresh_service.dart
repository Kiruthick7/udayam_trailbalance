import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../screens/login_screen.dart';
import 'storage_service.dart';
import 'api_service.dart';

/// Service to handle automatic token refresh
class TokenRefreshService {
  static bool _isRefreshing = false;
  static Completer<void>? _refreshCompleter;

  /// Centralized token refresh with retry and user feedback
  static Future<void> checkAndRefreshToken({BuildContext? context}) async {
    if (_isRefreshing) {
      await _refreshCompleter?.future;
      return;
    }
    _isRefreshing = true;
    _refreshCompleter = Completer<void>();
    try {
      final accessToken = await StorageService.getAccessToken();
      final refreshToken = await StorageService.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        _isRefreshing = false;
        _refreshCompleter?.complete();
        return;
      }

      // Decode JWT to check expiry
      if (_isTokenExpiringSoon(accessToken)) {
        final apiService = ApiService();
        int retry = 0;
        const maxRetries = 2;
        while (retry <= maxRetries) {
          try {
            final data = await apiService.refreshToken(refreshToken);
            await StorageService.saveTokens(
              accessToken: data['access_token'],
              refreshToken: data['refresh_token'],
            );
            _isRefreshing = false;
            _refreshCompleter?.complete();
            return;
          } catch (e) {
            // If refresh token expired or invalid, force logout and show message
            if (e is DioException && e.response?.statusCode == 401) {
              await StorageService.clearAll();
              if (context != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session expired. Please log in again.'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                });
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
              _isRefreshing = false;
              _refreshCompleter?.complete();
              return;
            }
            // Retry on network error
            if (retry < maxRetries) {
              retry++;
              await Future.delayed(const Duration(seconds: 2));
              continue;
            } else {
              // Give up after retries
              break;
            }
          }
        }
      }
    } finally {
      _isRefreshing = false;
      _refreshCompleter?.complete();
    }
  }

  /// Check if token is expired or expiring within 5 minutes
  static bool _isTokenExpiringSoon(String token) {
    try {
      // JWT structure: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload (base64url)
      final payload = parts[1];
      final normalized = payload.padRight(
        (payload.length + 3) ~/ 4 * 4,
        '=',
      );
      final decoded = utf8.decode(base64.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // Check expiry
      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Refresh if expired or expiring within 5 minutes
      const bufferMinutes = 5;
      return expiryDate
          .isBefore(now.add(const Duration(minutes: bufferMinutes)));
    } catch (e) {
      // If we can't decode, assume it's expired
      return true;
    }
  }
}
