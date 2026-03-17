import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trial_balance_app/screens/pin_setup_screen.dart';
import 'package:trial_balance_app/services/storage_service.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'pin_entry_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.checkAuth();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      final hasPin = await StorageService.hasPin();
      if (!mounted) return;
      final isSessionValid =
          await ref.read(apiServiceProvider).isSessionValid();
      if (!isSessionValid) {
        await StorageService.clearPin();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }
      if (!hasPin) {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PinSetupScreen(
              onPinSet: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                });
              },
            ),
          ),
        );
        return;
      } else {
        // Log removed
        final authNotifierForCallback = ref.read(authProvider.notifier);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PinEntryScreen(
              onPinVerified: () async {
                final refreshed = await authNotifierForCallback.refreshToken();
                if (!mounted) return;
                if (refreshed) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              onFailed: () async {
                await authNotifierForCallback.logout();
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        );
        return;
      }
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image not found
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        size: 60,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              'Udayam',
              style: AppTheme.headline1.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Trial Balance',
              style: AppTheme.bodyText.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
