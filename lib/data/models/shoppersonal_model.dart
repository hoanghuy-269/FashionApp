class ShoppersonalModel {
  final String nhanVienId;
  final String shopId;
  final String hoTen;
  final String? soDienThoai;
  final String? taiKhoan;
  final String matKhau;
  final List<String> vaitroID;
  final String? cccd;
  final String? cccdMatTruoc;
  final String? cccdMatSau;
  final DateTime createdAt;

  ShoppersonalModel({
    required this.nhanVienId,
    required this.shopId,
    required this.hoTen,
    required this.soDienThoai,
    required this.taiKhoan,
    required this.matKhau,
    required this.vaitroID,
    required this.cccd,
    required this.cccdMatTruoc,
    required this.cccdMatSau,
    required this.createdAt,
  });
  factory ShoppersonalModel.fromJson(Map<String, dynamic> json) {
    return ShoppersonalModel(
      nhanVienId: json['nhanVienId'],
      shopId: json['shopId'],
      hoTen: json['hoTen'],
      soDienThoai: json['soDienThoai'],
      taiKhoan: json['taiKhoan'],
      matKhau: json['matKhau'],
      vaitroID: List<String>.from(json['vaitroID'] ?? []),
      cccd: json['cccd'],
      cccdMatTruoc: json['cccdMatTruoc'],
      cccdMatSau: json['cccdMatSau'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nhanVienId': nhanVienId,
      'shopId': shopId,
      'hoTen': hoTen,
      'soDienThoai': soDienThoai,
      'taiKhoan': taiKhoan,
      'matKhau': matKhau,
      'vaitroID': vaitroID,
      'cccd': cccd,
      'cccdMatTruoc': cccdMatTruoc,
      'cccdMatSau': cccdMatSau,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
