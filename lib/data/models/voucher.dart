import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  String voucherId; // Unique ID of the voucher
  String maVoucher; // Voucher code
  String tenVoucher; // Name of the voucher
  int? soLuong; // Quantity of the voucher (nullable)
  int daSuDung; // 0: unused, 1: used
  Timestamp ngayBatDau; // Start date of the voucher
  Timestamp ngayKetThuc; // End date of the voucher
  String trangThaiVoucher; // Status of the voucher (active, expired, etc.)
  String trangThaiId; // Reference to the status table
  double? phanTramGiamGia; // Discount percentage

  // Constructor
  Voucher({
    required this.voucherId,
    required this.maVoucher,
    required this.tenVoucher,
    this.soLuong,
    required this.daSuDung,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.trangThaiVoucher,
    required this.trangThaiId,
    this.phanTramGiamGia, // Discount percentage
  });

  // Convert Firestore document to Voucher object
  factory Voucher.fromMap(Map<String, dynamic> data, String documentId) {
    return Voucher(
      voucherId: documentId,
      maVoucher: data['ma_voucher'] ?? '',
      tenVoucher: data['ten_voucher'] ?? '',
      soLuong: data['so_luong'],
      daSuDung: data['da_su_dung'] ?? 0,
      ngayBatDau: data['ngay_bat_dau'],
      ngayKetThuc: data['ngay_ket_thuc'],
      trangThaiVoucher: data['TrangThaiVoucher'] ?? '',
      trangThaiId: data['trang_thai_id'] ?? '',
      phanTramGiamGia: data['phan_tram_giam_gia']?.toDouble(),
    );
  }

  // Convert Voucher object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'ma_voucher': maVoucher,
      'ten_voucher': tenVoucher,
      'so_luong': soLuong,
      'da_su_dung': daSuDung,
      'ngay_bat_dau': ngayBatDau,
      'ngay_ket_thuc': ngayKetThuc,
      'TrangThaiVoucher': trangThaiVoucher,
      'trang_thai_id': trangThaiId,
      'phan_tram_giam_gia': phanTramGiamGia,
    };
  }

  // Getter for discount percentage
  double get percentageDiscount => phanTramGiamGia ?? 0;  // Returns 0 if null
}
