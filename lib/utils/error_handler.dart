import 'package:dio/dio.dart';

/// Centralized error handler for the application
class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  AppException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}

class ErrorHandler {
  /// Convert any error to user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }

    return error?.toString() ?? 'An unexpected error occurred';
  }

  /// Handle Dio/HTTP errors
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Please try again.';

      case DioExceptionType.badResponse:
        return _handleStatusCode(error);

      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';

      case DioExceptionType.badCertificate:
        return 'Certificate verification failed. Connection is not secure.';

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'No internet connection. Please check your network.';
        }
        return 'Connection failed. Please try again.';
    }
  }

  /// Handle HTTP status codes
  static String _handleStatusCode(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Try to extract error message from response
    String? serverMessage;
    if (responseData is Map) {
      serverMessage = responseData['message'] ??
          responseData['error'] ??
          responseData['detail'];
    }

    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Invalid request. Please check your input.';

      case 401:
        return 'Session expired. Please login again.';

      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';

      case 404:
        return 'Resource not found. Please try again.';

      case 408:
        return 'Request timeout. Please try again.';

      case 409:
        return serverMessage ?? 'A conflict occurred. Please try again.';

      case 422:
        return serverMessage ?? 'Invalid data. Please check your input.';

      case 429:
        return 'Too many requests. Please wait a moment and try again.';

      case 500:
        return 'Server error. Please try again later.';

      case 502:
        return 'Server is temporarily unavailable. Please try again later.';

      case 503:
        return 'Service is temporarily unavailable. Please try again later.';

      case 504:
        return 'Gateway timeout. Please try again later.';

      default:
        if (statusCode != null && statusCode >= 500) {
          return 'Server error ($statusCode). Please try again later.';
        }
        return serverMessage ?? 'An error occurred. Please try again.';
    }
  }

  /// Check if error is authentication related
  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    return false;
  }

  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown &&
              (error.message?.contains('SocketException') ?? false);
    }
    return false;
  }
}
