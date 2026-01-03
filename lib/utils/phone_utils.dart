import 'package:url_launcher/url_launcher.dart';

/// Utility functions for phone-related operations
class PhoneUtils {
  /// Extract and clean phone numbers from a string that may contain multiple numbers
  /// Returns a list of cleaned phone numbers
  static List<String> extractPhoneNumbers(String phoneString) {
    if (phoneString.isEmpty) return [];

    // First, split by known separators (comma, slash, pipe, semicolon)
    final mainParts = phoneString.split(RegExp(r'[,/|;]'));
    final List<String> numbers = [];

    for (var part in mainParts) {
      // Remove all non-digit characters and spaces
      final digitsOnly = part.replaceAll(RegExp(r'[^\d]'), '');

      // Valid Indian mobile number (10 digits or 12 with 91)
      if (digitsOnly.length == 10) {
        numbers.add(digitsOnly);
      } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
        numbers.add(digitsOnly.substring(2)); // Remove 91 prefix
      } else if (digitsOnly.length > 12 && digitsOnly.startsWith('91')) {
        // Handle case like "919876543210" (extra digits)
        numbers.add(digitsOnly.substring(2, 12));
      } else if (digitsOnly.length >= 10) {
        // Extract last 10 digits
        numbers.add(digitsOnly.substring(digitsOnly.length - 10));
      }
    }

    return numbers.toSet().toList(); // Remove duplicates
  }

  /// Make a phone call to the given phone number
  /// Cleans the number and launches the phone dialer
  static Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      // Extract first valid number
      final numbers = extractPhoneNumbers(phoneNumber);
      if (numbers.isEmpty) return false;

      final cleanNumber = numbers.first;
      final Uri phoneUri = Uri(scheme: 'tel', path: '+91$cleanNumber');
      return await launchUrl(phoneUri);
    } catch (e) {
      return false;
    }
  }

  /// Format phone number for display
  /// Example: 9876543210 -> +91 98765 43210
  static String formatPhoneNumber(String phoneNumber) {
    final numbers = extractPhoneNumbers(phoneNumber);
    if (numbers.isEmpty) return phoneNumber;

    if (numbers.length == 1) {
      final num = numbers.first;
      if (num.length == 10) {
        return '+91 ${num.substring(0, 5)} ${num.substring(5)}';
      }
    } else {
      // Multiple numbers - format each
      return numbers
          .map((number) =>
              '+91 ${number.substring(0, 5)} ${number.substring(5)}')
          .join(' / ');
    }

    return phoneNumber;
  }

  /// Validate phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    final numbers = extractPhoneNumbers(phoneNumber);
    return numbers.isNotEmpty;
  }

  /// Check if phone string contains multiple numbers
  static bool hasMultipleNumbers(String phoneString) {
    return extractPhoneNumbers(phoneString).length > 1;
  }
}
