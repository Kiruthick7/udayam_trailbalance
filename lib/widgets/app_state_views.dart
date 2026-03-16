import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// A reusable error state widget with icon, message, and retry button.
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;

  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor, size: 56),
            const SizedBox(height: 16),
            if (title != null)
              Text(
                title!,
                style: AppTheme.headline2,
                textAlign: TextAlign.center,
              ),
            if (title != null) const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyText,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  ),
                ),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A reusable empty state widget with icon and message.
class AppEmptyView extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;

  const AppEmptyView({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 56),
            const SizedBox(height: 16),
            if (title != null)
              Text(
                title!,
                style: AppTheme.headline2,
                textAlign: TextAlign.center,
              ),
            if (title != null) const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
