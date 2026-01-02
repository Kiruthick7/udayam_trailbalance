class SalesDetail {
  final DateTime billdate;
  final int billno;
  final int? ordno;
  final String? sno;
  final String cuscod;
  final String? cusnam;
  final String? adrone;
  final String? adrtwo;
  final String? phone;
  final String? salmannam;
  final String? salmanphon;
  final String? managername;
  final String? managerphon;
  final String? taxtyp;
  final String name;
  final double rate;
  final double qty;
  final double tprice;
  final double tqty;
  final double net;
  final double prcost;

  SalesDetail({
    required this.billdate,
    required this.billno,
    this.ordno,
    this.sno,
    required this.cuscod,
    this.cusnam,
    this.adrone,
    this.adrtwo,
    this.phone,
    this.salmannam,
    this.salmanphon,
    this.managername,
    this.managerphon,
    this.taxtyp,
    required this.name,
    required this.rate,
    required this.qty,
    required this.tprice,
    required this.tqty,
    required this.net,
    required this.prcost,
  });

  factory SalesDetail.fromJson(Map<String, dynamic> json) {
    return SalesDetail(
      billdate: DateTime.parse(json['billdate']),
      billno: json['billno'],
      ordno: json['ordno'],
      sno: json['sno'],
      cuscod: json['cuscod'],
      cusnam: json['cusnam'],
      adrone: json['adrone'],
      adrtwo: json['adrtwo'],
      phone: json['phone'],
      salmannam: json['salmannam'],
      salmanphon: json['salmanphon'],
      managername: json['managername'],
      managerphon: json['managerphon'],
      taxtyp: json['taxtyp'],
      name: json['name'] ?? '',
      rate: (json['rate'] as num).toDouble(),
      qty: (json['qty'] as num).toDouble(),
      tprice: (json['tprice'] as num).toDouble(),
      tqty: (json['tqty'] as num).toDouble(),
      net: (json['net'] as num).toDouble(),
      prcost: (json['prcostrate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billdate': billdate.toIso8601String().split('T')[0],
      'billno': billno,
      'ordno': ordno,
      'sno': sno,
      'cuscod': cuscod,
      'cusnam': cusnam,
      'adrone': adrone,
      'adrtwo': adrtwo,
      'phone': phone,
      'salmannam': salmannam,
      'salmanphon': salmanphon,
      'managername': managername,
      'managerphon': managerphon,
      'taxtyp': taxtyp,
      'name': name,
      'rate': rate,
      'qty': qty,
      'tprice': tprice,
      'tqty': tqty,
      'net': net,
      'prcostrate': prcost,
    };
  }

  // Get customer full address
  String get fullAddress {
    final parts = <String>[];
    if (adrone != null && adrone!.isNotEmpty) parts.add(adrone!);
    if (adrtwo != null && adrtwo!.isNotEmpty) parts.add(adrtwo!);
    return parts.join(', ');
  }

  // Get formatted rate
  String get formattedRate => rate.toStringAsFixed(2);

  // Get formatted quantity
  String get formattedQty => qty.toStringAsFixed(2);

  // Get formatted total price
  String get formattedTotalPrice => tprice.toStringAsFixed(2);

  // Get formatted net amount
  String get formattedNet => net.toStringAsFixed(2);

  // Calculate profit for this item
  double get itemProfit => (rate - prcost) * qty;

  // Get formatted profit
  String get formattedProfit {
    final profit = itemProfit;
    if (profit >= 0) {
      return profit.toStringAsFixed(2);
    } else {
      return '-${profit.abs().toStringAsFixed(2)}';
    }
  }

  // Check if item is profitable
  bool get isProfitable => rate >= prcost;
}

class SalesDetailRequest {
  final DateTime date;
  final int billno;
  final String cuscod;

  SalesDetailRequest({
    required this.date,
    required this.billno,
    required this.cuscod,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'billno': billno,
      'cuscod': cuscod,
    };
  }
}
