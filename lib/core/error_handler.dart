import 'crash_reporter.dart';
import 'device_app_info.dart';

class AppErrorHandler {
  static Future<void> handle(Object error, StackTrace stack,
      {String? userId,
      String? companyId,
      String? lastScreen,
      String? lastAction}) async {
    final extra = await getDeviceAppInfo(
      userId: userId,
      companyId: companyId,
      lastScreen: lastScreen,
      lastAction: lastAction,
    );
    await CrashReporter.send(error, stack, extra);
  }
}
