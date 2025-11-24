import 'package:fashion_app/data/models/order_model.dart';
import 'package:fashion_app/data/repositories/order_repository.dart';
import 'package:fashion_app/data/sources/order_source.dart';
import 'package:fashion_app/views/user/order_detail_screen.dart';
import 'package:flutter/material.dart';

class OrderListScreen extends StatefulWidget {
  final String userId;

  const OrderListScreen({super.key, required this.userId});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderRepository _orderRepo = OrderRepository(OrderSource());
  int _selectedFilter = 0;

  final List<String> _filters = [
    'Tất cả',
    'Đang chờ',
    'Đã xác nhận',
    'Đang xử lý',
    'Đang giao hàng',
    'Hoàn thành',
    'Đã hủy',
  ];

  final Map<int, String> _statusMap = {
    1: 'status_001',
    2: 'status_002',
    3: 'status_003',
    4: 'status_004',
    5: 'status_006',
    6: 'status_005',
  };

  // Danh sách lý do hủy đơn hàng
  final List<CancelReason> _cancelReasons = [
    CancelReason('Thay đổi địa chỉ giao hàng', Icons.location_on),
    CancelReason('Thay đổi kích thước/số lượng', Icons.shopping_cart),
    CancelReason('Tìm thấy giá tốt hơn', Icons.attach_money),
    CancelReason('Không còn nhu cầu mua', Icons.cancel),
    CancelReason('Sản phẩm không đúng như mong đợi', Icons.warning),
    CancelReason('Thời gian giao hàng quá lâu', Icons.access_time),
    CancelReason('Khác', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedFilter == index,
                      label: Text(_filters[index]),
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    final stream =
        _selectedFilter == 0
            ? _orderRepo.getOrdersByUserId(widget.userId)
            : _orderRepo.getOrdersByStatus(
              widget.userId,
              _statusMap[_selectedFilter]!,
            );

    return StreamBuilder<List<FashionOrder>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có đơn hàng nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderItem(order);
          },
        );
      },
    );
  }

  Widget _buildOrderItem(FashionOrder order) {
    // Sử dụng trạng thái tính toán nếu có nhiều item
    final displayStatus =
        (order.shouldUseCalculatedStatus
            ? order.getCalculatedStatus()
            : order.orderStatus) ??
        'status_001'; // fallback
    final items = order.items ?? [];

    // Kiểm tra xem đơn hàng có thể hủy không (chỉ cho phép hủy khi đang chờ hoặc đã xác nhận)
    final bool canCancel =
        displayStatus == 'status_001' || displayStatus == 'status_002';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã đơn: ${order.orderId.length > 15 ? '${order.orderId.substring(0, 15)}...' : order.orderId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                // Hiển thị badge trạng thái
                _buildStatusBadge(displayStatus, order),
              ],
            ),
            const SizedBox(height: 12),

            // Items preview với trạng thái từng item
            if (items.isNotEmpty) ...[
              Column(
                children:
                    items.take(2).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            // Product image với status indicator
                            Stack(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(item.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // Status dot cho từng item
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(item.itemStatus),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity} x ${_formatPrice(item.price)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  // Hiển thị trạng thái item nếu khác với đơn hàng
                                  if (item.itemStatus != displayStatus &&
                                      items.length > 1) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _getStatusText(item.itemStatus),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getStatusColor(item.itemStatus),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              if (items.length > 2) ...[
                const SizedBox(height: 8),
                Text(
                  '+ ${items.length - 2} sản phẩm khác',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 12),
            ],

            // Footer với thông tin giá và số lượng
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${items.length} sản phẩm',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  _formatPrice(order.finalTotal),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            // Nút hành động
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(order: order),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Xem đơn hàng',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        canCancel ? () => _showCancelOrderDialog(order) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text(
                      'Hủy đơn hàng',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelOrderDialog(FashionOrder order) {
    String? selectedReason;
    final TextEditingController customReasonController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              // SỬA: Thêm insetPadding để dialog full màn hình hơn
              insetPadding: const EdgeInsets.all(20),
              // SỬA: Thêm shape cho Dialog
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                // SỬA: Thêm constraints để đảm bảo kích thước phù hợp
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.red.shade600,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Hủy đơn hàng',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content - SỬA: Dùng Expanded để chiếm không gian còn lại
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mã đơn: ${order.orderId}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Chọn lý do hủy đơn hàng:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Danh sách lý do - SỬA: Sử dụng ListView.separated
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _cancelReasons.length,
                              separatorBuilder:
                                  (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final reason = _cancelReasons[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          selectedReason == reason.text
                                              ? Colors.red.shade400
                                              : Colors.grey.shade300,
                                      width:
                                          selectedReason == reason.text ? 2 : 1,
                                    ),
                                    color:
                                        selectedReason == reason.text
                                            ? Colors.red.shade50
                                            : Colors.white,
                                  ),
                                  child: RadioListTile<String>(
                                    title: Row(
                                      children: [
                                        Icon(
                                          reason.icon,
                                          size: 22,
                                          color:
                                              selectedReason == reason.text
                                                  ? Colors.red.shade600
                                                  : Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            reason.text,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  selectedReason == reason.text
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                              color:
                                                  selectedReason == reason.text
                                                      ? Colors.red.shade700
                                                      : Colors.grey.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    value: reason.text,
                                    groupValue: selectedReason,
                                    onChanged: (value) {
                                      setDialogState(() {
                                        selectedReason = value;
                                        if (reason.text != 'Khác') {
                                          customReasonController.clear();
                                        }
                                      });
                                    },
                                    activeColor: Colors.red.shade600,
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // TextField cho lý do khác
                            if (selectedReason == 'Khác') ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Nhập lý do cụ thể:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: customReasonController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Mô tả lý do hủy đơn hàng của bạn...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ],

                            // Thông báo lỗi
                            const SizedBox(height: 16),
                            if (selectedReason == 'Khác' &&
                                customReasonController.text.isEmpty)
                              _buildWarningMessage('Vui lòng nhập lý do cụ thể')
                            else if (selectedReason == null)
                              _buildWarningMessage(
                                'Vui lòng chọn lý do hủy đơn',
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Footer buttons
                    Container(
                      padding: const EdgeInsets.all(20),

                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade400),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Quay lại',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final String reason =
                                    selectedReason == 'Khác'
                                        ? customReasonController.text.trim()
                                        : selectedReason ?? '';

                                if (reason.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vui lòng chọn hoặc nhập lý do hủy đơn hàng',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                _cancelOrder(order, reason);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Xác nhận hủy',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
          },
        );
      },
    );
  }

  // Helper widget cho thông báo cảnh báo
  Widget _buildWarningMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.orange.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.orange.shade600),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm xử lý hủy đơn hàng
  void _cancelOrder(FashionOrder order, String reason) async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Đang hủy đơn hàng...'),
                ],
              ),
            ),
      );

      // Gọi repository trực tiếp
      final bool success = await _orderRepo.cancelOrder(order.orderId, reason);

      // Ẩn loading
      if (mounted) Navigator.of(context).pop();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hủy đơn hàng ${order.orderId} thành công'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // UI sẽ tự động cập nhật qua Stream
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi hủy đơn hàng: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Widget hiển thị badge trạng thái
  Widget _buildStatusBadge(String status, FashionOrder order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getStatusText(status),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Hiển thị icon nếu có nhiều item với trạng thái khác nhau
          if (order.shouldUseCalculatedStatus &&
              order.items.map((item) => item.itemStatus).toSet().length >
                  1) ...[
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 12, color: Colors.white),
          ],
        ],
      ),
    );
  }

  // Cập nhật hàm getStatusText để dùng status ID
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

  // Cập nhật hàm getStatusColor để dùng status ID
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

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }
}

// Model cho lý do hủy đơn
class CancelReason {
  final String text;
  final IconData icon;

  CancelReason(this.text, this.icon);
}
