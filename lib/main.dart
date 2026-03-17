import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/splash_screen.dart';
import 'services/token_refresh_service.dart';
import 'dart:async';
import 'core/navigation_service.dart';
import 'core/crash_reporter.dart';
import 'core/device_app_info.dart';

void main() {
  runZonedGuarded(() {
    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.presentError(details);
      final extra = await getDeviceAppInfo();
      CrashReporter.send(details.exception, details.stack, extra);
    };
    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) async {
    final extra = await getDeviceAppInfo();
    CrashReporter.send(error, stack, extra);
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  Timer? _tokenRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set up periodic token refresh check every 3 minutes
    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => TokenRefreshService.checkAndRefreshToken(),
    );
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes, check and refresh token if needed
    if (state == AppLifecycleState.resumed) {
      TokenRefreshService.checkAndRefreshToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Udayam TB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
