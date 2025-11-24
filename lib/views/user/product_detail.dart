import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/cart_model.dart';
import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/models/order_model.dart';
import 'package:fashion_app/viewmodels/cart_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ShopProductWithDetail product;
  final String? idUser;

  const ProductDetailScreen({super.key, required this.product, this.idUser});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImage = 0;
  late PageController _pageController;
  Timer? _timer;
  ValueNotifier<int> cartItemCount = ValueNotifier<int>(0);
  int selectedColorIndex = 0;
  String selectedSize = "";

  final Map<String, String> _colorNameCache = {};
  Map<String, List<Map<String, dynamic>>> _variantSizes = {};
  List<Map<String, dynamic>> sizes = [];
  bool _isLoadingSizes = true;
  Map<String, String> _sizeNameCache = {};
  // Thêm vào state
  String? _brandName;
  String? _shopAddress;
  bool _isLoadingAdditionalInfo = true;

  // Hàm load brand và shop address
  Future<void> _loadAdditionalInfo() async {
    try {
      // Load brand name từ brandID
      if (widget.product.productDetail.brandID != null) {
        final brandDoc =
            await FirebaseFirestore.instance
                .collection('brands')
                .doc(widget.product.productDetail.brandID)
                .get();

        if (brandDoc.exists) {
          _brandName = brandDoc.data()?['name'] as String?;
        }
      }

      // Load shop address từ shopID
      if (widget.product.shopProduct.shopId != null) {
        final shopDoc =
            await FirebaseFirestore.instance
                .collection('shops')
                .doc(widget.product.shopProduct.shopId)
                .get();

        if (shopDoc.exists) {
          _shopAddress = shopDoc.data()?['address'] as String?;
        }
      }
    } catch (e) {
      print("❌ Lỗi load additional info: $e");
    } finally {
      setState(() {
        _isLoadingAdditionalInfo = false;
      });
    }
  }

  void _listenSizesByVariant(String variantID) {
    final productID = widget.product.shopProduct.shopproductID;

    FirebaseFirestore.instance
        .collection('shop_products')
        .doc(productID)
        .collection('shop_product_variants')
        .doc(variantID)
        .collection('product_sizes')
        .snapshots()
        .listen((snapshot) {
          final loadedSizes =
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'sizeID': doc.id,
                  'name': _sizeNameCache[doc.id] ?? 'Unknown',
                  'quantity': data['quantity'] ?? 0,
                  'price': (data['price'] as num?)?.toDouble() ?? 0,
                };
              }).toList();

          setState(() {
            if (_selectedVariantID == variantID) {
              sizes = loadedSizes;
            }
            _isLoadingSizes = false;
          });
        });
  }

  Future<void> _loadAllSizes() async {
    final snapshot = await FirebaseFirestore.instance.collection('sizes').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final name = data['name'] as String? ?? 'Unknown';
      _sizeNameCache[doc.id] = name;
    }
  }

  // Giữ nguyên danh sách ảnh từ tất cả variants (không thay đổi theo màu)
  List<String> get productImages {
    return widget.product.variants
        .map((variant) => variant.imageUrls)
        .where((imageUrl) => imageUrl.isNotEmpty)
        .toList();
  }

  String get _selectedColorID {
    return widget.product.variants[selectedColorIndex].colorID;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadAllSizes().then((_) {
      //_loadProductSizes();
      _listenSizesByVariant(_selectedVariantID);
    });
    _loadAdditionalInfo();
    // Giữ nguyên timer lướt ảnh
    if (productImages.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController.hasClients) {
          int nextPage = _currentImage + 1;
          if (nextPage >= productImages.length) {
            nextPage = 0;
          }
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  String get _selectedVariantID {
    return widget.product.variants[selectedColorIndex].shopProductVariantID;
  }

  // Hàm xử lý khi chọn màu
  void _onColorSelected(int index) {
    if (index == selectedColorIndex) return;

    setState(() {
      selectedColorIndex = index;
      selectedSize = "";
      sizes.clear();
      _isLoadingSizes = true;
      _quantity = 1;
    });

    _listenSizesByVariant(widget.product.variants[index].shopProductVariantID);
  }

  Future<void> _loadSizesByVariant(String variantID) async {
    try {
      final productID = widget.product.shopProduct.shopproductID;

      final snapshot =
          await FirebaseFirestore.instance
              .collection('shop_products')
              .doc(productID)
              .collection('shop_product_variants')
              .doc(variantID)
              .collection('product_sizes')
              .get();

      final loadedSizes =
          snapshot.docs.map((doc) {
            final data = doc.data();
            final sizeID = doc.id;
            final quantity = data['quantity'] as int? ?? 0;

            final price = data['price'];
            double priceValue = 0.0;
            if (price != null) {
              if (price is int) {
                priceValue = price.toDouble();
              } else if (price is double) {
                priceValue = price;
              } else if (price is num) {
                priceValue = price.toDouble();
              }
            }

            final name = _sizeNameCache[sizeID] ?? 'Unknown';
            return {
              'sizeID': sizeID,
              'name': name,
              'quantity': quantity,
              'price': priceValue,
            };
          }).toList();

      setState(() {
        sizes = loadedSizes;
        _isLoadingSizes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSizes = false;
        sizes = [];
      });
    }
  }

  Future<void> _loadProductSizes() async {
    try {
      setState(() {
        _isLoadingSizes = true;
        sizes.clear();
        selectedSize = "";
      });

      final productID = widget.product.shopProduct.shopproductID;
      final variantID = _selectedVariantID;

      final snapshot =
          await FirebaseFirestore.instance
              .collection('shop_products')
              .doc(productID)
              .collection('shop_product_variants')
              .doc(variantID)
              .collection('product_sizes')
              .get();

      final loaded =
          snapshot.docs.map((doc) {
            final d = doc.data();
            final sizeID = doc.id;
            final quantity = d['quantity'] as int? ?? 0;

            // SỬA TƯƠNG TỰ Ở ĐÂY
            final price = d['price'];
            double priceValue = 0.0;
            if (price != null) {
              if (price is int) {
                priceValue = price.toDouble();
              } else if (price is double) {
                priceValue = price;
              } else if (price is num) {
                priceValue = price.toDouble();
              }
            }

            final name = _sizeNameCache[sizeID] ?? 'Unknown';
            return {
              'sizeID': sizeID,
              'name': name,
              'quantity': quantity,
              'price': priceValue, // ← DÙNG DOUBLE
            };
          }).toList();

      setState(() {
        sizes = loaded;
        _isLoadingSizes = false;
      });
    } catch (e) {
      print("❌ Lỗi load init sizes: $e");
      setState(() => _isLoadingSizes = false);
    }
  }

  String _getColorName(String colorID) {
    if (_colorNameCache.containsKey(colorID)) {
      return _colorNameCache[colorID]!;
    }

    final colorName = "Màu ${colorID.split('_').last}";
    _colorNameCache[colorID] = colorName;
    return colorName;
  }

  String _getSizeName(String sizeID) {
    if (_sizeNameCache.containsKey(sizeID)) {
      return _sizeNameCache[sizeID]!;
    }

    final size = sizes.firstWhere(
      (size) => size['sizeID'] == sizeID,
      orElse: () => {'name': sizeID},
    );

    final sizeName = size['name'] as String? ?? sizeID;

    _sizeNameCache[sizeID] = sizeName;
    return sizeName;
  }

  int _getSizeQuantity(String sizeID) {
    if (sizeID.isEmpty) return 0;

    try {
      final size = sizes.firstWhere((size) => size['sizeID'] == sizeID);
      return size['quantity'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  double _getSizePrice(String sizeID) {
    if (sizeID.isEmpty) return 0;

    try {
      final size = sizes.firstWhere((s) => s['sizeID'] == sizeID);
      final price = size['price'];

      if (price == null) return 0;

      return (price as num).toDouble();
    } catch (e) {
      return 0;
    }
  }

  double _getMinPrice() {
    if (sizes.isEmpty) return 0;

    try {
      final prices =
          sizes
              .map((s) {
                final price = s['price'];
                if (price == null) return 0.0;
                return (price as num).toDouble();
              })
              .where((price) => price > 0)
              .toList();

      if (prices.isEmpty) return 0;

      prices.sort();
      return prices.first;
    } catch (e) {
      return 0;
    }
  }

  bool _isSizeAvailable(String sizeID) {
    return true;
  }

  Stream<int> get cartItemCountStream {
    if (widget.idUser == null) {
      return Stream.value(0);
    }

    return FirebaseFirestore.instance
        .collection('carts')
        .doc(widget.idUser)
        .collection('cart_items')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
  // Thêm vào _ProductDetailScreenState class

  Future<void> _createSampleOrder() async {
    try {
      // Kiểm tra user đã đăng nhập chưa
      if (widget.idUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để mua hàng'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Tạo order ID
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
      final product = widget.product;
      final variant = product.variants[selectedColorIndex];

      // Tạo order document
      final orderData = {
        'orderId': orderId,
        'userId': widget.idUser!,
        'customerPhone': '0123456789', // Số điện thoại mẫu
        'customerAddress': '123 Đường ABC, Quận 1, TP.HCM', // Địa chỉ mẫu
        'itemsTotal': _getSizePrice(selectedSize) * _quantity,
        'shippingFee': 30000.0, // Phí ship mẫu
        'discount': 0.0,
        'finalTotal': (_getSizePrice(selectedSize) * _quantity) + 30000.0,
        'paymentMethodId': 'payment_cod', // COD mẫu
        'orderStatus': 'pending',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      // Tạo order item
      final orderItem = {
        'orderItemId': '${orderId}_ITEM_1',
        'productId': product.shopProduct.shopproductID,
        'productName': product.productDetail.name ?? 'Không tên',
        'variantId': variant.shopProductVariantID,
        'shopId': product.shopProduct.shopId ?? '',
        'colorId': variant.colorID,
        'sizeId': selectedSize,
        'price': _getSizePrice(selectedSize),
        'quantity': _quantity,
        'totalPrice': _getSizePrice(selectedSize) * _quantity,
        'itemStatus': 'pending',
        'voucherId': '',
        'imageUrl': variant.imageUrls.isNotEmpty ? variant.imageUrls : '',
        'createdAt': Timestamp.now(),
      };

      // Lưu lên Firebase với nested structure
      await _saveOrderToFirebaseNested(orderId, orderData, orderItem);

      final colorName = _getColorName(_selectedColorID);
      final sizeName = _getSizeName(selectedSize);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Đã tạo đơn hàng #$orderId thành công - $_quantity sản phẩm ($colorName - $sizeName)',
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'XEM ĐƠN HÀNG',
            onPressed: () {
              // TODO: Điều hướng đến trang đơn hàng
            },
          ),
        ),
      );
    } catch (e) {
      print('❌ Lỗi tạo đơn hàng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi tạo đơn hàng: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveOrderToFirebaseNested(
    String orderId,
    Map<String, dynamic> orderData,
    Map<String, dynamic> orderItem,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    // 1. Tạo user document trong orders collection (nếu chưa có)
    final userOrderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.idUser);

    // 2. Tạo subcollection user_orders và order document
    final orderRef = userOrderRef.collection('user_orders').doc(orderId);

    batch.set(orderRef, orderData);

    // 3. Tạo subcollection order_items trong order document
    final orderItemRef = orderRef
        .collection('order_items')
        .doc(orderItem['orderItemId']);

    batch.set(orderItemRef, orderItem);

    // 4. Xóa sản phẩm khỏi giỏ hàng (nếu có)
    final cartItemId =
        '${widget.product.shopProduct.shopproductID}_${_selectedColorID}_$selectedSize';
    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(widget.idUser)
        .collection('cart_items')
        .doc(cartItemId);

    batch.delete(cartRef);

    await batch.commit();

    print('✅ Đã tạo đơn hàng nested: $orderId');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    cartItemCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int maxQuantity = _getSizeQuantity(selectedSize);
    final cartViewModel = Provider.of<CartViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        backgroundColor: const Color.fromARGB(255, 172, 199, 247),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Icon giỏ hàng với StreamBuilder
          StreamBuilder<int>(
            stream: cartItemCountStream,
            builder: (context, snapshot) {
              final itemCount = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () {
                      // TODO: Điều hướng đến màn hình giỏ hàng
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          itemCount > 99 ? '99+' : '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === ẢNH SẢN PHẨM (GIỮ NGUYÊN) ===
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: productImages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[300],
                            ),
                            child: Image.network(
                              productImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error,
                                        size: 50,
                                        color: Colors.red,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Lỗi tải ảnh',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (productImages.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          productImages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImage == index ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  _currentImage == index
                                      ? Colors.blueAccent
                                      : Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // === TÊN & GIÁ ===
              Text(
                widget.product.productDetail.name ?? "Không có tên",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "Giá: ",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  Text(
                    "${selectedSize.isEmpty ? _getMinPrice() : _getSizePrice(selectedSize)} đ",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Đã bán: ${widget.product.shopProduct.sold ?? 9}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),

              // === ĐÁNH GIÁ ===
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.product.shopProduct.rating ?? 0}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${widget.product.shopProduct.sold ?? 0} đánh giá)",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // === MÀU SẮC ===
              const Text(
                "Màu sắc",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(widget.product.variants.length, (
                  index,
                ) {
                  final variant = widget.product.variants[index];
                  final isSelected = index == selectedColorIndex;

                  return GestureDetector(
                    onTap: () => _onColorSelected(index),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.blueAccent
                                  : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // ẢNH THEO MÀU
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child:
                                  variant.imageUrls.isNotEmpty
                                      ? Image.network(
                                        variant.imageUrls,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors.grey[300],
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.error,
                                                  color: Colors.grey[600],
                                                  size: 20,
                                                ),
                                                Text(
                                                  "Màu ${index + 1}",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                      : Container(
                                        color: Colors.grey[300],
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.photo,
                                          color: Colors.grey[500],
                                          size: 20,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // TÊN MÀU
                          Text(
                            _getColorName(variant.colorID),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  isSelected
                                      ? Colors.blueAccent
                                      : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // === SIZE ===
              const Text(
                "Kích thước",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _isLoadingSizes
                  ? const Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 10),
                      Text('Đang tải sizes...'),
                    ],
                  )
                  : sizes.isEmpty
                  ? const Text('Không có size nào cho màu này')
                  : Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children:
                        sizes.map((size) {
                          final sizeID = size['sizeID'] as String;
                          final sizeName = size['name'] as String;
                          final quantity = size['quantity'] as int;
                          final isSelected = sizeID == selectedSize;

                          return GestureDetector(
                            onTap:
                                quantity > 0
                                    ? () => setState(() {
                                      selectedSize = sizeID;
                                      _quantity = 1;
                                    })
                                    : null, // Ngăn chọn nếu hết hàng
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    quantity > 0
                                        ? (isSelected
                                            ? Colors.blueAccent
                                            : const Color(0xFFD9D9D9))
                                        : Colors
                                            .grey
                                            .shade400, // màu xám khi hết hàng
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    sizeName,
                                    style: TextStyle(
                                      color:
                                          quantity > 0
                                              ? (isSelected
                                                  ? Colors.white
                                                  : Colors.black)
                                              : Colors.white70,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  quantity > 0
                                      ? const SizedBox()
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
              const SizedBox(height: 20),

              // === SỐ LƯỢNG ===
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Số lượng:", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),

                  // Nút giảm
                  GestureDetector(
                    onTap:
                        _quantity > 0
                            ? () => setState(() => _quantity--)
                            : null,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          _quantity > 1
                              ? const Color.fromARGB(255, 245, 131, 131)
                              : Colors.grey[300],
                      child: Icon(
                        Icons.remove,
                        color: _quantity > 1 ? Colors.white : Colors.grey[500],
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 45,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: TextEditingController(text: '$_quantity')
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: '$_quantity'.length),
                        ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),

                      onChanged: (value) {
                        int? num = int.tryParse(value);

                        if (num == null || num <= 0) {
                          setState(() => _quantity = 1);
                          return;
                        }

                        if (num > maxQuantity) {
                          setState(() => _quantity = maxQuantity);
                          return;
                        }

                        setState(() => _quantity = num);
                      },
                    ),
                  ),

                  const SizedBox(width: 10),
                  // Nút tăng
                  GestureDetector(
                    onTap: () {
                      if (selectedSize.isNotEmpty && _quantity < maxQuantity) {
                        setState(() => _quantity++);
                      }
                    },
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          selectedSize.isEmpty
                              ? Colors.grey[300]
                              : (_quantity < maxQuantity
                                  ? const Color.fromARGB(255, 118, 200, 238)
                                  : Colors.grey[300]),
                      child: Icon(
                        Icons.add,
                        color:
                            selectedSize.isEmpty
                                ? Colors.grey[500]
                                : (_quantity < maxQuantity
                                    ? Colors.white
                                    : Colors.grey[500]),
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  Text(
                    "Còn $maxQuantity sản phẩm",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // === MÔ TẢ ===
              ExpansionTile(
                title: const Text(
                  "Thông số & mô tả",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.product.shopProduct.description != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Chi tiết sản phẩm:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.product.shopProduct.description!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        const Text("📦 Kho: Còn hàng"),
                        const SizedBox(height: 8),

                        // HIỂN THỊ THƯƠNG HIỆU
                        if (_isLoadingAdditionalInfo)
                          const Text("📦 Thương hiệu: Đang tải...")
                        else if (_brandName != null)
                          Text("📦 Thương hiệu: $_brandName"),

                        const SizedBox(height: 8),

                        // HIỂN THỊ ĐỊA CHỈ SHOP
                        if (_isLoadingAdditionalInfo)
                          const Text("📦 Địa chỉ shop: Đang tải...")
                        else if (_shopAddress != null)
                          Text("📦 Địa chỉ shop: $_shopAddress"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // === NÚT HÀNH ĐỘNG ===
              Row(
                children: [
                  // NÚT THÊM GIỎ - BỊ THIẾU
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            selectedSize.isNotEmpty
                                ? () async {
                                  // LẤY CartViewModel từ Provider
                                  final cartVM = Provider.of<CartViewModel>(
                                    context,
                                    listen: false,
                                  );

                                  // Kiểm tra user đã đăng nhập chưa
                                  if (widget.idUser == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Vui lòng đăng nhập để thêm vào giỏ hàng',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  final colorName = _getColorName(
                                    _selectedColorID,
                                  );
                                  final sizeName = _getSizeName(selectedSize);

                                  final cartItem = CartItem(
                                    cartItemId:
                                        '${widget.product.shopProduct.shopproductID}_${_selectedColorID}_$selectedSize',
                                    userId: widget.idUser!,
                                    productId:
                                        widget
                                            .product
                                            .shopProduct
                                            .shopproductID,
                                    productName:
                                        widget.product.productDetail.name ??
                                        'Không tên',
                                    variantId: _selectedVariantID,
                                    shopId:
                                        widget.product.shopProduct.shopId ?? '',
                                    colorId: _selectedColorID,
                                    sizeId: selectedSize,
                                    quantity: _quantity,
                                    price: _getSizePrice(selectedSize),
                                    imageUrl:
                                        widget
                                                .product
                                                .variants[selectedColorIndex]
                                                .imageUrls
                                                .isNotEmpty
                                            ? widget
                                                .product
                                                .variants[selectedColorIndex]
                                                .imageUrls
                                            : '',
                                    addedAt: DateTime.now(),
                                  );

                                  try {
                                    await cartVM.addOrUpdateItem(cartItem);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "✅ Đã thêm $_quantity sản phẩm ($colorName - $sizeName) vào giỏ hàng",
                                        ),
                                        duration: const Duration(seconds: 2),
                                        action: SnackBarAction(
                                          label: 'XEM GIỎ',
                                          onPressed: () {
                                            // TODO: Điều hướng đến giỏ hàng
                                          },
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "❌ Lỗi thêm giỏ hàng: $e",
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedSize.isNotEmpty
                                  ? Colors.green
                                  : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Thêm giỏ",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // NÚT MUA NGAY - ĐÃ CÓ
                  // NÚT MUA NGAY - SỬA LẠI
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            selectedSize.isNotEmpty
                                ? () async {
                                  final colorName = _getColorName(
                                    _selectedColorID,
                                  );
                                  final sizeName = _getSizeName(selectedSize);

                                  // Hiển thị loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('🔄 Đang tạo đơn hàng...'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );

                                  // Tạo đơn hàng
                                  await _createSampleOrder();
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedSize.isNotEmpty
                                  ? Colors.blueAccent
                                  : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Mua ngay",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
