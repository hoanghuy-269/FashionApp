import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Orderprocessing extends StatefulWidget {
  final String shopID;

  const Orderprocessing({super.key, required this.shopID});

  @override
  State<Orderprocessing> createState() => _OrderprocessingState();
}

class _OrderprocessingState extends State<Orderprocessing> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Lấy danh sách đơn hàng và sản phẩm theo shopId từ Firestore
  Future<void> _fetchOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get(); // Lấy tất cả đơn hàng

      List<Map<String, dynamic>> fetchedOrders = [];

      for (var orderDoc in snapshot.docs) {
        final orderId = orderDoc.id;

        // Lọc order_items theo shopId và itemStatus
        final orderItemsSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('order_items')
            .where('shopId', isEqualTo: widget.shopID)
            .where('itemStatus', isEqualTo: 'status_001') // Lọc theo itemStatus
            .get();

        List<Map<String, dynamic>> orderItems = [];
        for (var itemDoc in orderItemsSnapshot.docs) {
          var item = itemDoc.data() as Map<String, dynamic>;

          // Lấy giá từ order_item (price trong order_items)
          var price = item['price'];

          // Lấy thông tin màu sắc và kích thước từ bảng colors và sizes
          var colorId = item['colorId'];
          var sizeId = item['sizeId'];

          var colorName = 'Chưa có màu';
          var sizeName = 'Chưa có kích thước';

          // Lấy tên màu từ bảng colors
          if (colorId != null) {
            final colorSnapshot = await FirebaseFirestore.instance
                .collection('colors')
                .doc(colorId)
                .get();
            if (colorSnapshot.exists) {
              colorName = colorSnapshot['name'] ?? 'Chưa có màu';
            }
          }

          // Lấy tên kích thước từ bảng sizes
          if (sizeId != null) {
            final sizeSnapshot = await FirebaseFirestore.instance
                .collection('sizes')
                .doc(sizeId)
                .get();
            if (sizeSnapshot.exists) {
              sizeName = sizeSnapshot['name'] ?? 'Chưa có kích thước';
            }
          }

          // Cập nhật thông tin vào item
          item['colorName'] = colorName;
          item['sizeName'] = sizeName;
          item['price'] = price;  // Thêm giá vào item

          orderItems.add(item);
        }

        final customerAddress = orderDoc.data().containsKey('customerAddress')
            ? orderDoc['customerAddress']
            : 'Không có địa chỉ';
        final customerPhone = orderDoc.data().containsKey('customerPhone')
            ? orderDoc['customerPhone']
            : 'Không có số điện thoại';

       final userId = orderDoc.data().containsKey('userId') ? orderDoc['userId'] : null;
        String userName = 'Tên người dùng không có';

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
            'userName': userName,
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
      print('Lỗi khi lấy đơn hàng: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng đang xử lý'),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? const Center(child: Text('Không có đơn hàng nào đang xử lý'))
                : ListView.separated(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderCard(
                        order: order,
                        onProcessOrder: _handleOrderProcessing, // Truyền hàm xử lý
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(),
                  ),
      ),
    );
  }

  // Xử lý khi nhấn nút "Đóng gói" và cập nhật trạng thái itemStatus thành "status_002"
  Future<void> _handleOrderProcessing(String orderId) async {
    try {
      // Lọc các item trong order_items có itemStatus là 'status_001'
      final orderItemsSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('order_items')
          .where('itemStatus', isEqualTo: 'status_001') // Lọc itemStatus "Đang chờ"
          .get();

      // Cập nhật itemStatus của tất cả các item thành "status_002"
      for (var itemDoc in orderItemsSnapshot.docs) {
        await itemDoc.reference.update({
          'itemStatus': 'status_002', // Cập nhật itemStatus thành "Đã đóng gói"
        });
      }

      // Hiển thị thông báo xác nhận đã đóng gói
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đơn hàng đã được đóng gói!'),
          backgroundColor: Colors.green,
        ),
      );

      // Gọi lại _reloadData để tải lại dữ liệu sau khi cập nhật
      _reloadData();
    } catch (e) {
      print('Lỗi khi xử lý đơn hàng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi cập nhật trạng thái itemStatus.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm load lại dữ liệu sau khi cập nhật
  Future<void> _reloadData() async {
    setState(() {
      isLoading = true;  // Hiển thị loading khi reload
    });
    await _fetchOrders();  // Tải lại danh sách đơn hàng từ Firestore
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Future<void> Function(String orderId) onProcessOrder;

  const _OrderCard({required this.order, required this.onProcessOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          Text(
            'Mã Đơn hàng: ${order['orderId']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tên khách hàng: ${order['userName']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'Địa chỉ: ${order['customerAddress']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'Số điện thoại: ${order['customerPhone']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 8),
          Column(
            children: (order['orderItems'] as List<dynamic>)
                .map((item) => _ProductCard(product: item))
                .toList(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                _showConfirmationDialog(context, order['orderId']);
              },
              child: const Text('Đóng gói'),
            ),
          ),
        ],
      ),
    );
  }

  // Hiển thị hộp thoại xác nhận đóng gói
  Future<void> _showConfirmationDialog(BuildContext context, String orderId) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận đóng gói'),
          content: const Text('Bạn có chắc chắn muốn đóng gói đơn hàng này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onProcessOrder(orderId); // Gọi hàm xử lý khi xác nhận
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product['imageUrl'] ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['productName'] ?? 'Tên sản phẩm',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Số lượng: ${product['quantity']}'),
                const SizedBox(height: 4),
                // Hiển thị tên màu sắc, kích thước và giá
                Text('Màu: ${product['colorName']}'),
                Text('Size: ${product['sizeName']}'),
                Text('Giá: ${product['price']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
