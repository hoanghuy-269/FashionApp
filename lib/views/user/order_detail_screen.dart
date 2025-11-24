import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/models/order_model.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final FashionOrder order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status
            _buildOrderStatus(),
            const SizedBox(height: 24),

            // Order info
            _buildOrderInfo(),
            const SizedBox(height: 24),
            // Shipping info
            _buildShippingInfo(),
            // Items list
            _buildItemsList(),
            const SizedBox(height: 24),

            // Price summary
            _buildPriceSummary(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(order.orderStatus),
                color: _getStatusColor(order.orderStatus),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusText(order.orderStatus),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.orderStatus),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã đơn: ${order.orderId}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin đơn hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Ngày đặt', _formatDate(order.createdAt)),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Phương thức',
              _getPaymentMethod(order.paymentMethodId),
            ),
            if (order.cancellationReason != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Lý do hủy', order.cancellationReason!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sản phẩm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => _buildOrderItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        collapsedIconColor: Colors.grey,
        iconColor: Colors.black,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Thay thế bằng FutureBuilder để lấy tên màu và size
                  _buildColorSizeInfo(item),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatPrice(item.price)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Product status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getProductStatusColor(
                        item.itemStatus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getProductStatusColor(
                          item.itemStatus,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getProductStatusText(item.itemStatus),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getProductStatusColor(item.itemStatus),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget để hiển thị thông tin màu và size với tên
  Widget _buildColorSizeInfo(OrderItem item) {
    return FutureBuilder<Map<String, String>>(
      future: _getColorAndSizeNames(item.colorId, item.sizeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Phân loại: Đang tải...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Phân loại: ${item.colorId} - ${item.sizeId}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          );
        } else if (snapshot.hasData) {
          final names = snapshot.data!;
          return Text(
            'Phân loại: ${names['colorName']} - ${names['sizeName']}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          );
        } else {
          return Text(
            'Phân loại: ${item.colorId} - ${item.sizeId}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          );
        }
      },
    );
  }

  // Widget để hiển thị chi tiết màu và size trong phần mở rộng
  Widget _buildColorSizeDetail(OrderItem item) {
    return FutureBuilder<Map<String, String>>(
      future: _getColorAndSizeNames(item.colorId, item.sizeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Màu sắc', 'Đang tải...'),
              const SizedBox(height: 8),
              _buildDetailRow('Kích thước', 'Đang tải...'),
            ],
          );
        } else if (snapshot.hasData) {
          final names = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Màu sắc', names['colorName']!),
              const SizedBox(height: 8),
              _buildDetailRow('Kích thước', names['sizeName']!),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Màu sắc', item.colorId),
              const SizedBox(height: 8),
              _buildDetailRow('Kích thước', item.sizeId),
            ],
          );
        }
      },
    );
  }

  // Hàm lấy tên màu và size từ Firebase
  Future<Map<String, String>> _getColorAndSizeNames(
    String colorId,
    String sizeId,
  ) async {
    try {
      final colorFuture =
          FirebaseFirestore.instance.collection('colors').doc(colorId).get();

      final sizeFuture =
          FirebaseFirestore.instance.collection('sizes').doc(sizeId).get();

      final results = await Future.wait([colorFuture, sizeFuture]);

      final colorDoc = results[0];
      final sizeDoc = results[1];

      return {
        'colorName':
            colorDoc.exists ? (colorDoc.data()?['name'] ?? colorId) : colorId,
        'sizeName':
            sizeDoc.exists ? (sizeDoc.data()?['name'] ?? sizeId) : sizeId,
      };
    } catch (e) {
      // Trả về ID nếu có lỗi
      return {'colorName': colorId, 'sizeName': sizeId};
    }
  }

  Widget _buildPriceSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPriceRow('Tạm tính', order.itemsTotal),
            _buildPriceRow('Phí vận chuyển', order.shippingFee),
            if (order.discount > 0) _buildPriceRow('Giảm giá', -order.discount),
            const Divider(height: 24),
            _buildPriceRow('Tổng cộng', order.finalTotal, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin giao hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Địa chỉ', order.customerAddress),
            const SizedBox(height: 8),
            _buildInfoRow('Số điện thoại', order.customerPhone),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount >= 0 ? '' : '-'}${_formatPrice(amount.abs())}',
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.red : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Status methods for order
  String _getStatusText(String statusId) {
    switch (statusId) {
      case 'status_001':
        return 'Đang chờ';
      case 'status_002':
        return 'Đã xác nhận';
      case 'status_003':
        return 'Đang giao hàng';
      case 'status_004':
        return 'Hoàn thành';
      case 'status_005':
        return 'Đã hủy';
      default:
        return 'Đang chờ';
    }
  }

  Color _getStatusColor(String statusId) {
    switch (statusId) {
      case 'status_001':
        return Colors.orange;
      case 'status_002':
        return Colors.blue;
      case 'status_003':
        return Colors.purple;
      case 'status_004':
        return Colors.green;
      case 'status_005':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String statusId) {
    switch (statusId) {
      case 'status_001':
        return Icons.pending_actions;
      case 'status_002':
        return Icons.check_circle_outline;
      case 'status_003':
        return Icons.autorenew;
      case 'status_004':
        return Icons.local_shipping;
      case 'status_006':
        return Icons.check_circle;
      case 'status_005':
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }

  // Status methods for individual products - SỬA LẠI TOÀN BỘ
  String _getProductStatusText(String statusId) {
    switch (statusId) {
      case 'status_001':
        return 'Chờ xác nhận';
      case 'status_002':
        return 'Đã xác nhận';
      case 'status_003':
        return 'Đang giao hàng';
      case 'status_004':
        return 'Giao hàng thành công';
      case 'status_005':
        return 'Đã hủy';
      default:
        return 'Chờ xác nhận';
    }
  }

  Color _getProductStatusColor(String statusId) {
    switch (statusId) {
      case 'status_001':
        return Colors.orange;
      case 'status_002':
        return Colors.blue;
      case 'status_003':
        return Colors.purple;
      case 'status_004':
        return Colors.green;
      case 'status_005':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Timeline status methods
  String _getTimelineStatusText(String statusId) {
    switch (statusId) {
      case 'timeline_001':
        return 'Đơn hàng được đặt';
      case 'timeline_002':
        return 'Shop xác nhận đơn hàng';
      case 'timeline_003':
        return 'Shop đóng gói sản phẩm';
      case 'timeline_004':
        return 'Đã bàn giao cho đơn vị vận chuyển';
      case 'timeline_005':
        return 'Đang giao hàng';
      case 'timeline_006':
        return 'Giao hàng thành công';
      default:
        return 'Cập nhật trạng thái';
    }
  }

  Color _getTimelineStatusColor(String statusId) {
    switch (statusId) {
      case 'timeline_001':
        return Colors.orange;
      case 'timeline_002':
        return Colors.blue;
      case 'timeline_003':
        return Colors.purple;
      case 'timeline_004':
        return Colors.indigo;
      case 'timeline_005':
        return Colors.blueAccent;
      case 'timeline_006':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTimelineStatusIcon(String statusId) {
    switch (statusId) {
      case 'timeline_001':
        return Icons.shopping_cart;
      case 'timeline_002':
        return Icons.check;
      case 'timeline_003':
        return Icons.inventory_2;
      case 'timeline_004':
        return Icons.local_shipping;
      case 'timeline_005':
        return Icons.delivery_dining;
      case 'timeline_006':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _getPaymentMethod(String methodId) {
    switch (methodId) {
      case 'cod':
        return 'Thanh toán khi nhận hàng';
      case 'banking':
        return 'Chuyển khoản ngân hàng';
      case 'momo':
        return 'Ví MoMo';
      default:
        return 'Thanh toán khi nhận hàng';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }
}

// Thêm model cho timeline sản phẩm (nếu chưa có)
class ProductTimeline {
  final String status;
  final DateTime timestamp;
  final String? note;

  ProductTimeline({required this.status, required this.timestamp, this.note});
}
