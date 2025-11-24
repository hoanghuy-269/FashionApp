import 'dart:math';

import 'package:fashion_app/data/models/address.dart';
import 'package:fashion_app/data/models/app_notification_model.dart';
import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/models/order_model.dart';
import 'package:fashion_app/data/models/order_request.dart';
import 'package:fashion_app/data/models/payment_model.dart';
import 'package:fashion_app/data/repositories/notification_repository.dart';
import 'package:fashion_app/data/repositories/order_request_repository.dart';
import 'package:fashion_app/data/repositories/payment_repo.dart';
import 'package:fashion_app/viewmodels/order_viewmodel.dart';
import 'package:fashion_app/views/user/add_payment_methods.dart';
import 'package:fashion_app/views/user/address_screen.dart';
import 'package:fashion_app/views/user/address_selection_screen.dart';
import 'package:fashion_app/views/user/order_pending_confirmation_screen.dart';
import 'package:fashion_app/views/user/order_pending_screen.dart';
import 'package:fashion_app/views/user/order_success.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/cart_model.dart';

class CheckoutScreen extends StatefulWidget {
  final String userId;
  final List<CartItem> selectedItems;
  final String? selectedVoucher;
  final bool isFromCart;
  const CheckoutScreen({
    super.key,
    required this.userId,
    required this.selectedItems,
    this.selectedVoucher,
    this.isFromCart = true,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isVoucherExpanded = false;
  String? _selectedVoucher;
  List<Map<String, dynamic>> _vouchers = [];
  List<Map<String, dynamic>> _displayedVouchers = [];
  int _voucherDisplayLimit = 2;

  Map<String, String> _shopNames = {};
  final PaymentMethodRepository _paymentMethodRepo = PaymentMethodRepository();
  List<PaymentMethod> _paymentMethods = [];
  String _selectedPaymentMethodId = '';
  bool _isLoadingPaymentMethods = true;
  Address? selectedAddress;
  final OrderViewModel _orderViewModel = OrderViewModel();
  bool _isPlacingOrder = false;
  final OrderRequestRepository _orderRequestRepo = OrderRequestRepository();
  final NotificationRepository _notificationRepo = NotificationRepository();
  @override
  void initState() {
    super.initState();
    _selectedVoucher = widget.selectedVoucher;
    _loadVouchersFromFirebase();
    _loadShopNamesFromFirebase();
    _loadPaymentMethods();
    _loadDefaultAddress();
  }

  // Thêm vào _CheckoutScreenState
  Future<void> _loadDefaultAddress() async {
    try {
      print('🔄 Đang load địa chỉ mặc định...');

      final snapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userId)
              .collection("addresses")
              .where("isDefault", isEqualTo: true)
              .orderBy(
                "timestamp",
                descending: true,
              ) // SỬA createdAt thành timestamp
              .limit(1)
              .get();

      print('📊 Kết quả query: ${snapshot.docs.length} địa chỉ');

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final addressData = doc.data();

        print('✅ Tìm thấy địa chỉ mặc định:');
        print('   - ID: ${doc.id}');
        print('   - Name: ${addressData['name']}');
        print('   - Phone: ${addressData['phone']}');
        print('   - Detail: ${addressData['detail']}');
        print('   - isDefault: ${addressData['isDefault']}');
        print('   - timestamp: ${addressData['timestamp']}');

        final address = Address(
          id: doc.id,
          name: addressData['name'] ?? '',
          phone: addressData['phone'] ?? '',
          detail: addressData['detail'] ?? '',
          ward: addressData['ward'] ?? '',
          district: addressData['district'] ?? '',
          province: addressData['province'] ?? '',
          isDefault: addressData['isDefault'] ?? false,
          createdAt: addressData['timestamp'] as Timestamp?, // SỬA Ở ĐÂY
        );

        setState(() {
          selectedAddress = address;
          print('🎯 Đã cập nhật selectedAddress: ${address.name}');
        });
      } else {
        print(
          '⚠️ Không tìm thấy địa chỉ mặc định, thử lấy địa chỉ đầu tiên...',
        );
        _loadFirstAddress();
      }
    } catch (e) {
      print('❌ Lỗi load địa chỉ mặc định: $e');
      _loadFirstAddress();
    }
  }

  // Và sửa hàm _loadFirstAddress tương tự:
  Future<void> _loadFirstAddress() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userId)
              .collection("addresses")
              .orderBy("timestamp", descending: true) // SỬA Ở ĐÂY
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final addressData = doc.data();

        final address = Address(
          id: doc.id,
          name: addressData['name'] ?? '',
          phone: addressData['phone'] ?? '',
          detail: addressData['detail'] ?? '',
          ward: addressData['ward'] ?? '',
          district: addressData['district'] ?? '',
          province: addressData['province'] ?? '',
          isDefault: addressData['isDefault'] ?? false,
          createdAt: addressData['timestamp'] as Timestamp?, // SỬA Ở ĐÂY
        );

        setState(() {
          selectedAddress = address;
          print('🎯 Đã load địa chỉ đầu tiên: ${address.name}');
        });
      } else {
        print('📭 Không có địa chỉ nào');
        setState(() {
          selectedAddress = null;
        });
      }
    } catch (e) {
      print('❌ Lỗi load địa chỉ đầu tiên: $e');
      setState(() {
        selectedAddress = null;
      });
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      print('🔄 Bắt đầu load payment methods...');

      final methods =
          await _paymentMethodRepo.getActivePaymentMethodsFromServer();

      if (mounted) {
        print('✅ Load từ SERVER: ${methods.length} methods');
        for (var method in methods) {
          print('   - ${method.id}: ${method.name}');
        }

        // FILTER để loại bỏ phương thức trùng lặp
        final filteredMethods =
            methods.where((method) {
              return method.id != 'dank_transfer';
            }).toList();

        // SẮP XẾP: COD luôn đầu tiên
        filteredMethods.sort((a, b) {
          if (a.id == 'cod') return -1;
          if (b.id == 'cod') return 1;

          // Thứ tự ưu tiên sau COD
          final order = [
            'ewallet',
            'bank_transfer',
            'credit_card',
            'visa_mastercard',
          ];
          final indexA = order.indexOf(a.id);
          final indexB = order.indexOf(b.id);

          // Nếu không có trong order list thì để cuối
          if (indexA == -1) return 1;
          if (indexB == -1) return -1;

          return indexA.compareTo(indexB);
        });

        // CẬP NHẬT STATE
        setState(() {
          _paymentMethods = filteredMethods;
          _isLoadingPaymentMethods = false;
          if (_paymentMethods.isNotEmpty && _selectedPaymentMethodId.isEmpty) {
            _selectedPaymentMethodId = _paymentMethods.first.id;
          }
        });

        print('🎯 Đã cập nhật state với ${_paymentMethods.length} methods');
      }
    } catch (e) {
      print('❌ Lỗi load payment methods: $e');
      setState(() {
        _isLoadingPaymentMethods = false;
      });
    }
  }

  // LOAD TÊN SHOP TỪ FIREBASE
  Future<void> _loadShopNamesFromFirebase() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('shops').get();

      Map<String, String> loadedShopNames = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        loadedShopNames[doc.id] = data['shopName'] ?? doc.id;
      }

      setState(() {
        _shopNames = loadedShopNames;
      });
    } catch (e) {
      print('Lỗi load shop names: $e');
    }
  }

  // HÀM LẤY TÊN SHOP TỪ ID
  String _getShopName(String shopId) {
    return _shopNames[shopId] ?? shopId;
  }

  // LOAD VOUCHER TỪ FIREBASE - GIỐNG CARTSCREEN
  Future<void> _loadVouchersFromFirebase() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('discounts')
              .where('TrangThaiVoucher', isEqualTo: "Đang hoạt động")
              .get();

      List<Map<String, dynamic>> loadedVouchers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final now = DateTime.now();
        final startDate = (data['ngay_bat_dau'] as Timestamp).toDate();
        final endDate = (data['ngay_ket_thuc'] as Timestamp).toDate();

        // Kiểm tra voucher còn hiệu lực
        if (now.isAfter(startDate) && now.isBefore(endDate)) {
          loadedVouchers.add({
            'id': doc.id,
            'code': data['ma_voucher'] ?? '',
            'name': data['ten_voucher'] ?? '',
            'discount': 'Giảm ${data['phan_tram_giam_gia']}%',
            'description':
                '${data['ten_voucher']} - Còn lại: ${data['so_luong'] - data['da_su_dung']}',
            'percentage': data['phan_tram_giam_gia'] ?? 0,
            'usedCount': data['da_su_dung'] ?? 0,
            'quantity': data['so_luong'] ?? 0,
            'startDate': startDate,
            'endDate': endDate,
          });
        }
      }

      setState(() {
        _vouchers = loadedVouchers;
        _updateDisplayedVouchers();
      });
    } catch (e) {
      print('Lỗi load vouchers: $e');
    }
  }

  // CẬP NHẬT DANH SÁCH VOUCHER HIỂN THỊ
  void _updateDisplayedVouchers() {
    setState(() {
      _displayedVouchers = _vouchers.take(_voucherDisplayLimit).toList();
    });
  }

  // TÍNH TỔNG TIỀN
  double get _totalAmount {
    return widget.selectedItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // TÍNH TIỀN GIẢM GIÁ TỪ VOUCHER
  double get _discountAmount {
    if (_selectedVoucher == null) return 0;

    try {
      final voucher = _vouchers.firstWhere(
        (v) => v['code'] == _selectedVoucher,
      );

      final percentage = voucher['percentage'] ?? 0;
      return _totalAmount * percentage / 100;
    } catch (e) {
      return 0;
    }
  }

  double get _finalAmount => _totalAmount - _discountAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THÔNG TIN GIAO HÀNG
                  _buildDeliveryInfo(),
                  const SizedBox(height: 20),

                  // DANH SÁCH SẢN PHẨM
                  _buildOrderItems(),
                  const SizedBox(height: 20),

                  // PHƯƠNG THỨC THANH TOÁN
                  _buildPaymentMethod(),
                ],
              ),
            ),
          ),
          // PHẦN MÃ GIẢM GIÁ
          _buildVoucherSection(),
          // TỔNG KẾT VÀ NÚT ĐẶT HÀNG CỐ ĐỊNH BÊN DƯỚI
          _buildBottomCheckoutSection(),
        ],
      ),
    );
  }

  // TỔNG KẾT VÀ NÚT ĐẶT HÀNG CỐ ĐỊNH BÊN DƯỚI
  Widget _buildBottomCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // PHẦN THÔNG TIN TIỀN BÊN TRÁI
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TIẾT KIỆM (nếu có)
                if (_discountAmount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiết kiệm:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[600],
                        ),
                      ),
                      Text(
                        '-${_formatPrice(_discountAmount.toInt())}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 4),

                // THÀNH TIỀN
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thành tiền:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatPrice(_finalAmount.toInt()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed:
                  _isPlacingOrder
                      ? null
                      : _placeOrder, // Disable khi đang đặt hàng
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isPlacingOrder
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        'ĐẶT HÀNG',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    final address = selectedAddress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị tên và số điện thoại nếu có
          if (address != null)
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  address.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "(+084) (${address.phone})",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            )
          else
            const Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Chưa có địa chỉ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 8),

          // HIỂN THỊ ĐỊA CHỈ
          Text(
            _getFormattedAddress(),
            style: TextStyle(
              fontSize: 14,
              color: address != null ? Colors.black : Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () async {
                final selectedAddress = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddressSelectionScreen(userId: widget.userId),
                  ),
                );

                if (selectedAddress != null && selectedAddress is Address) {
                  setState(() {
                    this.selectedAddress = selectedAddress;
                  });
                }
              },
              child: Text(
                address != null ? 'Thay đổi' : 'Chọn địa chỉ',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Trong CheckoutScreen
  // Trong CheckoutScreen
  String _getFormattedAddress() {
    if (selectedAddress == null) return "Vui lòng chọn địa chỉ giao hàng";

    final detail = selectedAddress!.detail;
    final ward = selectedAddress!.ward;
    final district = selectedAddress!.district;
    final province = selectedAddress!.province;

    return "$detail, $ward, $district, $province";
  }

  // DANH SÁCH SẢN PHẨM ĐÃ CHỌN - NHÓM THEO SHOP
  Widget _buildOrderItems() {
    // NHÓM SẢN PHẨM THEO SHOP
    final Map<String, List<CartItem>> groupedItems = _groupItemsByShop(
      widget.selectedItems,
    );

    return Column(
      children:
          groupedItems.entries.map((entry) {
            final shopId = entry.key;
            final items = entry.value;
            final shopName = _getShopName(shopId);
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER SHOP
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          shopName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // DANH SÁCH SẢN PHẨM TRONG SHOP
                  Column(
                    children:
                        items
                            .map(
                              (item) => Column(
                                children: [
                                  _buildOrderItem(item),
                                  if (items.last != item)
                                    const SizedBox(height: 12),
                                ],
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // HÀM NHÓM SẢN PHẨM THEO SHOP
  Map<String, List<CartItem>> _groupItemsByShop(List<CartItem> items) {
    final Map<String, List<CartItem>> grouped = {};

    for (var item in items) {
      if (!grouped.containsKey(item.shopId)) {
        grouped[item.shopId] = [];
      }
      grouped[item.shopId]!.add(item);
    }

    return grouped;
  }

  Widget _buildOrderItem(CartItem item) {
    return Row(
      children: [
        // ẢNH SẢN PHẨM
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[100],
          ),
          child:
              item.imageUrl.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(item.imageUrl, fit: BoxFit.cover),
                  )
                  : Icon(Icons.shopping_bag, color: Colors.grey[400], size: 24),
        ),
        const SizedBox(width: 12),

        // THÔNG TIN SẢN PHẨM
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Size: ${item.sizeId}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatPrice(item.price)} • Số lượng: ${item.quantity}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder() async {
    // Kiểm tra địa chỉ
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn địa chỉ giao hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kiểm tra phương thức thanh toán
    if (_selectedPaymentMethodId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn phương thức thanh toán'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: Icon(
              Icons.shopping_cart_rounded,
              size: 48,
              color: Colors.blue.shade500,
            ),
            title: const Text(
              'Xác nhận đặt hàng',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bạn sắp đặt mua:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Số lượng:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '${widget.selectedItems.length} sản phẩm',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Thành tiền:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            _formatPrice(_finalAmount.toInt()),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade800,
                ),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _processOrder();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('Đặt hàng'),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  // HÀM CẬP NHẬT SỐ LƯỢNG VÀ SOLD (PHIÊN BẢN ĐÃ SỬA)
  Future<void> _updateProductQuantitiesAndSold() async {
    try {
      print('🔄 Bắt đầu cập nhật số lượng và sold...');

      for (var item in widget.selectedItems) {
        await _updateItemQuantityAndSold(item);
      }

      print('🎯 Hoàn thành cập nhật số lượng và sold cho tất cả sản phẩm');
    } catch (e) {
      print('❌ Lỗi khi cập nhật số lượng sản phẩm: $e');
      throw e;
    }
  }

  // HÀM CẬP NHẬT CHO TỪNG SẢN PHẨM (PHIÊN BẢN ĐÃ SỬA)
  Future<void> _updateItemQuantityAndSold(CartItem item) async {
    try {
      final shopProductId = item.productId;

      // KIỂM TRA SHOP_PRODUCT CÓ TỒN TẠI KHÔNG
      final shopProductRef = FirebaseFirestore.instance
          .collection('shop_products')
          .doc(shopProductId);

      final shopProductDoc = await shopProductRef.get();

      if (!shopProductDoc.exists) {
        throw Exception('Shop product $shopProductId không tồn tại');
      }

      await _updateSizeQuantity(
        shopProductId,
        item.variantId!,
        item.sizeId,
        item.quantity,
      );

      // Bước 2: Cập nhật sold trong shop_product
      await _updateShopProductSold(shopProductId, item.quantity);

      print('✅ Đã cập nhật thành công cho sản phẩm: ${item.productName}');
    } catch (e) {
      print('❌ Lỗi khi cập nhật item ${item.productId}: $e');
      throw e;
    }
  }

  // HÀM KIỂM TRA VÀ GIỮ HÀNG TẠM THỜI
  Future<bool> _reserveInventory(
    String shopProductId,
    String variantId,
    String sizeId,
    int quantity,
    String orderId,
  ) async {
    try {
      final sizeRef = FirebaseFirestore.instance
          .collection('shop_products')
          .doc(shopProductId)
          .collection('shop_product_variants')
          .doc(variantId)
          .collection('product_sizes')
          .doc(sizeId);

      final result = await FirebaseFirestore.instance.runTransaction((
        transaction,
      ) async {
        final snapshot = await transaction.get(sizeRef);

        if (!snapshot.exists) {
          throw Exception('Không tìm thấy sản phẩm');
        }

        final sizeData = snapshot.data() as Map<String, dynamic>;
        final currentQuantity = sizeData['quantity'] ?? 0;
        final reservedQuantity = sizeData['reserved'] ?? 0;
        final availableQuantity = currentQuantity - reservedQuantity;

        print(
          '📊 Tồn kho: $currentQuantity, Đã giữ: $reservedQuantity, Có sẵn: $availableQuantity',
        );

        if (availableQuantity < quantity) {
          throw Exception(
            'Số lượng sản phẩm không đủ. Hiện có sẵn: $availableQuantity, bạn cần: $quantity',
          );
        }

        // TĂNG SỐ LƯỢNG ĐÃ GIỮ
        final newReserved = reservedQuantity + quantity;
        transaction.update(sizeRef, {
          'reserved': newReserved,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      return result;
    } catch (e) {
      print('❌ Lỗi khi giữ hàng: $e');
      return false;
    }
  }

  // HÀM XÁC NHẬN ĐÃ BÁN (TRỪ SỐ LƯỢNG THẬT)
  Future<void> _confirmSale(
    String shopProductId,
    String variantId,
    String sizeId,
    int quantity,
  ) async {
    try {
      final sizeRef = FirebaseFirestore.instance
          .collection('shop_products')
          .doc(shopProductId)
          .collection('shop_product_variants')
          .doc(variantId)
          .collection('product_sizes')
          .doc(sizeId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(sizeRef);

        if (!snapshot.exists) {
          throw Exception('Không tìm thấy sản phẩm');
        }

        final sizeData = snapshot.data() as Map<String, dynamic>;
        final currentQuantity = sizeData['quantity'] ?? 0;
        final reservedQuantity = sizeData['reserved'] ?? 0;

        // TRỪ SỐ LƯỢNG THẬT VÀ GIẢM SỐ LƯỢNG ĐÃ GIỮ
        final newQuantity = currentQuantity - quantity;
        final newReserved = reservedQuantity - quantity;

        transaction.update(sizeRef, {
          'quantity': newQuantity,
          'reserved': newReserved,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print(
          '✅ Đã xác nhận bán: quantity $currentQuantity -> $newQuantity, reserved $reservedQuantity -> $newReserved',
        );
      });
    } catch (e) {
      print('❌ Lỗi khi xác nhận bán: $e');
      throw e;
    }
  }

  // HÀM HỦY GIỮ HÀNG
  Future<void> _cancelReservation(
    String shopProductId,
    String variantId,
    String sizeId,
    int quantity,
  ) async {
    try {
      final sizeRef = FirebaseFirestore.instance
          .collection('shop_products')
          .doc(shopProductId)
          .collection('shop_product_variants')
          .doc(variantId)
          .collection('product_sizes')
          .doc(sizeId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(sizeRef);

        if (snapshot.exists) {
          final sizeData = snapshot.data() as Map<String, dynamic>;
          final reservedQuantity = sizeData['reserved'] ?? 0;
          final newReserved = max(0, reservedQuantity - quantity);

          transaction.update(sizeRef, {
            'reserved': newReserved,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          print(
            '✅ Đã hủy giữ hàng: reserved $reservedQuantity -> $newReserved',
          );
        }
      });
    } catch (e) {
      print('❌ Lỗi khi hủy giữ hàng: $e');
    }
  }

  // HÀM CẬP NHẬT SỐ LƯỢNG TRONG PRODUCT_SIZES (GIỮ NGUYÊN)
  Future<void> _updateSizeQuantity(
    String shopProductId,
    String variantId,
    String sizeId,
    int quantity,
  ) async {
    try {
      final sizeRef = FirebaseFirestore.instance
          .collection('shop_products')
          .doc(shopProductId)
          .collection('shop_product_variants')
          .doc(variantId)
          .collection('product_sizes')
          .doc(sizeId);

      print(
        '📍 Đường dẫn size: shop_products/$shopProductId/shop_product_variants/$variantId/product_sizes/$sizeId',
      );

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(sizeRef);

        if (!snapshot.exists) {
          throw Exception('Không tìm thấy size document');
        }

        final sizeData = snapshot.data() as Map<String, dynamic>;
        final currentQuantity = sizeData['quantity'] ?? 0;

        print('📊 Số lượng hiện tại: $currentQuantity, cần trừ: $quantity');

        // KIỂM TRA NGHIÊM NGẶT SỐ LƯỢNG
        if (currentQuantity < quantity) {
          throw Exception(
            'Số lượng sản phẩm không đủ. Hiện còn: $currentQuantity, bạn cần: $quantity. '
            'Vui lòng chọn số lượng ít hơn hoặc sản phẩm khác.',
          );
        }

        final newQuantity = currentQuantity - quantity;
        transaction.update(sizeRef, {'quantity': newQuantity});

        print('✅ Đã cập nhật size: $currentQuantity -> $newQuantity');
      });
    } catch (e) {
      print('❌ Lỗi khi cập nhật size: $e');
      throw e;
    }
  }

  // HÀM CẬP NHẬT SOLD TRONG SHOP_PRODUCT (GIỮ NGUYÊN)
  Future<void> _updateShopProductSold(
    String shopProductId,
    int quantity,
  ) async {
    try {
      final shopProductRef = FirebaseFirestore.instance
          .collection('shop_products')
          .doc(shopProductId);

      print('📍 Đường dẫn shop_product: shop_products/$shopProductId');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(shopProductRef);

        if (!snapshot.exists) {
          throw Exception('Không tìm thấy shop_product: $shopProductId');
        }

        final shopProductData = snapshot.data() as Map<String, dynamic>;
        final currentSold = shopProductData['sold'] ?? 0;
        final currentTotalQuantity = shopProductData['totalQuantity'] ?? 0;

        final newSold = currentSold + quantity;
        final newTotalQuantity = currentTotalQuantity - quantity;

        transaction.update(shopProductRef, {
          'sold': newSold,
          'totalQuantity': newTotalQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('✅ Đã cập nhật:');
        print('   - sold: $currentSold -> $newSold');
        print('   - totalQuantity: $currentTotalQuantity -> $newTotalQuantity');
      });
    } catch (e) {
      print('❌ Lỗi khi cập nhật sold và totalQuantity: $e');
      throw e;
    }
  }

  // Trong CheckoutScreen
  Future<void> _processOrder() async {
    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Tạo request ID
      final requestId =
          'REQ_${DateTime.now().millisecondsSinceEpoch}_${widget.userId.substring(0, 6)}';

      // Tạo Order Request
      final orderRequest = OrderRequest(
        requestId: requestId,
        userId: widget.userId,
        items: widget.selectedItems,
        address: selectedAddress!,
        paymentMethodId: _selectedPaymentMethodId,
        voucherCode: _selectedVoucher,
        totalAmount: _totalAmount,
        discountAmount: _discountAmount,
        finalAmount: _finalAmount,
        createdAt: DateTime.now(),
      );

      // LƯU ORDER REQUEST
      final success = await _orderRequestRepo.createOrderRequest(orderRequest);

      if (success) {
        // GỬI THÔNG BÁO YÊU CẦU XÁC NHẬN
        await _sendOrderConfirmationNotification(requestId);

        if (_selectedVoucher != null) {
          await _updateVoucherQuantity();
        }

        if (mounted) {
          // Điều hướng đến màn hình chờ xác nhận
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OrderPendingConfirmationScreen(
                    requestId: requestId,
                    totalAmount: _finalAmount.toInt(),
                    itemCount: widget.selectedItems.length,
                    userId: widget.userId,
                  ),
            ),
            (route) => false,
          );
        }
      } else {
        throw Exception('Không thể gửi yêu cầu đặt hàng');
      }
    } catch (e) {
      print('❌ Lỗi khi gửi yêu cầu đặt hàng: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gửi yêu cầu thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  // HÀM GỬI THÔNG BÁO YÊU CẦU XÁC NHẬN
  Future<void> _sendOrderConfirmationNotification(String requestId) async {
    try {
      final notificationId =
          'NOTI_${DateTime.now().millisecondsSinceEpoch}_${widget.userId}';

      final notification = AppNotification(
        id: notificationId,
        userId: widget.userId,
        title: 'Xác nhận đơn hàng 📦',
        message:
            'Bạn có 1 đơn hàng đang chờ xác nhận. '
            'Tổng tiền: ${_formatPrice(_finalAmount.toInt())}. '
            'Vui lòng xác nhận để hoàn tất đặt hàng.',
        type: 'order_confirmation',
        data: {
          'requestId': requestId,
          'totalAmount': _finalAmount,
          'itemCount': widget.selectedItems.length,
          'requiresAction': true, // Yêu cầu hành động
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        createdAt: DateTime.now(),
      );

      final success = await _notificationRepo.sendNotification(notification);

      if (success) {
        print('✅ Đã gửi thông báo yêu cầu xác nhận');
      } else {
        print('⚠️ Không thể gửi thông báo');
      }
    } catch (e) {
      print('❌ Lỗi gửi thông báo: $e');
    }
  }

  // Hàm xóa sản phẩm khỏi giỏ hàng (chỉ dùng khi isFromCart = true)
  Future<void> _removeOrderedItemsFromCart() async {
    try {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('cart');

      // Xóa từng sản phẩm đã đặt hàng khỏi giỏ hàng
      for (var item in widget.selectedItems) {
        // CHỈ XÓA NẾU CÓ cartItemId (sản phẩm thực sự có trong giỏ hàng)
        if (item.cartItemId.isNotEmpty) {
          await cartRef.doc(item.cartItemId).delete();
        } else {}
      }
    } catch (e) {}
  }

  // ---------------- VOUCHER SECTION ----------------
  Widget _buildVoucherSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // NÚT MỞ/RÚT GỌN MÃ GIẢM GIÁ
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: const Icon(
              Icons.local_offer_outlined,
              color: Colors.orange,
              size: 22,
            ),
            title: const Text(
              'Mã giảm giá',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedVoucher != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      _getVoucherPercentageDisplay(_selectedVoucher!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  _isVoucherExpanded ? Icons.expand_more : Icons.expand_less,
                  color: Colors.grey,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _isVoucherExpanded = !_isVoucherExpanded;
              });
            },
          ),

          // DANH SÁCH MÃ GIẢM GIÁ (HIỆN/KẾT)
          if (_isVoucherExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child:
                  _vouchers.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Không có mã giảm giá khả dụng',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : Column(
                        children: [
                          ..._displayedVouchers
                              .map((voucher) => _buildVoucherItem(voucher))
                              .toList(),

                          // NÚT XEM THÊM (chỉ hiện khi còn voucher chưa hiển thị)
                          if (_vouchers.length > _voucherDisplayLimit)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 8),
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _voucherDisplayLimit = _vouchers.length;
                                    _updateDisplayedVouchers();
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text('Xem thêm mã giảm giá'),
                              ),
                            ),
                        ],
                      ),
            ),
        ],
      ),
    );
  }

  // ---------------- VOUCHER ITEM ----------------
  Widget _buildVoucherItem(Map<String, dynamic> voucher) {
    bool isSelected = _selectedVoucher == voucher['code'];
    bool isAvailable =
        (voucher['usedCount'] as int) < (voucher['quantity'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              isSelected
                  ? Colors.orange
                  : isAvailable
                  ? Colors.grey.shade300
                  : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color:
            isSelected
                ? Colors.orange.shade50
                : isAvailable
                ? Colors.white
                : Colors.grey.shade100,
      ),
      child: Row(
        children: [
          // BIỂU TƯỢNG PHẦN TRĂM
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.orange
                      : isAvailable
                      ? Colors.orange.shade100
                      : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.percent,
              color:
                  isSelected
                      ? Colors.white
                      : isAvailable
                      ? Colors.orange
                      : Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // THÔNG TIN MÃ GIẢM GIÁ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher['discount'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color:
                        isSelected
                            ? Colors.orange
                            : isAvailable
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
                Text(
                  voucher['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isAvailable ? Colors.grey.shade600 : Colors.grey,
                  ),
                ),
                Text(
                  'HSD: ${_formatDate(voucher['endDate'])}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isAvailable ? Colors.blue : Colors.grey,
                  ),
                ),
                if (!isAvailable)
                  const Text(
                    'Đã hết lượt sử dụng',
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
              ],
            ),
          ),

          // NÚT ÁP DỤNG/HỦY
          if (isAvailable)
            isSelected
                ? OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedVoucher = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Hủy'),
                )
                : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedVoucher = voucher['code'];
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Áp dụng'),
                )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Hết lượt',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ---------------- FORMAT TIỀN ----------------
  String _formatPrice(dynamic price) {
    // Chuyển đổi thành số nguyên để format
    int priceInt;
    if (price is double) {
      priceInt = price.round();
    } else if (price is int) {
      priceInt = price;
    } else {
      priceInt = 0;
    }

    String priceStr = priceInt.toString();
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

  // HÀM HIỂN THỊ PHẦN TRĂM GIẢM GIÁ
  String _getVoucherPercentageDisplay(String voucherCode) {
    try {
      final voucher = _vouchers.firstWhere((v) => v['code'] == voucherCode);
      final percentage = voucher['percentage'] ?? 0;
      return '${percentage.toStringAsFixed(0)}%';
    } catch (e) {
      return '0%';
    }
  }

  Widget _buildPaymentMethod() {
    if (_isLoadingPaymentMethods) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_paymentMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: Text('Không có phương thức thanh toán nào')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.payment, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Phương thức thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Danh sách phương thức thanh toán TỪ FIREBASE
          Column(
            children:
                _paymentMethods.map((method) {
                  return Column(
                    children: [
                      _buildPaymentOption(
                        method: method,
                        isSelected: _selectedPaymentMethodId == method.id,
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethodId = method.id;
                          });
                        },
                      ),
                      if (method != _paymentMethods.last)
                        const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget con cho mỗi phương thức thanh toán
  Widget _buildPaymentOption({
    required PaymentMethod method,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(method.icon),
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue.shade800 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Hiển thị phí nếu có
            if (method.fee > 0)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  'Phí: ${method.fee}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  // Hàm chuyển icon string thành IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_shipping':
        return Icons.local_shipping;
      case 'wallet':
        return Icons.wallet;
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'credit_score':
        return Icons.credit_score;
      default:
        return Icons.payment;
    }
  }

  // Thêm hàm này vào CheckoutScreen
  Future<void> _updateVoucherQuantity() async {
    if (_selectedVoucher == null) return;

    try {
      final selectedVoucher = _vouchers.firstWhere(
        (v) => v['code'] == _selectedVoucher,
      );

      final voucherId = selectedVoucher['id'];
      final voucherRef = FirebaseFirestore.instance
          .collection('discounts')
          .doc(voucherId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(voucherRef);

        if (!snapshot.exists) {
          print(" Voucher không tồn tại");
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final total = data['so_luong'] ?? 0;
        final used = data['da_su_dung'] ?? 0;

        // Kiểm tra hết lượt sử dụng
        if (used >= total) {
          print("Voucher đã hết lượt sử dụng");
          return;
        }

        // Cập nhật newUsed = used + 1
        final newUsed = used + 1;

        transaction.update(voucherRef, {'da_su_dung': newUsed});

        print("✅ Transaction: Đã +1 da_su_dung cho voucher $voucherId");
      });
    } catch (e) {
      print("❌ Lỗi transaction voucher: $e");
    }
  }
}
