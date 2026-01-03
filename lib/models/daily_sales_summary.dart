class DailySalesSummary {
  final DateTime billdate;
  final int billno;
  final String? sno;
  final String cuscod;
  final String? cusnam;
  final String? adrone;
  final String? adrtwo;
  final String? phone;
  final double tqty;
  final double net;
  final double totalProfit;
  final double totalLoss;

  DailySalesSummary({
    required this.billdate,
    required this.billno,
    this.sno,
    required this.cuscod,
    this.cusnam,
    this.adrone,
    this.adrtwo,
    this.phone,
    required this.tqty,
    required this.net,
    this.totalProfit = 0.0,
    this.totalLoss = 0.0,
  });

  factory DailySalesSummary.fromJson(Map<String, dynamic> json) {
    return DailySalesSummary(
      billdate: DateTime.parse(json['billdate']),
      billno: json['billno'],
      sno: json['sno'],
      cuscod: json['cuscod'],
      cusnam: json['cusnam'],
      adrone: json['adrone'],
      adrtwo: json['adrtwo'],
      phone: json['phone'],
      tqty: (json['tqty'] as num).toDouble(),
      net: (json['net'] as num).toDouble(),
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
      totalLoss: (json['total_loss'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billdate': billdate.toIso8601String(),
      'billno': billno,
      'sno': sno,
      'cuscod': cuscod,
      'cusnam': cusnam,
      'adrone': adrone,
      'adrtwo': adrtwo,
      'phone': phone,
      'tqty': tqty,
      'net': net,
      'total_profit': totalProfit,
      'total_loss': totalLoss,
    };
  }

  // Formatted getters for UI display
  String get fullAddress {
    final parts = <String>[];
    if (adrone != null && adrone!.isNotEmpty) parts.add(adrone!);
    if (adrtwo != null && adrtwo!.isNotEmpty) parts.add(adrtwo!);
    return parts.join(', ');
  }

  String get formattedTqty {
    return tqty.toStringAsFixed(2);
  }

  String get formattedNet {
    return net.toStringAsFixed(2);
  }

  String get displayName {
    return cusnam ?? 'Customer $cuscod';
  }

  String get formattedTotalProfit {
    return totalProfit.toStringAsFixed(2);
  }

  String get formattedTotalLoss {
    return totalLoss.toStringAsFixed(2);
  }

  bool get isProfitable {
    return totalProfit > 0;
  }

  bool get hasLoss {
    return totalLoss > 0;
  }
}
