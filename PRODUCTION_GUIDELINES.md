# Udayam Trial Balance Production Guidelines

## 1. Remove Debug Logs
- Search for all debug log statements (e.g., `_logger.i`, `print`, etc.).
- Remove them or wrap with:
  ```dart
  if (kDebugMode) {
    _logger.i(...);
  }
  ```
- This ensures no sensitive/debug info is logged in production builds.

## 2. Privacy Policy
- Use the provided template below.
- Fill in the effective date and your contact email.
- Host the policy on a public URL (GitHub Pages, company website, or Notion).
- Add the URL to your Play Store/App Store listing.

### Privacy Policy Template

**Privacy Policy for Udayam Trial Balance**

Effective Date: [ADD DATE]

Udayam Trial Balance ("we", "our", or "us") operates the Udayam mobile application.

This page informs users regarding our policies with the collection, use, and disclosure of personal information.

#### 1. Information We Collect
- Account Information: Username, company details
- Authentication Data: Session tokens for login
- Device Information: Device type, OS version (for performance and debugging)
- Usage Data: App interactions for improving user experience

We do NOT collect:
- Personal contacts
- Photos or media (unless explicitly required for features)

#### 2. How We Use Information
- Provide and maintain app functionality
- Authenticate users securely
- Improve app performance and features
- Detect and prevent fraud or misuse

#### 3. Data Storage & Security
- Data is stored securely using encrypted storage
- Sensitive data (like tokens) is stored using secure storage mechanisms
- We implement industry-standard security practices

#### 4. Third-Party Services
- Analytics tools
- Crash reporting tools

These services may collect limited information for debugging and performance monitoring.

#### 5. Data Sharing
- We do NOT sell or share user data with third parties except:
  - When required by law
  - To protect our legal rights

#### 6. User Rights
- Users can request deletion of their data
- Users can log out and clear stored credentials

#### 7. Changes to This Policy
- We may update this policy from time to time. Changes will be reflected on this page.

#### 8. Contact Us
- If you have questions, contact us at: [YOUR EMAIL HERE]

---

## 3. Architecture Cleanup
- Refactor codebase to recommended folder structure for scalability:
  ```
  lib/
    core/
    data/
    features/
    shared/
    main.dart
  ```
- Add a repository layer between providers and services for testability and separation.
- Implement a global error handler (e.g., `AppErrorHandler`).
- Use a navigation service for cleaner navigation logic.

## 4. Crash Reporting (AWS CloudWatch)
- Add a global error handler in `main.dart` to catch all errors.
- Implement a `CrashReporter` class using Dio to POST errors to your API Gateway endpoint.
- Set up AWS Lambda to receive and log errors to CloudWatch.

## 5. Add Device, User, and App Info to Crash Reports
- Include device info, user/company IDs, app version, and breadcrumbs (last screen/action) in your error payloads.

## 6. Bonus Improvements
- Add a Dio retry interceptor for network resilience.
- Create a reusable loading state widget.
- Add offline crash queue logic if needed.

---

## Next Steps
- Follow each section above to make your app production-ready.
- For detailed code samples or step-by-step setup, see the project documentation or request specific help.

# Udayam Trial Balance Production Steps: Architecture, Crash Reporting, and Improvements

---

## 3. Architecture Cleanup

### Recommended Folder Structure
```
lib/
  core/           # Constants, theme, utils
  data/           # Models, services, repositories
  features/       # Feature modules (auth, sales, etc.)
  shared/         # Shared widgets/components
  main.dart
```

### Repository Layer Example
```dart
// lib/data/repositories/auth_repository.dart
class AuthRepository {
  final ApiService api;
  AuthRepository(this.api);
  Future<bool> login(...) async => await api.login(...);
}
```

### Global Error Handler Example
```dart
// lib/core/error_handler.dart
class AppErrorHandler {
  static void handle(Object error, StackTrace stack) {
    // log + crash reporting
  }
}
```

### Navigation Service Example
```dart
// lib/core/navigation_service.dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static navigateTo(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }
}
```

---

## 4. Crash Reporting (AWS CloudWatch)

### Global Error Handler in main.dart
```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
void main() {
  runZonedGuarded(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _reportError(details.exception, details.stack);
    };
    runApp(const MyApp());
  }, (error, stack) {
    _reportError(error, stack);
  });
}
```

### CrashReporter Class
```dart
import 'package:dio/dio.dart';
class CrashReporter {
  static final _dio = Dio();
  static Future<void> send(Object error, StackTrace? stack, Map<String, dynamic> extra) async {
    try {
      await _dio.post(
        'https://your-api.com/log-error',
        data: {
          'error': error.toString(),
          'stack': stack.toString(),
          ...extra,
        },
      );
    } catch (_) {}
  }
}
void _reportError(Object error, StackTrace? stack) {
  CrashReporter.send(error, stack, {/* device/user info */});
}
```

### AWS Lambda Example (Node.js)
```js
exports.handler = async (event) => {
  const body = JSON.parse(event.body);
  console.error("APP ERROR:", body);
  return { statusCode: 200, body: JSON.stringify({ success: true }) };
};
```

---

## 5. Add Device, User, and App Info to Crash Reports

- Use `package_info_plus` and `device_info_plus` to collect info:
```dart
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

final info = <String, dynamic>{
  'appVersion': (await PackageInfo.fromPlatform()).version,
  'device': (await DeviceInfoPlugin().deviceInfo).toMap(),
  'userId': userId,
  'companyId': companyId,
  'lastScreen': lastScreen,
  'action': lastAction,
};
```
- Pass this info as `extra` to `CrashReporter.send()`.

---

## 6. Bonus Improvements

### Dio Retry Interceptor
- Use the `dio_retry` package:
```dart
import 'package:dio_retry/dio_retry.dart';
dio.interceptors.add(RetryInterceptor(dio: dio));
```

### Loading State Widget
```dart
class AppLoader {
  static void show(BuildContext context) => showDialog(...);
  static void hide(BuildContext context) => Navigator.of(context, rootNavigator: true).pop();
}
```

### Offline Crash Queue
- Store failed crash logs locally (e.g., with `shared_preferences` or a local DB) and retry sending when online.

---

For detailed code, see the main PRODUCTION_GUIDELINES.md or request a specific implementation.
