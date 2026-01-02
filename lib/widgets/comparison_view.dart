// lib/widgets/comparison_view.dart
import 'package:flutter/material.dart';
import '../models/trial_balance.dart';
import '../utils/responsive_helper.dart';
import 'package:intl/intl.dart';

class ComparisonView extends StatelessWidget {
  final List<TrialBalanceReport> reports;

  const ComparisonView({super.key, required this.reports});

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: 2,
    );
    if (value < 0) {
      return '-${formatter.format(value.abs())}';
    }
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    if (reports.length < 2) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, 24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.compare_arrows,
                size: ResponsiveHelper.getResponsiveIconSize(context, 64),
                color: Colors.grey[400],
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 16)),
              Text(
                'Select at least 2 companies to compare',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding:
          EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildComparisonHeader(context),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 16)),
          _buildSummaryComparison(context),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 16)),
          _buildDetailedComparison(context),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: Colors.green[700],
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                ),
                SizedBox(
                    width: ResponsiveHelper.getResponsivePadding(context, 8)),
                Text(
                  'Comparison Report',
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 8)),
            Text(
              'Comparing ${reports.length} companies',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryComparison(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 12)),
            ...reports.map((report) {
              final total = report.rows.last.balance;
              final assets = report.rows
                  .where((r) =>
                      r.accountType == 'ASSET' &&
                      !r.accountName.contains('TOTAL'))
                  .fold<double>(0, (sum, r) => sum + r.balance);
              final liabilities = report.rows
                  .where((r) =>
                      r.accountType == 'LIABILITY' &&
                      !r.accountName.contains('TOTAL'))
                  .fold<double>(0, (sum, r) => sum + r.balance);
              return Container(
                margin: EdgeInsets.only(
                  bottom: ResponsiveHelper.getResponsivePadding(context, 12),
                ),
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 12)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.green[50]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.companyName,
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 8)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Assets:',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 12),
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatCurrency(assets),
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 12),
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Liabilities:',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 12),
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatCurrency(liabilities),
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 12),
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 12),
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatCurrency(total),
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 12),
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedComparison(BuildContext context) {
    // Get all unique account names
    final allAccountNames = <String>{};
    for (final report in reports) {
      for (final row in report.rows) {
        if (!row.accountName.contains('TOTAL')) {
          allAccountNames.add(row.accountName);
        }
      }
    }

    final accountColumnWidth =
        ResponsiveHelper.getResponsivePadding(context, 160);
    final dataColumnWidth = ResponsiveHelper.getResponsivePadding(context, 120);
    final rowHeight = ResponsiveHelper.getResponsivePadding(context, 52);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Comparison',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 12)),
            SizedBox(
              height: (allAccountNames.length + 1) * rowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sticky Account Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: accountColumnWidth,
                        height: rowHeight,
                        padding: EdgeInsets.all(
                            ResponsiveHelper.getResponsivePadding(context, 12)),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 12),
                            ),
                          ),
                        ),
                      ),
                      // Data rows
                      ...allAccountNames.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final accountName = entry.value;
                        final isEvenRow = index % 2 == 0;

                        return Container(
                          width: accountColumnWidth,
                          height: rowHeight,
                          padding: EdgeInsets.all(
                              ResponsiveHelper.getResponsivePadding(
                                  context, 10)),
                          decoration: BoxDecoration(
                            color: isEvenRow ? Colors.white : Colors.green[50],
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              accountName,
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 10),
                              ),
                              maxLines: 2,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  // Scrollable columns
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Company columns
                          ...reports.map((report) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Container(
                                  width: dataColumnWidth,
                                  height: rowHeight,
                                  padding: EdgeInsets.all(
                                      ResponsiveHelper.getResponsivePadding(
                                          context, 8)),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[300]!),
                                      right:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      report.companyName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(context, 12),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                // Data rows
                                ...allAccountNames
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final accountName = entry.value;
                                  final isEvenRow = index % 2 == 0;

                                  final row = report.rows.firstWhere(
                                    (r) => r.accountName == accountName,
                                    orElse: () => TrialBalanceRow(
                                      accountCode: '',
                                      accountName: accountName,
                                      accountType: '',
                                      debit: 0,
                                      credit: 0,
                                      balance: 0,
                                    ),
                                  );
                                  return Container(
                                    width: dataColumnWidth,
                                    height: rowHeight,
                                    padding: EdgeInsets.all(
                                        ResponsiveHelper.getResponsivePadding(
                                            context, 6)),
                                    decoration: BoxDecoration(
                                      color: isEvenRow
                                          ? Colors.white
                                          : Colors.green[50],
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[300]!),
                                        right: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        formatCurrency(row.balance),
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper
                                              .getResponsiveFontSize(
                                                  context, 10),
                                          fontFamily: 'monospace',
                                          color: row.balance == 0
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }),
                          // Total column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Container(
                                width: dataColumnWidth,
                                height: rowHeight,
                                padding: EdgeInsets.all(
                                    ResponsiveHelper.getResponsivePadding(
                                        context, 12)),
                                decoration: BoxDecoration(
                                  color: Colors.amber[100],
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          ResponsiveHelper.getResponsivePadding(
                                              context, 8),
                                      vertical:
                                          ResponsiveHelper.getResponsivePadding(
                                              context, 4),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(context, 12),
                                        color: Colors.amber[900],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Data rows
                              ...allAccountNames
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final accountName = entry.value;
                                final isEvenRow = index % 2 == 0;

                                final balances = <double>[];
                                for (final report in reports) {
                                  final row = report.rows.firstWhere(
                                    (r) => r.accountName == accountName,
                                    orElse: () => TrialBalanceRow(
                                      accountCode: '',
                                      accountName: accountName,
                                      accountType: '',
                                      debit: 0,
                                      credit: 0,
                                      balance: 0,
                                    ),
                                  );
                                  balances.add(row.balance);
                                }
                                final total = balances.fold<double>(
                                    0, (sum, balance) => sum + balance);

                                return Container(
                                  width: dataColumnWidth,
                                  height: rowHeight,
                                  padding: EdgeInsets.all(
                                      ResponsiveHelper.getResponsivePadding(
                                          context, 6)),
                                  decoration: BoxDecoration(
                                    color: isEvenRow
                                        ? Colors.amber[50]
                                        : Colors.amber[100],
                                    border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[300]!),
                                      left:
                                          BorderSide(color: Colors.amber[200]!),
                                      right:
                                          BorderSide(color: Colors.amber[200]!),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      formatCurrency(total),
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(context, 10),
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[900],
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
