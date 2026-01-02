class TrialBalanceRow {
  final String accountCode;
  final String accountName;
  final String accountType;
  final double debit;
  final double credit;
  final double balance;

  TrialBalanceRow({
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  factory TrialBalanceRow.fromJson(Map<String, dynamic> json) =>
      TrialBalanceRow(
        accountCode: json['accountCode'] ?? '',
        accountName: json['accountName'] ?? '',
        accountType: json['accountType'] ?? '',
        debit: (json['debit'] ?? 0).toDouble(),
        credit: (json['credit'] ?? 0).toDouble(),
        balance: (json['balance'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'accountCode': accountCode,
        'accountName': accountName,
        'accountType': accountType,
        'debit': debit,
        'credit': credit,
        'balance': balance,
      };
}

class TrialBalanceReport {
  final String companyId;
  final String companyName;
  final Map<String, String> period;
  final List<TrialBalanceRow> rows;

  TrialBalanceReport({
    required this.companyId,
    required this.companyName,
    required this.period,
    required this.rows,
  });

  factory TrialBalanceReport.fromJson(Map<String, dynamic> json) =>
      TrialBalanceReport(
        companyId: json['companyId'] ?? '',
        companyName: json['companyName'] ?? 'Unknown',
        period: json['period'] != null
            ? Map<String, String>.from(json['period'])
            : {},
        rows: (json['rows'] as List? ?? [])
            .map((r) => TrialBalanceRow.fromJson(r))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'companyId': companyId,
        'companyName': companyName,
        'period': period,
        'rows': rows.map((r) => r.toJson()).toList(),
      };
}
