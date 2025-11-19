import 'package:flutter/material.dart';

class Ordermanagement extends StatefulWidget {
  const Ordermanagement({super.key});

  @override
  State<Ordermanagement> createState() => _OrdermanagementState();
}

class _OrdermanagementState extends State<Ordermanagement> with TickerProviderStateMixin {
  // Controller cho TabBar
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý đơn hàng',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Đang giao'),
            Tab(text: 'Chưa giao'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab "Đang giao"
          _OrderListView(isShipped: true),

          // Tab "Chưa giao"
          _OrderListView(isShipped: false),
        ],
      ),
    );
  }
}

class _OrderListView extends StatelessWidget {
  final bool isShipped;

  const _OrderListView({required this.isShipped});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Bạn có thể thay đổi số lượng đơn hàng thực tế
      itemBuilder: (context, index) => _OrderCard(isShipped: isShipped),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final bool isShipped;

  const _OrderCard({required this.isShipped});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8), // Màu nền sáng cho card
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mã đơn hàng
          Text(
            'Mã Đơn hàng: #1234567890',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 8),
          // Địa chỉ và số điện thoại
          Text(
            'Địa chỉ: 123 Đường ABC, Quận 1, TP.HCM',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            'Số điện thoại: 0901234567',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          // Nếu là tab "Đang giao", hiển thị thêm mã shipper
          if (isShipped)
            Text(
              'Mã Shipper: SH12345',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 10),
          // Cải tiến giao diện card để hiển thị một đường viền
          Divider(color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
