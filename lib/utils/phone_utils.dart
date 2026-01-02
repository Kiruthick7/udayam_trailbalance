import 'package:url_launcher/url_launcher.dart';

/// Utility functions for phone-related operations
class PhoneUtils {
  /// Make a phone call to the given phone number
  /// Cleans the number and launches the phone dialer
  static Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
      return await launchUrl(phoneUri);
    } catch (e) {
      return false;
    }
  }

  /// Format phone number for display
  /// Example: 9876543210 -> +91 98765 43210
  static String formatPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length == 10) {
      return '+91 ${cleanNumber.substring(0, 5)} ${cleanNumber.substring(5)}';
    }
    return phoneNumber;
  }

  /// Validate phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleanNumber.length >= 10;
  }
}
