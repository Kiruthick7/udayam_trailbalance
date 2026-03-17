import 'package:dio/dio.dart';

class CrashReporter {
  static final _dio = Dio();

  static Future<void> send(
      Object error, StackTrace? stack, Map<String, dynamic> extra) async {
    try {
      // Production: 'https://h32dbgnyv3.execute-api.ap-south-1.amazonaws.com'
      // iOS Simulator: 'http://127.0.0.1:8000'
      // Android Emulator: 'http://10.0.2.2:8000'
      // Physical Device: Use your Mac's IP, e.g., 'http://192.168.1.100:8000'
      await _dio.post(
        'https://h32dbgnyv3.execute-api.ap-south-1.amazonaws.com/log-error', // Production crash log endpoint
        data: {
          'error': error.toString(),
          'stack': stack.toString(),
          ...extra,
        },
      );
    } catch (_) {
      // Optionally queue for retry
    }
  }
}
