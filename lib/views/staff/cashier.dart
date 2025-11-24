import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cashier extends StatefulWidget {
  final String shopID;
  final String? staffID;

  const Cashier({super.key, required this.shopID, this.staffID});

  @override
  State<Cashier> createState() => _CashierState();
}

class _CashierState extends State<Cashier> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];

  /// Tên nhân viên có role R02 trong shop (thu ngân)
  String cashierName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    /// 🔹 Mỗi lần đổi tab thì reload dữ liệu
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _reload();
      }
    });

    _loadCashierName();
    _fetchOrders();
  }

  /// Lấy tên nhân viên có roleIds = 'R02' trong shop hiện tại
  Future<void> _loadCashierName() async {
    try {
      final staffSnapshot =
          await FirebaseFirestore.instance
              .collection('shops')
              .doc(widget.shopID)
              .collection('staff')
              .where('roleIds', isEqualTo: 'R02')
              .limit(1)
              .get();

      if (staffSnapshot.docs.isNotEmpty) {
        final data = staffSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          cashierName = data['fullName'] ?? '';
        });
      }
    } catch (e) {
      print('Lỗi load nhân viên r02: $e');
    }
  }

  /// Lấy danh sách orders + order_items theo shopId
  Future<void> _fetchOrders() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      List<Map<String, dynamic>> fetchedOrders = [];

      for (var orderDoc in snapshot.docs) {
        final orderId = orderDoc.id;
        final orderData = orderDoc.data() as Map<String, dynamic>;

        final orderItemsSnapshot =
            await FirebaseFirestore.instance
                .collection('orders')
                .doc(orderId)
                .collection('order_items')
                .where('shopId', isEqualTo: widget.shopID)
                .get();

        List<Map<String, dynamic>> orderItems = [];

        for (var itemDoc in orderItemsSnapshot.docs) {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final status = itemData['itemStatus'];

          // chỉ giữ item có status_004 (chưa thanh toán) hoặc status_005 (đơn trả)
          if (status == 'status_004' || status == 'status_005') {
            orderItems.add({
              ...itemData,
              'orderItemId': itemDoc.id,
              'orderId': orderId,
            });
          }
        }

        if (orderItems.isNotEmpty) {
          fetchedOrders.add({
            'orderId': orderId,
            'customerAddress':
                orderData['customerAddress'] ?? 'Không có địa chỉ',
            'customerPhone':
                orderData['customerPhone'] ?? 'Không có số điện thoại',
            'orderItems': orderItems,
          });
        }
      }

      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi lấy đơn hàng cho Cashier: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _reload() async {
    setState(() {
      isLoading = true;
    });
    await _fetchOrders();
  }

  /// Xử lý xác nhận THANH TOÁN:
  /// - cộng tiền vào totalPrice của từng product trong shop_products
  /// - đổi itemStatus của item từ status_004 -> status_006
  Future<void> _handleConfirmPayment(Map<String, dynamic> order) async {
    try {
      final items = order['orderItems'] as List<dynamic>;

      for (final rawItem in items) {
        final item = rawItem as Map<String, dynamic>;

        if (item['itemStatus'] != 'status_004') continue;

        final String? productId = item['productId'];
        final String? orderId = item['orderId'];
        final String? orderItemId = item['orderItemId'];

        if (productId == null || orderId == null || orderItemId == null) {
          continue;
        }

        double itemTotal = 0;

        final rawTotal = item['totalPrice'];
        if (rawTotal != null && rawTotal is num) {
          itemTotal = rawTotal.toDouble();
        } else {
          final rawPrice = item['price'] ?? 0;
          final double price =
              rawPrice is num
                  ? rawPrice.toDouble()
                  : double.tryParse(rawPrice.toString()) ?? 0;

          final int qty =
              (item['quantity'] ?? 1) is int
                  ? item['quantity'] as int
                  : int.tryParse(item['quantity'].toString()) ?? 1;

          itemTotal = price * qty;
        }

        final productRef = FirebaseFirestore.instance
            .collection('shop_products')
            .doc(productId);

        final itemRef = FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('order_items')
            .doc(orderItemId);

        await FirebaseFirestore.instance.runTransaction((tx) async {
          final productSnap = await tx.get(productRef);
          if (!productSnap.exists) return;

          final data = productSnap.data() as Map<String, dynamic>;

          double currentTotalPrice;
          final rawProductTotal = data['totalPrice'] ?? 0;
          if (rawProductTotal is num) {
            currentTotalPrice = rawProductTotal.toDouble();
          } else {
            currentTotalPrice =
                double.tryParse(rawProductTotal.toString()) ?? 0;
          }

          tx.update(productRef, {'totalPrice': currentTotalPrice + itemTotal});

          tx.update(itemRef, {'itemStatus': 'status_006'});
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xác nhận thanh toán và cập nhật totalPrice.'),
        ),
      );

      await _reload();
    } catch (e) {
      print('Lỗi xử lý thanh toán: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi khi xác nhận thanh toán.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Xử lý xác nhận ĐƠN TRẢ:
  /// - cộng lại totalQuantity
  /// - trừ sold
  /// - cộng quantity cho đúng size trong product_sizes
  /// - đổi itemStatus -> status_006
  Future<void> _handleConfirmReturn(Map<String, dynamic> order) async {
    try {
      final items = order['orderItems'] as List<dynamic>;

      for (final rawItem in items) {
        final item = rawItem as Map<String, dynamic>;

        if (item['itemStatus'] != 'status_005') continue;

        final String? productId = item['productId'];
        final String? variantId = item['variantId'];
        final String? sizeId = item['sizeId'];
        final String? orderId = item['orderId'];
        final String? orderItemId = item['orderItemId'];

        if (productId == null ||
            variantId == null ||
            sizeId == null ||
            orderId == null ||
            orderItemId == null) {
          continue;
        }

        final int qty =
            (item['quantity'] ?? 1) is int
                ? item['quantity'] as int
                : int.tryParse(item['quantity'].toString()) ?? 1;

        final productRef = FirebaseFirestore.instance
            .collection("shop_products")
            .doc(productId);

        final sizeRef = FirebaseFirestore.instance
            .collection("shop_products")
            .doc(productId)
            .collection("shop_product_variants")
            .doc(variantId)
            .collection("product_sizes")
            .doc(sizeId);

        final itemRef = FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('order_items')
            .doc(orderItemId);

        await FirebaseFirestore.instance.runTransaction((tx) async {
          final productSnap = await tx.get(productRef);
          if (!productSnap.exists) return;

          final data = productSnap.data() as Map<String, dynamic>;

          int total =
              (data['totalQuantity'] ?? 0) is int
                  ? data['totalQuantity'] as int
                  : int.tryParse(data['totalQuantity'].toString()) ?? 0;

          int sold =
              (data['sold'] ?? 0) is int
                  ? data['sold'] as int
                  : int.tryParse(data['sold'].toString()) ?? 0;

          final sizeSnap = await tx.get(sizeRef);

          int? sizeQty;
          if (sizeSnap.exists) {
            final sizeData = sizeSnap.data() as Map<String, dynamic>;
            sizeQty =
                (sizeData['quantity'] ?? 0) is int
                    ? sizeData['quantity'] as int
                    : int.tryParse(sizeData['quantity'].toString()) ?? 0;
          }

          tx.update(productRef, {
            'totalQuantity': total + qty,
            'sold': (sold - qty) < 0 ? 0 : (sold - qty),
          });

          if (sizeQty != null) {
            tx.update(sizeRef, {'quantity': sizeQty + qty});
          }

          tx.update(itemRef, {'itemStatus': 'status_006'});
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xác nhận đơn trả & cập nhật kho.")),
      );

      await _reload();
    } catch (e) {
      print("Lỗi xử lý đơn trả: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Có lỗi khi xác nhận đơn trả."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER: back + tên nhân viên r02
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nhân viên thu ngân',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          cashierName.isEmpty ? "Đang tải..." : cashierName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 🔹 ĐÃ BỎ NÚT REFRESH Ở ĐÂY
                ],
              ),
            ),

            // TAB BUTTONS
            Container(
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xffe6efff),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xff4ea0ff),
                  borderRadius: BorderRadius.circular(30),
                ),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                tabs: const [
                  Tab(text: "Chưa thanh toán"),
                  Tab(text: "Đơn trả"),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // TAB CONTENT
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : orders.isEmpty
                      ? const Center(
                        child: Text('Không có đơn nào cho shop này'),
                      )
                      : TabBarView(
                        controller: _tabController,
                        children: [
                          _OrderListView(
                            itemStatus: 'status_004',
                            orders: orders,
                            isReturn: false,
                            onConfirmPayment: _handleConfirmPayment,
                            onConfirmReturn: _handleConfirmReturn,
                          ),
                          _OrderListView(
                            itemStatus: 'status_005',
                            orders: orders,
                            isReturn: true,
                            onConfirmPayment: _handleConfirmPayment,
                            onConfirmReturn: _handleConfirmReturn,
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderListView extends StatelessWidget {
  final String itemStatus;
  final List<Map<String, dynamic>> orders;
  final bool isReturn;
  final Future<void> Function(Map<String, dynamic>) onConfirmPayment;
  final Future<void> Function(Map<String, dynamic>) onConfirmReturn;

  const _OrderListView({
    required this.itemStatus,
    required this.orders,
    required this.isReturn,
    required this.onConfirmPayment,
    required this.onConfirmReturn,
  });

  @override
  Widget build(BuildContext context) {
    final filteredOrders =
        orders.where((order) {
          final items = order['orderItems'] as List;
          return items.any((item) => item['itemStatus'] == itemStatus);
        }).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          isReturn ? 'Không có đơn trả nào' : 'Không có đơn chưa thanh toán',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return _OrderCard(
          order: filteredOrders[index],
          isReturn: isReturn,
          onConfirmPayment: onConfirmPayment,
          onConfirmReturn: onConfirmReturn,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isReturn;
  final Future<void> Function(Map<String, dynamic>) onConfirmPayment;
  final Future<void> Function(Map<String, dynamic>) onConfirmReturn;

  const _OrderCard({
    required this.order,
    required this.isReturn,
    required this.onConfirmPayment,
    required this.onConfirmReturn,
  });

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await onConfirm();
                },
                child: const Text('Đồng ý'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = order['orderItems'] as List;

    double total = 0;
    for (var item in items) {
      final raw = item['totalPrice'] ?? item['price'] ?? 0;
      final price = raw is num ? raw.toDouble() : 0.0;
      total += price;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng trên: mã đơn (không có nút)
          Text(
            isReturn
                ? 'Mã đơn trả: ${order['orderId']}'
                : 'Mã đơn hàng: ${order['orderId']}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 6),
          Text(
            'Địa chỉ: ${order['customerAddress']}',
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            'SĐT: ${order['customerPhone']}',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),

          // Dòng: Tổng tiền + nút xác nhận bên phải
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tổng tiền: $total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isReturn ? Colors.redAccent : const Color(0xff4ea0ff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  onPressed: () {
                    if (isReturn) {
                      _showConfirmDialog(
                        context,
                        title: 'Xác nhận đơn trả',
                        message:
                            'Bạn có chắc chắn muốn xác nhận xử lý đơn trả này?',
                        onConfirm: () => onConfirmReturn(order),
                      );
                    } else {
                      _showConfirmDialog(
                        context,
                        title: 'Xác nhận thanh toán',
                        message:
                            'Bạn có chắc chắn khách đã thanh toán đơn hàng này?',
                        onConfirm: () => onConfirmPayment(order),
                      );
                    }
                  },
                  child: Text(
                    isReturn ? 'Xác nhận đơn trả' : 'Xác nhận thanh toán',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(),

          ...items.take(2).map((item) {
            final name = item['productName'] ?? 'Sản phẩm';
            final qty = item['quantity'] ?? 1;
            final raw = item['price'] ?? 0;
            final price = raw is num ? raw.toDouble() : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('x$qty', style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    '$price',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          if (items.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${items.length - 2} sản phẩm khác',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
