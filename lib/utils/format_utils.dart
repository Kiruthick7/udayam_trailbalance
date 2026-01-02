import 'package:intl/intl.dart';

/// Utility functions for formatting values
class FormatUtils {
  /// Format currency amount
  /// Example: 1234.56 -> ₹1,234.56
  static String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    final formatted = formatter.format(amount);
    return showSymbol ? '₹$formatted' : formatted;
  }

  /// Format currency without decimals
  /// Example: 1234.56 -> ₹1,235
  static String formatCurrencyCompact(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    final formatted = formatter.format(amount.round());
    return showSymbol ? '₹$formatted' : formatted;
  }

  /// Format quantity
  /// Example: 123.0 -> 123
  static String formatQuantity(double quantity) {
    return quantity.toStringAsFixed(0);
  }

  /// Format decimal value
  /// Example: 123.456 -> 123.46
  static String formatDecimal(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  /// Format date
  /// Example: DateTime -> 01 Jan 2024
  static String formatDate(DateTime date, {String pattern = 'dd MMM yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  /// Format date with day name
  /// Example: DateTime -> Monday, 01 Jan 2024
  static String formatDateWithDay(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy').format(date);
  }

  /// Format percentage
  /// Example: 0.1234 -> 12.34%
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(2)}%';
  }

  /// Format profit/loss with sign
  /// Example: 123.45 -> +123.45, -123.45 -> -123.45
  static String formatProfitLoss(double amount) {
    if (amount >= 0) {
      return '+${amount.toStringAsFixed(2)}';
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  /// Abbreviate large numbers
  /// Example: 1234567 -> 1.23M
  static String abbreviateNumber(double number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)}Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(0);
  }
}
