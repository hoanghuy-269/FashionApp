class Voucher {
  final String code;
  final String name;
  final String amount;
  final bool isUsed;
  final bool isExpired;

  Voucher({
    required this.code,
    required this.name,
    required this.amount,
    this.isUsed = false,
    this.isExpired = false,
  });

  // Chuyển từ Map (Firebase) sang đối tượng Voucher
  factory Voucher.fromMap(Map<String, dynamic> data) {
    return Voucher(
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      amount: data['amount'] ?? '',
      isUsed: data['isUsed'] ?? false,
      isExpired: data['isExpired'] ?? false,
    );
  }

  // Chuyển Voucher thành Map để push lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'amount': amount,
      'isUsed': isUsed,
      'isExpired': isExpired,
    };
  }
}
