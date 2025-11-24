// order_pending_confirmation_screen.dart
import 'package:fashion_app/views/user/home_screen.dart';
import 'package:fashion_app/views/user/notification_screen.dart';
import 'package:flutter/material.dart';

class OrderPendingConfirmationScreen extends StatelessWidget {
  final String requestId;
  final int totalAmount;
  final int itemCount;
  final String userId;

  const OrderPendingConfirmationScreen({
    super.key,
    required this.requestId,
    required this.totalAmount,
    required this.itemCount,
    required this.userId, // Thêm userId vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Chờ xác nhận',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Icon chờ xác nhận
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pending_actions,
                        size: 40,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tiêu đề
                    const Text(
                      'Đang chờ xác nhận!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Thông báo
                    const Text(
                      'Đơn hàng của bạn đang chờ xác nhận. '
                      'Vui lòng vào mục Thông báo để xác nhận và hoàn tất đặt hàng.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Thông tin yêu cầu
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Mã yêu cầu', requestId),
                          const SizedBox(height: 8),
                          _buildInfoRow('Số sản phẩm', '$itemCount sản phẩm'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Tổng tiền', _formatPrice(totalAmount)),
                          const SizedBox(height: 8),
                          _buildInfoRow('Trạng thái', 'Chờ xác nhận'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Nút hành động
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Đi đến màn hình thông báo - truyền userId
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => NotificationScreen(
                                        userId: userId, // Truyền userId ở đây
                                        initialRequestId: requestId,
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Đến thông báo để xác nhận',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => HomeScreen(idUser: userId),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Tiếp tục mua hàng',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: label == 'Trạng thái' ? Colors.orange : Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    String priceStr = price.toString();
    String result = '';
    int count = 0;

    for (int i = priceStr.length - 1; i >= 0; i--) {
      result = priceStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }

    return '$resultđ';
  }
}
