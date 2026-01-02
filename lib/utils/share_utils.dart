import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'format_utils.dart';

/// Utility class for sharing content
class ShareUtils {
  /// Share text content
  static Future<void> shareText({
    required String text,
    String? subject,
    BuildContext? context,
  }) async {
    final box = context?.findRenderObject() as RenderBox?;

    await Share.share(
      text,
      subject: subject,
      sharePositionOrigin:
          box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
    );
  }

  /// Share file (PDF, image, etc.)
  static Future<void> shareFile({
    required String filePath,
    String? text,
    BuildContext? context,
  }) async {
    final box = context?.findRenderObject() as RenderBox?;

    await Share.shareXFiles(
      [XFile(filePath)],
      text: text,
      sharePositionOrigin:
          box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
    );
  }

  /// Share multiple files
  static Future<void> shareFiles({
    required List<String> filePaths,
    String? text,
    BuildContext? context,
  }) async {
    final box = context?.findRenderObject() as RenderBox?;

    await Share.shareXFiles(
      filePaths.map((path) => XFile(path)).toList(),
      text: text,
      sharePositionOrigin:
          box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
    );
  }

  /// Share via WhatsApp specifically
  /// Note: This opens WhatsApp with the file/text, but doesn't guarantee delivery
  static Future<bool> shareViaWhatsApp({
    String? phoneNumber,
    String? message,
    String? filePath,
  }) async {
    try {
      // If file is provided, use the generic share (which will show WhatsApp as option)
      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: message,
        );
        return true;
      }

      // If only message and phone number, create WhatsApp URL
      if (phoneNumber != null && message != null) {
        // Remove all non-digit characters from phone number
        final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

        // Create WhatsApp URL
        final whatsappUrl = Uri.parse(
            'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}');

        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          return true;
        }
      }

      // If only message, share it (will show WhatsApp as option)
      if (message != null) {
        await Share.share(message);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Share bill/invoice details as formatted text
  static Future<void> shareInvoiceAsText({
    required String billNumber,
    required DateTime billDate,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    BuildContext? context,
  }) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('📄 INVOICE');
    buffer.writeln('═' * 30);
    buffer.writeln('Bill No: $billNumber');
    buffer.writeln('Date: ${FormatUtils.formatDate(billDate)}');
    buffer.writeln('Customer: $customerName');
    buffer.writeln('═' * 30);
    buffer.writeln();

    // Items
    buffer.writeln('ITEMS:');
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.writeln('${i + 1}. ${item['name']}');
      buffer.writeln(
          '   Qty: ${item['qty']} × Rs.${item['rate']} = Rs.${item['amount']}');
    }
    buffer.writeln();

    // Total
    buffer.writeln('─' * 30);
    buffer.writeln('TOTAL: Rs.${FormatUtils.formatDecimal(totalAmount)}');
    buffer.writeln('─' * 30);

    await shareText(
      text: buffer.toString(),
      context: context,
    );
  }

  /// Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    try {
      final url = Uri.parse('whatsapp://send');
      return await canLaunchUrl(url);
    } catch (e) {
      return false;
    }
  }

  /// Open email client with pre-filled data
  static Future<bool> shareViaEmail({
    required String recipient,
    String? subject,
    String? body,
    List<String>? attachmentPaths,
  }) async {
    try {
      final emailUrl = Uri(
        scheme: 'mailto',
        path: recipient,
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        },
      );

      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
