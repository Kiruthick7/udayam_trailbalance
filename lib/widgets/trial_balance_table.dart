import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trial_balance.dart';
import '../utils/responsive_helper.dart';

class TrialBalanceTable extends StatelessWidget {
  final List<TrialBalanceReport> reports;

  const TrialBalanceTable({super.key, required this.reports});

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
    final isTabletOrLarger = !ResponsiveHelper.isMobile(context);

    if (isTabletOrLarger) {
      return ResponsiveHelper.constrainedContent(
        context: context,
        child: GridView.builder(
          padding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, 12)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.getGridColumns(context),
            childAspectRatio: 0.75,
            crossAxisSpacing:
                ResponsiveHelper.getResponsivePadding(context, 12),
            mainAxisSpacing: ResponsiveHelper.getResponsivePadding(context, 12),
          ),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            if (report.companyId == 'GHE01') {
              return _buildTwoColumnReport(context, report);
            }
            return _buildSingleColumnReport(context, report);
          },
        ),
      );
    }

    return ListView.builder(
      padding:
          EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 12)),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        if (report.companyId == 'GHE01') {
          return _buildTwoColumnReport(context, report);
        }
        return _buildSingleColumnReport(context, report);
      },
    );
  }

  Widget _buildTwoColumnReport(
      BuildContext context, TrialBalanceReport report) {
    final creditRows = report.rows
        .where((row) =>
            row.accountType == 'LIABILITY' &&
            !row.accountName.contains('TOTAL'))
        .toList();

    final debitRows = report.rows
        .where((row) =>
            row.accountType == 'ASSET' && !row.accountName.contains('TOTAL'))
        .toList();

    final creditTotal = report.rows
        .firstWhere(
          (row) => row.accountName == 'TOTAL LIABILITIES',
          orElse: () => TrialBalanceRow(
            accountCode: '',
            accountName: '',
            accountType: '',
            debit: 0,
            credit: 0,
            balance: 0,
          ),
        )
        .balance;

    final debitTotal = report.rows
        .firstWhere(
          (row) => row.accountName == 'TOTAL ASSETS',
          orElse: () => TrialBalanceRow(
            accountCode: '',
            accountName: '',
            accountType: '',
            debit: 0,
            credit: 0,
            balance: 0,
          ),
        )
        .balance;

    final netTotal = report.rows
        .firstWhere(
          (row) => row.accountName == 'NET TOTAL',
          orElse: () => TrialBalanceRow(
            accountCode: '',
            accountName: '',
            accountType: '',
            debit: 0,
            credit: 0,
            balance: 0,
          ),
        )
        .balance;

    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getResponsivePadding(context, 16),
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildReportHeader(context, report),
          Padding(
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 12)),
            child: Column(
              children: [
                _buildSection(context, 'LIABILITIES', creditRows, creditTotal,
                    Colors.red),
                SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 12)),
                _buildSection(
                    context, 'ASSETS', debitRows, debitTotal, Colors.green),
              ],
            ),
          ),
          _buildNetTotal(context, netTotal),
        ],
      ),
    );
  }

  Widget _buildReportHeader(BuildContext context, TrialBalanceReport report) {
    return Container(
      padding:
          EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 16)),
      decoration: BoxDecoration(
        color:
            report.companyId == 'GHE01' ? Colors.indigo[700] : Colors.blue[700],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.business,
            color: Colors.white,
            size: ResponsiveHelper.getResponsiveIconSize(context, 20),
          ),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.companyName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 15),
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 4)),
                Text(
                  '${report.period['start']} to ${report.period['end']}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<TrialBalanceRow> rows,
    double total,
    MaterialColor color,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color[200]!, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 10)),
            decoration: BoxDecoration(
              color: color[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  title == 'LIABILITIES'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: color[800],
                  size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                ),
                SizedBox(
                    width: ResponsiveHelper.getResponsivePadding(context, 6)),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 11),
                  ),
                ),
              ],
            ),
          ),
          ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getResponsivePadding(context, 8),
                horizontal: ResponsiveHelper.getResponsivePadding(context, 8),
              ),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : color[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.accountName,
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 10),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                      width: ResponsiveHelper.getResponsivePadding(context, 8)),
                  Text(
                    formatCurrency(row.balance),
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 11),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            );
          }),
          Container(
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 8)),
            decoration: BoxDecoration(
              color: color[200],
              border: Border(top: BorderSide(color: color[400]!, width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 11),
                  ),
                ),
                Text(
                  formatCurrency(total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 11),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetTotal(BuildContext context, double netTotal) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        ResponsiveHelper.getResponsivePadding(context, 12),
        0,
        ResponsiveHelper.getResponsivePadding(context, 12),
        ResponsiveHelper.getResponsivePadding(context, 12),
      ),
      padding:
          EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 12)),
      decoration: BoxDecoration(
        color: netTotal >= 0 ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: netTotal >= 0 ? Colors.green[400]! : Colors.red[400]!,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                netTotal >= 0 ? Icons.check_circle : Icons.warning,
                color: netTotal >= 0 ? Colors.green[700] : Colors.red[700],
                size: ResponsiveHelper.getResponsiveIconSize(context, 20),
              ),
              SizedBox(
                  width: ResponsiveHelper.getResponsivePadding(context, 8)),
              Text(
                netTotal >= 0 ? 'NET PROFIT' : 'NET LOSS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                  color: netTotal >= 0 ? Colors.green[900] : Colors.red[900],
                ),
              ),
            ],
          ),
          Text(
            formatCurrency(netTotal.abs()),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
              fontFamily: 'monospace',
              color: netTotal >= 0 ? Colors.green[900] : Colors.red[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleColumnReport(
      BuildContext context, TrialBalanceReport report) {
    final allAccounts =
        report.rows.where((row) => row.accountName != 'NET PROFIT').toList();

    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getResponsivePadding(context, 16),
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildReportHeader(context, report),
          Padding(
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 12)),
            child: Column(
              children: [
                ...allAccounts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final account = entry.value;
                  return Container(
                    padding: EdgeInsets.symmetric(
                      vertical:
                          ResponsiveHelper.getResponsivePadding(context, 8),
                      horizontal:
                          ResponsiveHelper.getResponsivePadding(context, 12),
                    ),
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.white : Colors.green[50],
                      border: Border(
                        top: index == 0
                            ? BorderSide.none
                            : BorderSide(color: Colors.grey[300]!, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            account.accountName,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 11),
                            ),
                          ),
                        ),
                        Text(
                          formatCurrency(account.balance),
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 11),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(
              ResponsiveHelper.getResponsivePadding(context, 12),
              0,
              ResponsiveHelper.getResponsivePadding(context, 12),
              ResponsiveHelper.getResponsivePadding(context, 12),
            ),
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 12)),
            decoration: BoxDecoration(
              color: Colors.green[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[400]!, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 13),
                  ),
                ),
                Text(
                  formatCurrency(report.rows.last.balance),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 15),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
