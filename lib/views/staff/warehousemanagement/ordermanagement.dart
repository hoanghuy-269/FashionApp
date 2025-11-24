import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ordermanagement extends StatefulWidget {
  final String shopID;

  const Ordermanagement({super.key, required this.shopID});

  @override
  State<Ordermanagement> createState() => _OrdermanagementState();
}

class _OrdermanagementState extends State<Ordermanagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders(); // Fetch orders on initialization
  }

  // Fetch orders based on shopID and itemStatus
  Future<void> _fetchOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders') // Fetch orders
          .get();

      List<Map<String, dynamic>> fetchedOrders = [];

      for (var orderDoc in snapshot.docs) {
        final orderId = orderDoc.id;

        // Fetch items from the order_items subcollection based on shopId and itemStatus
        final orderItemsSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('order_items')
            .where('shopId', isEqualTo: widget.shopID) // Filter by shopId
            .get();

        List<Map<String, dynamic>> orderItems = [];
        for (var itemDoc in orderItemsSnapshot.docs) {
          // Check item status and add item if it matches
          if (itemDoc['itemStatus'] == 'status_003' ||
              itemDoc['itemStatus'] == 'status_002') {
            orderItems.add(itemDoc.data() as Map<String, dynamic>);
          }
        }

        final customerAddress =
            orderDoc.data().containsKey('customerAddress')
                ? orderDoc['customerAddress']
                : 'No address available';
        final customerPhone =
            orderDoc.data().containsKey('customerPhone')
                ? orderDoc['customerPhone']
                : 'No phone number available';

        final userId =
            orderDoc.data().containsKey('userId') ? orderDoc['userId'] : null;
        String userName = 'Tên người dùng không có';

        // Lấy tên khách hàng từ collection 'users'
        if (userId != null) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (userSnapshot.exists) {
            userName = userSnapshot['name'] ?? 'Không có tên người dùng';
          }
        }

        if (orderItems.isNotEmpty) {
          fetchedOrders.add({
            'orderId': orderId,
            'userName': userName, // Lưu tên người dùng vào danh sách đơn hàng
            'customerAddress': customerAddress,
            'customerPhone': customerPhone,
            'orderItems': orderItems,
          });
        }
      }

      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Reload lại dữ liệu khi đổi tab
  Future<void> _reload() async {
    setState(() {
      isLoading = true;
    });
    await _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý đơn hàng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                // 👉 khi bấm tab thì reload lại dữ liệu
                onTap: (_) {
                  _reload();
                },
                indicator: BoxDecoration(
                  color: const Color(0xff4ea0ff),
                  borderRadius: BorderRadius.circular(999),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                overlayColor:
                    const MaterialStatePropertyAll(Colors.transparent),
                tabs: const [
                  Tab(text: 'Đang giao'),
                  Tab(text: 'Chưa giao'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? const Center(child: Text('Không có đơn hàng nào'))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab "Đang giao" - Lọc theo itemStatus = 'status_003'
                      _OrderListView(itemStatus: 'status_003', orders: orders),

                      // Tab "Chưa giao" - Lọc theo itemStatus = 'status_002'
                      _OrderListView(itemStatus: 'status_002', orders: orders),
                    ],
                  ),
      ),
    );
  }
}

class _OrderListView extends StatelessWidget {
  final String itemStatus;
  final List<Map<String, dynamic>> orders;

  const _OrderListView({required this.itemStatus, required this.orders});

  @override
  Widget build(BuildContext context) {
    final filteredOrders = orders.where((order) {
      // Filter the orders based on the itemStatus
      final items = order['orderItems'] as List;
      return items.any((item) => item['itemStatus'] == itemStatus);
    }).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          itemStatus == 'status_003'
              ? 'Không có đơn đang giao'
              : 'Không có đơn chưa giao',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return _OrderCard(
          order: filteredOrders[index],
          itemStatus: itemStatus,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String itemStatus;

  const _OrderCard({required this.order, required this.itemStatus});

  Color _statusColor() {
    if (itemStatus == 'status_003') {
      return const Color(0xff1abc9c); // Đang giao - xanh teal
    } else {
      return const Color(0xfff39c12); // Chưa giao - vàng cam
    }
  }

  String _statusText() {
    return itemStatus == 'status_003' ? 'Đang giao' : 'Chưa giao';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👉 MÃ ĐƠN HÀNG: nằm riêng một dòng, không chia sẻ với status
          Text(
            'Mã đơn hàng: ${order['orderId']}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          // 👉 STATUS CHIP: dòng riêng, lệch trái, không che ID
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor().withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _statusText(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor().withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Tên khách
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tên khách hàng: ${order['userName']}',
                  style: const TextStyle(fontSize: 13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Địa chỉ
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Địa chỉ: ${order['customerAddress']}',
                  style: const TextStyle(fontSize: 13.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Số điện thoại
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                'Số điện thoại: ${order['customerPhone']}',
                style: const TextStyle(fontSize: 13.5),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300, height: 1),
        ],
      ),
    );
  }
}
