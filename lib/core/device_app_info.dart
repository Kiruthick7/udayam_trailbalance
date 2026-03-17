import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<Map<String, dynamic>> getDeviceAppInfo(
    {String? userId,
    String? companyId,
    String? lastScreen,
    String? lastAction}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final deviceInfoPlugin = DeviceInfoPlugin();
  final deviceInfo = await deviceInfoPlugin.deviceInfo;
  return {
    'appVersion': packageInfo.version,
    'device': deviceInfo.data,
    if (userId != null) 'userId': userId,
    if (companyId != null) 'companyId': companyId,
    if (lastScreen != null) 'lastScreen': lastScreen,
    if (lastAction != null) 'action': lastAction,
  };
}
