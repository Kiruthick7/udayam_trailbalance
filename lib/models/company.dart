class Company {
  final int snoId;
  final String fircodId; // Company code (ex: 1, 8.1, 8.2)
  final String fircod; // Company short code (ex: GHE01, STA01)
  final String firname; // Company name (ex: RR Marketing, Stationery)
  final String scgrpcod; // Sundry creditors
  final String sdgrpcod; // Sundry debtors
  final bool isSelected;

  Company({
    required this.snoId,
    required this.fircodId,
    required this.fircod,
    required this.firname,
    required this.scgrpcod,
    required this.sdgrpcod,
    this.isSelected = false,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        snoId: json['SNO_ID'],
        fircodId: json['FIRCOD_ID'],
        fircod: json['FIRCOD'],
        firname: json['FIRNAME'],
        scgrpcod: json['SCGRPCOD'],
        sdgrpcod: json['SDGRPCOD'],
      );

  Map<String, dynamic> toJson() => {
        'SNO_ID': snoId,
        'FIRCOD_ID': fircodId,
        'FIRCOD': fircod,
        'FIRNAME': firname,
        'SCGRPCOD': scgrpcod,
        'SDGRPCOD': sdgrpcod,
      };

  Company copyWith({bool? isSelected}) => Company(
        snoId: snoId,
        fircodId: fircodId,
        fircod: fircod,
        firname: firname,
        scgrpcod: scgrpcod,
        sdgrpcod: sdgrpcod,
        isSelected: isSelected ?? this.isSelected,
      );
}
