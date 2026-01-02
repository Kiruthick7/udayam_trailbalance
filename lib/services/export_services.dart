import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/trial_balance.dart';

class ExportService {
  final dateFormat = DateFormat('dd/MM/yyyy');
  final currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2);

  // Export to PDF
  Future<void> exportToPdf(List<TrialBalanceReport> reports,
      {Rect? sharePositionOrigin}) async {
    final pdf = pw.Document();

    for (final report in reports) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildPdfHeader(report),
            pw.SizedBox(height: 20),
            _buildPdfTable(report),
            pw.SizedBox(height: 20),
            _buildPdfSummary(report),
          ],
        ),
      );
    }

    // Save PDF to file and share
    final output = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/trial_balance_$timestamp.pdf');
    await file.writeAsBytes(output);

    // Share the PDF with position origin for iPad
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Trial Balance Report',
      text:
          'Trial Balance Report - Generated on ${dateFormat.format(DateTime.now())}',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  pw.Widget _buildPdfHeader(TrialBalanceReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Trial Balance Report',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          report.companyName,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Period: ${report.period['start']} to ${report.period['end']}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Text(
          'Generated: ${dateFormat.format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTable(TrialBalanceReport report) {
    final rows =
        report.rows.where((r) => !r.accountName.contains('TOTAL')).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _pdfTableCell('Account Name', bold: true),
            _pdfTableCell('Type', bold: true),
            _pdfTableCell('Balance', bold: true, align: pw.TextAlign.right),
          ],
        ),
        ...rows.map((row) => pw.TableRow(
              children: [
                _pdfTableCell(row.accountName),
                _pdfTableCell(row.accountType),
                _pdfTableCell(
                  currencyFormat.format(row.balance),
                  align: pw.TextAlign.right,
                ),
              ],
            )),
      ],
    );
  }

  pw.Widget _pdfTableCell(String text,
      {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 10,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildPdfSummary(TrialBalanceReport report) {
    final totalRow = report.rows.lastWhere(
      (r) => r.accountName.contains('TOTAL'),
      orElse: () => report.rows.last,
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green300, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Total Balance',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            currencyFormat.format(totalRow.balance),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Export to CSV
  Future<void> exportToCsv(List<TrialBalanceReport> reports,
      {Rect? sharePositionOrigin}) async {
    try {
      final List<List<dynamic>> csvData = [];

      for (final report in reports) {
        csvData.add([report.companyName]);
        csvData.add(
            ['Period: ${report.period['start']} to ${report.period['end']}']);
        csvData.add([]);
        csvData.add([
          'Account Code',
          'Account Name',
          'Type',
          'Debit',
          'Credit',
          'Balance'
        ]);

        for (final row in report.rows) {
          csvData.add([
            row.accountCode,
            row.accountName,
            row.accountType,
            row.debit,
            row.credit,
            row.balance,
          ]);
        }

        csvData.add([]);
        csvData.add([]);
      }

      final csv = const ListToCsvConverter().convert(csvData);
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/trial_balance_$timestamp.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Trial Balance Report',
        text:
            'Trial Balance Report - Generated on ${dateFormat.format(DateTime.now())}',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  // Export to Excel (CSV format that Excel can read)
  Future<void> exportToExcel(List<TrialBalanceReport> reports,
      {Rect? sharePositionOrigin}) async {
    await exportToCsv(reports, sharePositionOrigin: sharePositionOrigin);
  }

  // Share report
  Future<void> shareReport(List<TrialBalanceReport> reports, String format,
      {Rect? sharePositionOrigin}) async {
    try {
      if (format == 'pdf') {
        await exportToPdf(reports, sharePositionOrigin: sharePositionOrigin);
      } else if (format == 'csv') {
        await exportToCsv(reports, sharePositionOrigin: sharePositionOrigin);
      } else if (format == 'excel') {
        await exportToExcel(reports, sharePositionOrigin: sharePositionOrigin);
      }
    } catch (e) {
      throw Exception('Failed to export report: $e');
    }
  }
}
