import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'format_utils.dart';

/// Data model for invoice/bill PDF
class InvoiceData {
  final String title;
  final String billNumber;
  final DateTime billDate;
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;
  final List<InvoiceItem> items;
  final double totalQuantity;
  final double netAmount;
  final String? footer;

  InvoiceData({
    this.title = 'INVOICE',
    required this.billNumber,
    required this.billDate,
    this.customerName,
    this.customerAddress,
    this.customerPhone,
    required this.items,
    required this.totalQuantity,
    required this.netAmount,
    this.footer,
  });
}

/// Data model for individual invoice items
class InvoiceItem {
  final String name;
  final double quantity;
  final double rate;
  final double amount;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.rate,
    required this.amount,
  });
}

/// Utility class for PDF generation and sharing
class PdfUtils {
  /// Generate an invoice PDF
  static Future<File> generateInvoicePdf(InvoiceData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildPdfHeader(data),
              pw.SizedBox(height: 24),

              // Customer Details
              if (data.customerName != null ||
                  data.customerAddress != null ||
                  data.customerPhone != null)
                _buildCustomerSection(data),

              if (data.customerName != null ||
                  data.customerAddress != null ||
                  data.customerPhone != null)
                pw.SizedBox(height: 24),

              // Items Table
              _buildItemsTable(data.items),
              pw.SizedBox(height: 24),

              // Summary
              _buildSummarySection(data),
              pw.Spacer(),

              // Footer
              _buildPdfFooter(data.footer),
            ],
          );
        },
      ),
    );

    // Save PDF to temporary directory
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bill_${data.billNumber}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Build PDF header section
  static pw.Widget _buildPdfHeader(InvoiceData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#667eea'),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            data.title,
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Bill #${data.billNumber}',
            style: pw.TextStyle(
              fontSize: 20,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Date: ${FormatUtils.formatDate(data.billDate)}',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build customer details section
  static pw.Widget _buildCustomerSection(InvoiceData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILL TO',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#667eea'),
            ),
          ),
          pw.SizedBox(height: 8),
          if (data.customerName != null)
            pw.Text(
              data.customerName!,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          if (data.customerAddress != null)
            pw.Text(
              data.customerAddress!,
              style: const pw.TextStyle(fontSize: 11),
            ),
          if (data.customerPhone != null)
            pw.Text(
              'Phone: ${data.customerPhone}',
              style: const pw.TextStyle(fontSize: 11),
            ),
        ],
      ),
    );
  }

  /// Build items table
  static pw.Widget _buildItemsTable(List<InvoiceItem> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ITEMS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#667eea'),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#f5f5f5'),
              ),
              children: [
                _buildTableCell('#', isHeader: true),
                _buildTableCell('Item Name', isHeader: true),
                _buildTableCell('Qty',
                    isHeader: true, align: pw.TextAlign.center),
                _buildTableCell('Rate',
                    isHeader: true, align: pw.TextAlign.right),
                _buildTableCell('Amount',
                    isHeader: true, align: pw.TextAlign.right),
              ],
            ),

            // Items
            ...List.generate(items.length, (index) {
              final item = items[index];
              return pw.TableRow(
                children: [
                  _buildTableCell('${index + 1}'),
                  _buildTableCell(item.name),
                  _buildTableCell(
                    FormatUtils.formatQuantity(item.quantity),
                    align: pw.TextAlign.center,
                  ),
                  _buildTableCell(
                    'Rs. ${FormatUtils.formatDecimal(item.rate)}',
                    align: pw.TextAlign.right,
                  ),
                  _buildTableCell(
                    'Rs. ${FormatUtils.formatDecimal(item.amount)}',
                    align: pw.TextAlign.right,
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: isHeader ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
        textAlign: align,
      ),
    );
  }

  /// Build summary section
  static pw.Widget _buildSummarySection(InvoiceData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#f0fdf4'),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromHex('#bbf7d0')),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Items:',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '${data.items.length}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Quantity:',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                FormatUtils.formatQuantity(data.totalQuantity),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Divider(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'NET AMOUNT:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#16a34a'),
                ),
              ),
              pw.Text(
                'Rs. ${FormatUtils.formatDecimal(data.netAmount)}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#16a34a'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build PDF footer
  static pw.Widget _buildPdfFooter(String? footerText) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          footerText ?? 'Thank you for your business!',
          style: pw.TextStyle(
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey600,
          ),
        ),
      ),
    );
  }

  /// Share a file (PDF, image, etc.)
  static Future<void> shareFile({
    required File file,
    required String shareText,
    BuildContext? context,
  }) async {
    final box = context?.findRenderObject() as RenderBox?;

    await Share.shareXFiles(
      [XFile(file.path)],
      text: shareText,
      sharePositionOrigin:
          box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
    );
  }

  /// Generate and share invoice PDF in one call
  static Future<bool> generateAndShareInvoice({
    required BuildContext context,
    required InvoiceData data,
    String? shareText,
  }) async {
    try {
      // Generate PDF
      final file = await generateInvoicePdf(data);

      // Share the PDF - check if context is still mounted
      if (context.mounted) {
        await shareFile(
          file: file,
          shareText: shareText ??
              'Bill #${data.billNumber} - ${FormatUtils.formatDate(data.billDate)}',
          context: context,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete temporary PDF files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      for (var file in files) {
        if (file.path.endsWith('.pdf')) {
          await file.delete();
        }
      }
    } catch (e) {
      // Silently fail - not critical
    }
  }
}
