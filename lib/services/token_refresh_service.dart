import 'dart:convert';
import 'storage_service.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

/// Service to handle automatic token refresh
class TokenRefreshService {
  static bool _isRefreshing = false;

  /// Check if access token is expired or about to expire, and refresh if needed
  static Future<void> checkAndRefreshToken() async {
    if (_isRefreshing) {
      if (kDebugMode) print('[TokenRefresh] Already refreshing, skipping...');
      return;
    }

    try {
      final accessToken = await StorageService.getAccessToken();
      final refreshToken = await StorageService.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        if (kDebugMode) print('[TokenRefresh] No tokens found, skipping...');
        return;
      }

      // Decode JWT to check expiry
      if (_isTokenExpiringSoon(accessToken)) {
        if (kDebugMode)
          print('[TokenRefresh] Token expiring soon, refreshing...');
        _isRefreshing = true;

        final apiService = ApiService();
        final data = await apiService.refreshToken(refreshToken);

        await StorageService.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );

        if (kDebugMode) print('[TokenRefresh] Token refreshed successfully');
        _isRefreshing = false;
      } else {
        if (kDebugMode)
          print('[TokenRefresh] Token still valid, no refresh needed');
      }
    } catch (e) {
      if (kDebugMode) print('[TokenRefresh] Error refreshing token: $e');
      _isRefreshing = false;
      // Silent fail - the auth interceptor will handle it on next API call
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
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // Check expiry
      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final timeUntilExpiry = expiryDate.difference(now);

      if (kDebugMode) {
        print(
            '[TokenRefresh] Token expires in: ${timeUntilExpiry.inMinutes} minutes');
      }

      // Refresh if expired or expiring within 5 minutes
      const bufferMinutes = 5;
      return expiryDate
          .isBefore(now.add(const Duration(minutes: bufferMinutes)));
    } catch (e) {
      if (kDebugMode) print('[TokenRefresh] Error decoding token: $e');
      // If we can't decode, assume it's expired
      return true;
    }
  }
}
