import 'package:fashion_app/views/user/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/cart_model.dart';
import 'package:fashion_app/viewmodels/cart_view_model.dart';

class CartScreen extends StatefulWidget {
  final String userId;

  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isVoucherExpanded = false;
  bool _isAllSelected = false;
  String? _selectedVoucher;
  List<Map<String, dynamic>> _vouchers = [];
  List<Map<String, dynamic>> _displayedVouchers = [];
  Map<String, String> _sizeMap = {};
  Map<String, bool> _selectedItems = {};
  int _voucherDisplayLimit = 2;
  bool _isEditMode = false;
  List<String> _itemsToDelete = [];
  Map<String, String> _shopNames = {};

  @override
  void initState() {
    super.initState();
    _loadVouchersFromFirebase();
    _loadSizesFromFirebase();
    _loadShopNamesFromFirebase();
  }

  // LOAD VOUCHER TỪ FIREBASE
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

  // XÓA CÁC ITEM ĐƯỢC CHỌN
  void _deleteSelectedItems() {
    if (_itemsToDelete.isEmpty) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa sản phẩm'),
            content: Text(
              'Bạn có chắc muốn xóa ${_itemsToDelete.length} sản phẩm khỏi giỏ hàng?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('HỦY'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performDeleteItems();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('XÓA'),
              ),
            ],
          ),
    );
  }

  // THỰC HIỆN XÓA ITEMS
  // THỰC HIỆN XÓA NHIỀU ITEMS
  void _performDeleteItems() {
    final cartVM = Provider.of<CartViewModel>(context, listen: false);

    // Sử dụng hàm removeMultipleFromCart nếu có, hoặc xóa từng item
    for (String cartItemId in _itemsToDelete) {
      cartVM.removeFromCart(cartItemId);
    }

    // Reset trạng thái sau khi xóa
    setState(() {
      _itemsToDelete.clear();
      _isAllSelected = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa ${_itemsToDelete.length} sản phẩm'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // CẬP NHẬT DANH SÁCH VOUCHER HIỂN THỊ
  void _updateDisplayedVouchers() {
    setState(() {
      _displayedVouchers = _vouchers.take(_voucherDisplayLimit).toList();
    });
  }

  // LOAD SIZE TỪ FIREBASE
  Future<void> _loadSizesFromFirebase() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('sizes').get();

      Map<String, String> loadedSizes = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Lấy tên size từ trường 'name' trong document
        loadedSizes[doc.id] = data['name'] ?? doc.id;
      }

      setState(() {
        _sizeMap = loadedSizes;
      });
    } catch (e) {
      print('Lỗi load sizes: $e');
    }
  }

  // ---------------- GET SIZE DISPLAY ----------------
  String _getSizeDisplay(String sizeId) {
    // Lấy tên size từ _sizeMap, nếu không có thì trả về sizeId
    return _sizeMap[sizeId] ?? sizeId;
  }

  // CẬP NHẬT TRẠNG THÁI CHỌN TẤT CẢ
  // CẬP NHẬT TRẠNG THÁI CHỌN TẤT CẢ
  void _updateAllSelected(bool? value, CartViewModel cartVM) {
    setState(() {
      _isAllSelected = value ?? false;
      // Cập nhật tất cả items
      for (var item in cartVM.items) {
        _selectedItems[item.cartItemId] = _isAllSelected;

        // CẬP NHẬT DANH SÁCH XÓA TRONG CHẾ ĐỘ CHỈNH SỬA
        if (_isEditMode) {
          if (_isAllSelected) {
            _itemsToDelete.add(item.cartItemId);
          } else {
            _itemsToDelete.clear();
          }
        }
      }
    });
  }

  // CẬP NHẬT TRẠNG THÁI CHỌN TỪNG ITEM
  void _updateItemSelected(String cartItemId, bool? value) {
    setState(() {
      _selectedItems[cartItemId] = value ?? false;

      // CẬP NHẬT DANH SÁCH XÓA TRONG CHẾ ĐỘ CHỈNH SỬA
      if (_isEditMode) {
        if (value == true) {
          _itemsToDelete.add(cartItemId);
        } else {
          _itemsToDelete.remove(cartItemId);
        }
      }

      // Kiểm tra xem có phải tất cả đều được chọn không
      _isAllSelected = _selectedItems.values.every((isSelected) => isSelected);
    });
  }

  /// Group cart items theo Shop
  Map<String, List<CartItem>> _groupItemsByShop(List<CartItem> items) {
    final Map<String, List<CartItem>> grouped = {};

    for (var item in items) {
      if (!grouped.containsKey(item.shopId)) {
        grouped[item.shopId] = [];
      }
      grouped[item.shopId]!.add(item);
      // Khởi tạo trạng thái selected cho item
      if (!_selectedItems.containsKey(item.cartItemId)) {
        _selectedItems[item.cartItemId] = _isAllSelected;
      }
    }

    return grouped;
  }

  // CHUYỂN ĐỔI CHẾ ĐỘ CHỈNH SỬA
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        // Khi thoát chế độ chỉnh sửa, reset danh sách xóa
        _itemsToDelete.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giỏ Hàng',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _toggleEditMode,
            child: Text(
              _isEditMode ? 'Xong' : 'Sửa',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<CartViewModel>(
        builder: (context, cartVM, child) {
          if (cartVM.items.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [_buildCartItems(cartVM)]),
                ),
              ),
              // THANH MÃ GIẢM GIÁ VÀ THANH TOÁN
              if (!_isEditMode) _buildVoucherAndCheckoutSection(cartVM),
            ],
          );
        },
      ),
      bottomNavigationBar: _isEditMode ? _buildEditBottomBar() : null,
    );
  }

  // BOTTOM BAR CHO CHẾ ĐỘ CHỈNH SỬA
  Widget _buildEditBottomBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        children: [
          // CHECKBOX CHỌN TẤT CẢ
          Consumer<CartViewModel>(
            builder: (context, cartVM, child) {
              return Row(
                children: [
                  Checkbox(
                    value: _isAllSelected,
                    onChanged: (value) {
                      _updateAllSelected(value, cartVM);
                    },
                    activeColor: Colors.orange,
                  ),
                  const Text(
                    "Chọn tất cả",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              );
            },
          ),

          const Spacer(),

          // NÚT XÓA
          ElevatedButton(
            onPressed: _itemsToDelete.isNotEmpty ? _deleteSelectedItems : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _itemsToDelete.isNotEmpty ? Colors.red : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              "Xóa (${_itemsToDelete.length})",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- EMPTY CART ----------------
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ---------------- CART ITEMS (GROUP BY SHOP) ----------------
  Widget _buildCartItems(CartViewModel cartVM) {
    final grouped = _groupItemsByShop(cartVM.items);

    return Column(
      children:
          grouped.entries.map((entry) {
            final shopId = entry.key;
            final items = entry.value;
            final shopName = _getShopName(shopId);

            // Kiểm tra xem tất cả items trong shop có được chọn không
            bool isAllShopItemsSelected = items.every(
              (item) => _selectedItems[item.cartItemId] ?? false,
            );

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(12),
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
                  // ---- Header tên Shop với checkbox ----
                  Row(
                    children: [
                      if (!_isEditMode)
                        Checkbox(
                          value: isAllShopItemsSelected,
                          onChanged: (value) {
                            _updateShopItemsSelected(
                              shopId,
                              value ?? false,
                              items,
                            );
                          },
                          activeColor: Colors.orange,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      if (!_isEditMode) const SizedBox(width: 4),

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
                  const Divider(height: 20),

                  Column(
                    children:
                        items.map((item) {
                          return _buildCartItem(item, cartVM);
                        }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // ---------------- ITEM UI ----------------
  Widget _buildCartItem(CartItem item, CartViewModel cartVM) {
    bool isSelected = _selectedItems[item.cartItemId] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // CHECKBOX CHO SẢN PHẨM - LUÔN HIỆN ĐỂ CHỌN MUA HÀNG
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              _updateItemSelected(item.cartItemId, value);
            },
            activeColor: Colors.orange,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 6),

          // --- Ảnh sản phẩm ---
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey[100],
            ),
            child:
                item.imageUrl.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.shopping_bag,
                            color: Colors.grey[400],
                            size: 24,
                          );
                        },
                      ),
                    )
                    : Icon(
                      Icons.shopping_bag,
                      color: Colors.grey[400],
                      size: 24,
                    ),
          ),
          const SizedBox(width: 10),

          // --- Thông tin sản phẩm ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sản phẩm
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

                // Size
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Kích thước: ${_getSizeDisplay(item.sizeId)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Số lượng: ',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 6),
                    _buildQuantitySelector(item, cartVM),
                  ],
                ),
                const SizedBox(height: 6),
                //Giá
                Row(
                  children: [
                    // Giá
                    Text(
                      'Giá: ',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      _formatPrice(item.price),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- QUANTITY SELECTOR ----------------
  Widget _buildQuantitySelector(CartItem item, CartViewModel cartVM) {
    final TextEditingController _controller = TextEditingController(
      text: item.quantity.toString(),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút giảm
          Container(
            width: 24,
            height: 24,
            child: IconButton(
              onPressed:
                  item.quantity > 1
                      ? () {
                        cartVM.updateQuantity(
                          cartItemId: item.cartItemId,
                          quantity: item.quantity - 1,
                        );
                      }
                      : null,
              icon: Icon(
                Icons.remove,
                size: 12,
                color: item.quantity > 1 ? Colors.black : Colors.grey,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),

          // Ô nhập số lượng
          Container(
            width: 30,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (value) {
                int? newQty = int.tryParse(value);
                if (newQty != null && newQty > 0) {
                  cartVM.updateQuantity(
                    cartItemId: item.cartItemId,
                    quantity: newQty,
                  );
                } else {
                  _controller.text = item.quantity.toString();
                }
              },
            ),
          ),

          // Nút tăng
          Container(
            width: 24,
            height: 24,
            child: IconButton(
              onPressed: () {
                cartVM.updateQuantity(
                  cartItemId: item.cartItemId,
                  quantity: item.quantity + 1,
                );
              },
              icon: const Icon(Icons.add, size: 12),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- CẬP NHẬT TRẠNG THÁI CHỌN CỦA SHOP ----------------
  void _updateShopItemsSelected(
    String shopId,
    bool value,
    List<CartItem> items,
  ) {
    setState(() {
      for (var item in items) {
        _selectedItems[item.cartItemId] = value;
      }
      // Kiểm tra xem có phải tất cả đều được chọn không
      _isAllSelected = _selectedItems.values.every((isSelected) => isSelected);
    });
  }

  // ---------------- VOUCHER AND CHECKOUT SECTION ----------------
  Widget _buildVoucherAndCheckoutSection(CartViewModel cartVM) {
    return Column(
      children: [
        // PHẦN MÃ GIẢM GIÁ
        _buildVoucherSection(),

        // PHẦN THANH TOÁN
        _buildCheckoutButton(cartVM),
      ],
    );
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

  // ---------------- CHECKOUT BUTTON ----------------
  Widget _buildCheckoutButton(CartViewModel cartVM) {
    // Chỉ tính tổng cho các sản phẩm được chọn
    final selectedItems =
        cartVM.items
            .where((item) => _selectedItems[item.cartItemId] ?? false)
            .toList();

    final totalAmount = selectedItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    // Tính discount
    double discountAmount = 0;
    if (_selectedVoucher != null) {
      final selectedVoucher = _vouchers.firstWhere(
        (v) => v['code'] == _selectedVoucher,
        orElse: () => {},
      );
      if (selectedVoucher.isNotEmpty) {
        final percentage = selectedVoucher['percentage'] ?? 0;
        discountAmount = totalAmount * percentage / 100;
      }
    }

    final finalAmount = totalAmount - discountAmount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // CHECKBOX TẤT CẢ
          Row(
            children: [
              Checkbox(
                value: _isAllSelected,
                onChanged: (value) {
                  _updateAllSelected(value, cartVM);
                },
                activeColor: Colors.orange,
              ),
              const Text("Tất cả", style: TextStyle(fontSize: 14)),
            ],
          ),

          const Spacer(),

          // TỔNG TIỀN
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_selectedVoucher != null && discountAmount > 0)
                Text(
                  _formatPrice(totalAmount),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Text(
                _formatPrice(finalAmount),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // NÚT MUA HÀNG
          ElevatedButton(
            onPressed:
                selectedItems.isNotEmpty
                    ? () {
                      _navigateToCheckout(cartVM);
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  selectedItems.isNotEmpty ? Colors.orange : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              "Mua hàng",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // CHUYỂN SANG MÀN HÌNH THANH TOÁN
  void _navigateToCheckout(CartViewModel cartVM) {
    // Lấy danh sách sản phẩm được chọn
    final selectedItems =
        cartVM.items
            .where((item) => _selectedItems[item.cartItemId] ?? false)
            .toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một sản phẩm để mua hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // CHUYỂN SANG MÀN HÌNH THANH TOÁN
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CheckoutScreen(
              userId: widget.userId,
              selectedItems: selectedItems,
              selectedVoucher: _selectedVoucher,
              isFromCart: true,
            ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ---------------- FORMAT TIỀN ----------------
  String _formatPrice(double price) {
    String priceStr = price.toStringAsFixed(0);
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
      final voucher = _vouchers.firstWhere(
        (v) => v['code'] == voucherCode,
        orElse: () => {},
      );
      if (voucher.isNotEmpty) {
        final percentage = voucher['percentage'] ?? 0;
        return '${percentage.toStringAsFixed(0)}%';
      }
      return '0%';
    } catch (e) {
      return '0%';
    }
  }
}
