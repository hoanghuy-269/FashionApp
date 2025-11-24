// notification_screen.dart
import 'package:fashion_app/data/models/app_notification_model.dart';
import 'package:fashion_app/data/repositories/notification_repository.dart';
import 'package:fashion_app/data/repositories/order_request_repository.dart';
import 'package:fashion_app/data/sources/order_service.dart';
import 'package:fashion_app/views/user/home_screen.dart';
import 'package:fashion_app/views/user/order_list_screen.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;
  final String? initialRequestId;

  const NotificationScreen({
    super.key,
    required this.userId,
    this.initialRequestId,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationRepository _notificationRepo = NotificationRepository();
  final OrderRequestRepository _orderRequestRepo = OrderRequestRepository();
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    if (widget.initialRequestId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToRequest(widget.initialRequestId!);
      });
    }
  }

  void _scrollToRequest(String requestId) {
    // TODO: Implement scroll to specific notification
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAllNotifications();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa tất cả'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _notificationRepo.getNotificationsByUserId(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không có thông báo nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header với số lượng thông báo
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.grey[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${notifications.length} thông báo',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearAllNotifications,
                      child: const Text(
                        'Xóa tất cả',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    final requiresAction = notification.data?['requiresAction'] == true;
    final isOrderSuccess = notification.type == 'order_success';
    final orderId = notification.data?['orderId'];

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(notification);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: notification.isRead ? Colors.white : Colors.blue[50],
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.isRead ? Colors.grey[200]! : Colors.blue[100]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với icon và tiêu đề
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getNotificationIcon(notification.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                  color:
                                      notification.isRead
                                          ? Colors.grey[700]
                                          : Colors.black,
                                ),
                              ),
                            ),
                            if (requiresAction)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Cần xác nhận',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isOrderSuccess)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Thành công',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteNotification(notification);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text('Xóa'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Thời gian
              Text(
                _formatTime(notification.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),

              // Nút hành động (nếu có)
              if (requiresAction) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _confirmOrder(notification),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận đặt hàng',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelOrder(notification),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Nút xem đơn hàng (cho thông báo thành công)
              if (isOrderSuccess && orderId != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _viewOrder(orderId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Xem đơn hàng',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'order_confirmation':
        icon = Icons.pending_actions;
        color = Colors.orange;
        break;
      case 'order_success':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.blue;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Future<void> _confirmOrder(AppNotification notification) async {
    final requestId = notification.data?['requestId'];
    if (requestId == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.shopping_cart_checkout_rounded,
                  color: Colors.green.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Xác nhận đơn hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn có chắc muốn xác nhận đơn hàng này?',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đơn hàng sẽ được xử lý và giao đến bạn',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text('HỦY'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _processOrderConfirmation(requestId, notification);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('XÁC NHẬN'),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _processOrderConfirmation(
    String requestId,
    AppNotification notification,
  ) async {
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
                  Text('Đang xác nhận đơn hàng...'),
                ],
              ),
            ),
      );

      // Tạo đơn hàng - hàm trả về bool
      final success = await _orderService.confirmOrderAndCreate(requestId);

      // Ẩn loading
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // XÓA thông báo xác nhận cũ
        await _notificationRepo.deleteNotification(notification.id);

        // Tạo orderId tạm thời (hoặc lấy từ service nếu có)
        final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

        // GỬI thông báo thành công mới
        await _sendOrderSuccessNotification(requestId, orderId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã xác nhận đơn hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Không thể tạo đơn hàng');
      }
    } catch (e) {
      // Ẩn loading nếu có lỗi
      if (mounted) Navigator.of(context).pop();

      // XỬ LÝ LỖI ĐẶC BIỆT - XUNG ĐỘT ĐẶT HÀNG
      if (_isConflictError(e.toString())) {
        await _showConflictErrorDialog(requestId, notification, e.toString());
      } else {
        await _showGenericErrorDialog(e.toString());
      }
    }
  }

  bool _isConflictError(String errorMessage) {
    return errorMessage.contains('không đủ số lượng') ||
        errorMessage.contains('hết hàng') ||
        errorMessage.contains('sold out') ||
        errorMessage.contains('conflict') ||
        errorMessage.contains('xung đột') ||
        errorMessage.contains('voucher đã hết') ||
        errorMessage.contains('đã có người mua');
  }

  Future<void> _showConflictErrorDialog(
    String requestId,
    AppNotification notification,
    String errorMessage,
  ) async {
    // Xác định loại lỗi cụ thể
    final isProductConflict =
        errorMessage.contains('không đủ số lượng') ||
        errorMessage.contains('hết hàng');
    final isVoucherConflict = errorMessage.contains('voucher đã hết');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 8,
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.orange.shade600,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isProductConflict
                          ? 'Sản phẩm đã hết hàng'
                          : 'Mã giảm giá không khả dụng',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isProductConflict
                        ? 'Rất tiếc, sản phẩm bạn muốn mua đã có người đặt trước. Vui lòng chọn sản phẩm khác.'
                        : 'Mã giảm giá bạn sử dụng đã hết lượt. Vui lòng chọn mã khác hoặc tiếp tục không sử dụng mã.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.blue.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Để tránh tình trạng này, hãy nhanh chóng xác nhận đơn hàng khi có thông báo.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          // Xóa thông báo và request khi người dùng đồng ý
                          await _notificationRepo.deleteNotification(
                            notification.id,
                          );
                          await _orderRequestRepo.cancelOrderRequest(requestId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã hủy yêu cầu đặt hàng'),
                              backgroundColor: Colors.orange,
                            ),
                          );

                          setState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'HIỂU RỒI',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Điều hướng về trang chủ hoặc trang sản phẩm
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      HomeScreen(idUser: widget.userId),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'MUA SẮM',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
    );
  }

  Future<void> _showGenericErrorDialog(String errorMessage) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lỗi xác nhận đơn hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đã xảy ra lỗi khi xác nhận đơn hàng:',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(fontSize: 13, color: Colors.red.shade800),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                child: const Text('ĐÓNG'),
              ),
            ],
          ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Lỗi xác nhận đơn hàng: $errorMessage'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _cancelOrder(AppNotification notification) async {
    final requestId = notification.data?['requestId'];
    if (requestId == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 10,
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade600,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hủy đơn hàng',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn có chắc muốn hủy đơn hàng này?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.orange.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Thao tác này không thể hoàn tác',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade700,
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
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'GIỮ LẠI',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _orderRequestRepo.cancelOrderRequest(requestId);
                          // Xóa thông báo khi hủy
                          await _notificationRepo.deleteNotification(
                            notification.id,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text('Đã hủy đơn hàng thành công'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.orange.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );

                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_outlined, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'HỦY ĐƠN',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
    );
  }

  // Hàm xem đơn hàng
  Future<void> _viewOrder(String orderId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderListScreen(userId: widget.userId),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(AppNotification notification) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa thông báo'),
            content: const Text('Bạn có chắc muốn xóa thông báo này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('HỦY'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('XÓA'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    try {
      await _notificationRepo.deleteNotification(notification.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa thông báo'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xóa thông báo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllNotifications() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa tất cả thông báo'),
            content: const Text('Bạn có chắc muốn xóa tất cả thông báo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('HỦY'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('XÓA TẤT CẢ'),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        await _notificationRepo.clearAllNotifications(widget.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa tất cả thông báo'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa thông báo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await _notificationRepo.markAsRead(notificationId);
  }

  Future<void> _sendOrderSuccessNotification(
    String requestId,
    String orderId,
  ) async {
    final notificationId =
        'NOTI_${DateTime.now().millisecondsSinceEpoch}_${widget.userId}';

    final notification = AppNotification(
      id: notificationId,
      userId: widget.userId,
      title: 'Đặt hàng thành công! 🎉',
      message: 'Đơn hàng của bạn đã được xác nhận và đang được xử lý.',
      type: 'order_success',
      data: {
        'requestId': requestId,
        'orderId': orderId, // Thêm orderId để dùng cho nút xem đơn hàng
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      createdAt: DateTime.now(),
    );

    await _notificationRepo.sendNotification(notification);
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';

    return '${date.day}/${date.month}/${date.year}';
  }
}
