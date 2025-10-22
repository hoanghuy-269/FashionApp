import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  String voucherId; // Unique ID of the voucher
  String shopId; // ID of the shop that the voucher belongs to
  String maVoucher; // Voucher code
  String tenVoucher; // Name of the voucher
  String? soTien; // The amount (number) of the voucher (use this as the money field)
  int? soLuong; // Quantity of the voucher (nullable)
  int daSuDung; // 0: unused, 1: used
  Timestamp ngayBatDau; // Start date of the voucher
  Timestamp ngayKetThuc; // End date of the voucher
  String trangThaiVoucher; // Status of the voucher (active, expired, etc.)
  String trangThaiId; // Reference to the status table

  // Constructor
  Voucher({
    required this.voucherId,
    required this.shopId,
    required this.maVoucher,
    required this.tenVoucher,
    this.soTien,
    this.soLuong, // Nullable
    required this.daSuDung,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.trangThaiVoucher,
    required this.trangThaiId,
  });

  // Convert Firestore document to Voucher object
  factory Voucher.fromMap(Map<String, dynamic> data, String documentId) {
    return Voucher(
      voucherId: documentId, // Firestore document ID
      shopId: data['shop_id'] ?? '',
      maVoucher: data['ma_voucher'] ?? '',
      tenVoucher: data['ten_voucher'] ?? '',
      soTien: data['so_tien'], // Changed to 'soTien'
      soLuong: data['so_luong'], // Nullable
      daSuDung: data['da_su_dung'] ?? 0,
      ngayBatDau: data['ngay_bat_dau'],
      ngayKetThuc: data['ngay_ket_thuc'],
      trangThaiVoucher: data['TrangThaiVoucher'] ?? '',
      trangThaiId: data['trang_thai_id'] ?? '',
    );
  }

  // Getter for amount (returns the value of soTien if not null)
  String get amount => soTien ?? '';  // Returns the soTien field or an empty string if it's null

  // Convert Voucher object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'shop_id': shopId,
      'ma_voucher': maVoucher,
      'ten_voucher': tenVoucher,
      'so_tien': soTien, // Store the soTien value in Firestore
      'so_luong': soLuong, // Nullable
      'da_su_dung': daSuDung,
      'ngay_bat_dau': ngayBatDau,
      'ngay_ket_thuc': ngayKetThuc,
      'TrangThaiVoucher': trangThaiVoucher,
      'trang_thai_id': trangThaiId,
    };
  }
}
