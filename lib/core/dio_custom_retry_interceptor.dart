import 'package:dio/dio.dart';
import 'dart:async';

class CustomRetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  CustomRetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    var retries = err.requestOptions.extra['retries'] ?? 0;
    if (_shouldRetry(err) && retries < maxRetries) {
      await Future.delayed(retryDelay);
      final options = err.requestOptions;
      options.extra['retries'] = retries + 1;
      try {
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } catch (_) {
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
