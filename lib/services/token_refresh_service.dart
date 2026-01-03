import 'dart:convert';
import 'storage_service.dart';
import 'api_service.dart';

/// Service to handle automatic token refresh
class TokenRefreshService {
  static bool _isRefreshing = false;

  /// Check if access token is expired or about to expire, and refresh if needed
  static Future<void> checkAndRefreshToken() async {
    if (_isRefreshing) return;

    try {
      final accessToken = await StorageService.getAccessToken();
      final refreshToken = await StorageService.getRefreshToken();

      if (accessToken == null || refreshToken == null) return;

      // Decode JWT to check expiry
      if (_isTokenExpiringSoon(accessToken)) {
        _isRefreshing = true;

        final apiService = ApiService();
        final data = await apiService.refreshToken(refreshToken);

        await StorageService.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );

        _isRefreshing = false;
      }
    } catch (e) {
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
