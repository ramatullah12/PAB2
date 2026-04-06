class GoldModel {
  final String tanggal;
  final int harga;

  GoldModel({
    required this.tanggal,
    required this.harga,
  });
  factory GoldModel.fromMap(Map<dynamic, dynamic> map) {
    return GoldModel(
      tanggal: map['tanggal']?.toString() ?? '',
      harga: _parseHarga(map['harga']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tanggal': tanggal,
      'harga': harga,
    };
  }

  static int _parseHarga(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}