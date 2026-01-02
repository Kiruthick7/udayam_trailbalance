# Udayam Trial Balance App

Flutter mobile application for viewing trial balance reports from multiple companies.

> **Security Note**: This README uses example values. Replace all placeholders with your actual API endpoints and credentials. Never commit actual secrets or production URLs to version control.

## Prerequisites

1. **Install Flutter**: Follow instructions at https://flutter.dev/docs/get-started/install
2. **Backend API**: Deployed on AWS Lambda (see `../trial_balance_api/README.md`)

## Setup

1. **Install dependencies:**
```bash
flutter pub get
```

2. **Add app icon:**
Place your app icon at `assets/icon/app_icon.png` (1024x1024 recommended)

3. **Configure API endpoint:**
Update `lib/services/api_service.dart` with your API URL:
```dart
baseUrl = 'https://your-api-id.execute-api.region.amazonaws.com'
```

For local development:
- Android emulator: `http://10.0.2.2:8000`
- iOS simulator: `http://localhost:8000`
- Physical device: `http://YOUR_COMPUTER_IP:8000`

## Running the App

```bash
# Check connected devices
flutter devices

# Run on connected device
flutter run

# Run in debug mode with hot reload
flutter run --debug

# Build release APK (Android)
flutter build apk --release

# Build iOS app
flutter build ios --release
```

## Features

- ✅ User authentication with JWT tokens
- ✅ Persistent auto-login with secure token storage
- ✅ Multi-company selection
- ✅ Date range picker with presets
- ✅ Trial balance report view
- ✅ Daily sales reports with detailed breakdowns
- ✅ Sales detail view with customer information
- ✅ Manager and salesman contact integration with phone dialing
- ✅ PDF invoice generation and WhatsApp sharing
- ✅ Expandable company reports
- ✅ Pull-to-refresh functionality
- ✅ Formatted currency display
- ✅ User-friendly error handling
- ✅ Network connectivity detection
- ✅ Responsive design with animations
- ✅ Production-ready with AWS integration
- ✅ Comprehensive reusable utility functions

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── company.dart
│   ├── trial_balance.dart
│   ├── daily_sales.dart
│   └── sales_detail.dart
├── services/                    # API & storage services
│   ├── api_service.dart
│   ├── auth_interceptor.dart
│   ├── storage_service.dart
│   └── connectivity_service.dart
├── providers/                   # State management (Riverpod)
│   ├── auth_provider.dart
│   ├── company_provider.dart
│   ├── trial_balance_provider.dart
│   ├── daily_sales_provider.dart
│   └── sales_detail_provider.dart
├── screens/                     # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── company_selection_screen.dart
│   ├── home_screen.dart
│   ├── trial_balance_screen.dart
│   ├── daily_sales_screen.dart
│   └── sales_detail_screen.dart
├── widgets/                     # Reusable widgets
│   ├── date_range_picker.dart
│   ├── trial_balance_table.dart
│   ├── error_snackbar.dart
│   └── common_widgets.dart      # Reusable UI components
└── utils/                       # Utilities
    ├── error_handler.dart
    ├── responsive_helper.dart
    ├── phone_utils.dart         # Phone call utilities
    ├── format_utils.dart        # Number & date formatting
    ├── dialog_utils.dart        # Dialogs & snackbars
    ├── pdf_utils.dart           # PDF generation
    ├── share_utils.dart         # File & WhatsApp sharing
    ├── QUICK_REFERENCE.md       # Quick utility lookup
    ├── UTILITY_FUNCTIONS_GUIDE.md # Comprehensive guide
    └── EXAMPLE_USAGE.dart       # Code examples
```

## Utility Functions

The app includes comprehensive utility functions to reduce code duplication:

- **PhoneUtils**: Make phone calls, format & validate phone numbers
- **FormatUtils**: Format currency, dates, quantities, profit/loss displays
- **DialogUtils**: Show loading dialogs, snackbars, confirmation dialogs
- **CommonWidgets**: Reusable UI components (chips, cards, empty states)
- **PdfUtils**: Generate professional PDF invoices with styling
- **ShareUtils**: Share via WhatsApp, email, or generic sharing

📖 **Detailed documentation**: See [lib/utils/QUICK_REFERENCE.md](lib/utils/QUICK_REFERENCE.md) and [lib/utils/UTILITY_FUNCTIONS_GUIDE.md](lib/utils/UTILITY_FUNCTIONS_GUIDE.md)

## Testing

Login with your configured credentials:
- Email: `your-email@example.com`
- Password: `your-secure-password`

The app includes:
- Auto-login on subsequent launches
- Error handling for network issues
- Offline detection and user feedback

## Production Build

### Android APK
```bash
# Build release APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### iOS App
```bash
flutter build ios --release
```

**Before releasing to production:**
1. Update package name in `android/app/build.gradle`
2. Configure release signing keystore
3. Add internet permissions to `AndroidManifest.xml`
4. Update app label to "Udayam TB"
5. Generate and set app icon (see `flutter_launcher_icons` package)

Refer to `FLUTTER_PRODUCTION_READINESS_REPORT.md` for complete checklist.

## Troubleshooting

**Can't connect to API:**
- Check internet connection
- Verify production API is accessible
- Check error messages for specific issues

**Build errors:**
- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter version: `flutter --version`

**Token expiration:**
- App automatically handles token refresh
- If issues persist, logout and login again

## Documentation

- [Utility Functions Quick Reference](lib/utils/QUICK_REFERENCE.md) - Quick lookup for all utilities
- [Utility Functions Guide](lib/utils/UTILITY_FUNCTIONS_GUIDE.md) - Comprehensive guide with examples
- [Utility Usage Examples](lib/utils/EXAMPLE_USAGE.dart) - Code examples for all utilities
- [AWS Security Guide](AWS_SECURITY_GUIDE.md) - AWS Secrets Manager setup
- [Production Readiness Report](FLUTTER_PRODUCTION_READINESS_REPORT.md) - Pre-release checklist
- [Secrets List](SECRETS_LIST.md) - AWS secrets configuration
