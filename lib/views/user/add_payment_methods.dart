// lib/utils/add_payment_methods.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/payment_model.dart';

class PaymentMethodSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedPaymentMethods() async {
    final now = DateTime.now();

    final paymentMethods = [
      PaymentMethod(
        id: 'cod',
        name: 'Thanh toán khi nhận hàng',
        description: 'Thanh toán bằng tiền mặt khi nhận được hàng',
        icon: 'local_shipping',
        isActive: true,
        fee: 0.0,
        createdAt: now,
        updatedAt: now,
      ),
      PaymentMethod(
        id: 'ewallet',
        name: 'Ví điện tử',
        description: 'Thanh toán nhanh chóng qua Momo, ZaloPay, VNPay',
        icon: 'wallet',
        isActive: true,
        fee: 0.0,
        createdAt: now,
        updatedAt: now,
      ),
      PaymentMethod(
        id: 'bank_transfer',
        name: 'Chuyển khoản ngân hàng',
        description:
            'Chuyển khoản trực tiếp qua Internet Banking hoặc Mobile Banking',
        icon: 'account_balance',
        isActive: true,
        fee: 0.0,
        createdAt: now,
        updatedAt: now,
      ),
      PaymentMethod(
        id: 'credit_card',
        name: 'Thẻ tín dụng/ghi nợ',
        description: 'Thanh toán an toàn qua cổng thanh toán quốc tế',
        icon: 'credit_card',
        isActive: true,
        fee: 1.5, // 1.5% phí
        createdAt: now,
        updatedAt: now,
      ),
      PaymentMethod(
        id: 'visa_mastercard',
        name: 'Thẻ Visa/Mastercard',
        description: 'Thanh toán qua thẻ Visa, Mastercard quốc tế',
        icon: 'credit_score',
        isActive: true,
        fee: 2.0, // 2% phí
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final method in paymentMethods) {
      await _firestore
          .collection('payment_methods')
          .doc(method.id)
          .set(method.toMap());
    }

    print(
      '✅ Đã thêm ${paymentMethods.length} phương thức thanh toán lên Firebase',
    );
  }
}
