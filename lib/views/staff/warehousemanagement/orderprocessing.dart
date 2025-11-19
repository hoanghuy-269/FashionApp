import 'package:flutter/material.dart';

class Orderprocessing extends StatefulWidget {
  const Orderprocessing({super.key});

  @override
  State<Orderprocessing> createState() => _OrderprocessingState();
}

class _OrderprocessingState extends State<Orderprocessing> {
  @override
  Widget build(BuildContext context) {
    // Tạm fake 6 đơn hàng để hiển thị
    final orders = List.generate(6, (index) => index);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4), // Sử dụng màu nền sáng nhẹ
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Đơn hàng',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề "Đơn hàng"
              const SizedBox(height: 8),
              const Text(
                'Danh sách đơn hàng đang xử lý',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Danh sách đơn hàng
              Expanded(
                child: ListView.separated(
                  itemCount: orders.length,
                  itemBuilder: (context, index) => const _OrderCard(),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white, // Nền card trắng
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mã đơn hàng
          const Text(
            'Mã Đơn hàng: #1234567890',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          // Địa chỉ và số điện thoại
          const Text(
            'Địa chỉ: 123 Đường ABC, Quận 1, TP.HCM',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'Số điện thoại: 0901234567',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          // Nếu đơn hàng cần xử lý (Đang giao), thêm mã shipper
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 8),
          // Nút "Đóng gói" (đơn hàng đang xử lý)
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 40,
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý khi bấm "đóng gói"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F9BFF), // Màu nút
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đóng gói',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
