import 'dart:async';
import 'dart:math' as Math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/views/user/cart_screen.dart';
import 'package:fashion_app/views/user/payment_screen.dart';
import 'package:fashion_app/views/user/widget/product_detail_helper.dart';
import 'package:fashion_app/views/user/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:fashion_app/data/models/cart_model.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:fashion_app/viewmodels/cart_view_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ShopProductWithDetail product;
  final String? idUser;

  const ProductDetailScreen({super.key, required this.product, this.idUser});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  // State
  int _quantity = 0;
  int _currentImage = 0;
  late PageController _pageController;
  Timer? _timer;
  int selectedColorIndex = 0;
  String selectedSize = "";
  final ProductDetailHelper _helper = ProductDetailHelper();

  // Animation
  late AnimationController _cartAnimationController;
  bool _showCartAnimation = false;

  // Global Keys cho animation
  final GlobalKey _addToCartButtonKey = GlobalKey();
  final GlobalKey _cartIconKey = GlobalKey();
  final GlobalKey _imageKey = GlobalKey();

  // Data
  List<Map<String, dynamic>> sizes = [];
  bool _isLoadingSizes = true;
  String? _brandName;
  String? _shopAddress;
  bool _isLoadingAdditionalInfo = true;

  // Getters
  String get _selectedVariantID =>
      widget.product.variants[selectedColorIndex].shopProductVariantID;
  String get _selectedColorID =>
      widget.product.variants[selectedColorIndex].colorID;
  List<String> get productImages =>
      _helper.getProductImages(widget.product.variants);

  // THÊM STATE MỚI CHO REVIEWS
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Khởi tạo animation controller
    _cartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _initializeData();
    _startImageAutoScroll();
    _loadReviews();
  }

  // Method debug

  Future<void> _initializeData() async {
    await _helper.loadAllSizes();
    _loadAdditionalInfo();
    _listenToSizes();
  }

  void _loadAdditionalInfo() async {
    final result = await _helper.loadAdditionalInfo(
      brandID: widget.product.productDetail.brandID,
      shopId: widget.product.shopProduct.shopId,
    );

    setState(() {
      _brandName = result['brandName'];
      _shopAddress = result['shopAddress'];
      _isLoadingAdditionalInfo = result['isLoading'];
    });
  }

  void _listenToSizes() {
    _helper
        .listenSizesByVariant(
          productID: widget.product.shopProduct.shopproductID,
          variantID: _selectedVariantID,
        )
        .listen((loadedSizes) {
          if (mounted) {
            setState(() {
              sizes = loadedSizes;
              _isLoadingSizes = false;
            });
          }
        });
  }

  void _startImageAutoScroll() {
    if (productImages.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController.hasClients) {
          int nextPage = _currentImage + 1;
          if (nextPage >= productImages.length) nextPage = 0;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  // ==================== ANIMATION METHODS ====================

  void _triggerCartAnimation() {
    setState(() {
      _showCartAnimation = true;
    });

    _cartAnimationController.forward().then((_) {
      setState(() {
        _showCartAnimation = false;
      });
      _cartAnimationController.reset();
    });
  }

  void runAddToCartAnimation() {
    final overlay = Overlay.of(context);

    // Lấy vị trí của nút "Thêm giỏ"
    final RenderBox addToCartBox =
        _addToCartButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset startPos = addToCartBox.localToGlobal(Offset.zero);

    // Lấy vị trí của icon giỏ hàng
    final RenderBox cartBox =
        _cartIconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset endPos = cartBox.localToGlobal(Offset.zero);

    // Animation bay cong từ nút thêm giỏ lên icon giỏ hàng
    final entry = OverlayEntry(
      builder: (_) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            // Tính toán vị trí với đường cong parabolic
            final double x = startPos.dx + (endPos.dx - startPos.dx) * value;
            final double y = startPos.dy + (endPos.dy - startPos.dy) * value;

            // Hiệu ứng bay cong - tạo đường cong lên trên
            final double curveHeight = -100; // Độ cao của đường cong
            final double curvedY = y + curveHeight * Math.sin(value * Math.pi);

            return Positioned(
              left: x,
              top: curvedY,
              child: Transform.scale(
                scale: 1.0 - value * 0.5, // Nhỏ dần khi bay
                child: Opacity(
                  opacity: 1.0 - value * 0.7, // Mờ dần khi bay
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 800), () {
      entry.remove();
      // Kích hoạt hiệu ứng rung nhẹ cho icon giỏ hàng sau khi animation kết thúc
      _triggerCartAnimation();
    });
  }

  // ==================== EVENT HANDLERS ====================

  void _onColorSelected(int index) {
    if (index == selectedColorIndex) return;

    setState(() {
      selectedColorIndex = index;
      selectedSize = "";
      sizes.clear();
      _isLoadingSizes = true;
      _quantity = 0;
    });

    _listenToSizes();
  }

  Future<void> _addToCart() async {
    if (widget.idUser == null) {
      _showSnackBar('Vui lòng đăng nhập để thêm vào giỏ hàng', isError: true);
      return;
    }

    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    final colorName = _helper.getColorName(_selectedColorID);
    final sizeName = _helper.getSizeName(selectedSize, sizes);

    final cartItem = CartItem(
      cartItemId:
          '${widget.product.shopProduct.shopproductID}_${_selectedColorID}_$selectedSize',
      userId: widget.idUser!,
      productId: widget.product.shopProduct.shopproductID,
      productName: widget.product.productDetail.name ?? 'Không tên',
      variantId: _selectedVariantID,
      shopId: widget.product.shopProduct.shopId ?? '',
      colorId: _selectedColorID,
      sizeId: selectedSize,
      quantity: _quantity,
      price: _helper.getSizePrice(selectedSize, sizes),
      imageUrl:
          widget.product.variants[selectedColorIndex].imageUrls.isNotEmpty
              ? widget.product.variants[selectedColorIndex].imageUrls
              : '',
      addedAt: DateTime.now(),
      shopProductId: widget.product.shopProduct.shopproductID,
    );

    try {
      // Chạy hiệu ứng animation
      runAddToCartAnimation();

      await cartVM.addOrUpdateItem(cartItem);
    } catch (e) {
      _showSnackBar("❌ Lỗi thêm giỏ hàng: $e", isError: true);
    }
  }

  // Hàm đồng bộ rating từ reviews - SỬA LẠI
  double _getSyncedRating() {
    if (_reviews.isEmpty) return widget.product.shopProduct.rating ?? 0;

    double totalRating = 0;
    for (final review in _reviews) {
      totalRating += review['rating'] as double;
    }

    final averageRating = totalRating / _reviews.length;
    return double.parse(averageRating.toStringAsFixed(1)); // Giữ 1 số thập phân
  }

  // Hàm lấy dữ liệu reviews
  Future<List<Map<String, dynamic>>> _getProductReviewsData() async {
    try {
      print(
        '🔄 Đang lấy reviews cho: ${widget.product.shopProduct.shopproductID}',
      );

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('shop_product_reviews')
              .where(
                'shopProductId',
                isEqualTo: widget.product.shopProduct.shopproductID,
              )
              .orderBy('createdAt', descending: true)
              .get();

      print('✅ Tìm thấy ${querySnapshot.docs.length} reviews');

      // Tạo list reviews với user name
      final List<Map<String, dynamic>> reviews = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final String userId = data['userId'] ?? ''; // Giả sử field là 'userId'

        // Lấy tên người dùng
        final String userName = await _getUserName(userId);

        reviews.add({
          'userName': userName,
          'rating': (data['rating'] as num).toDouble(),
          'reviewText': data['reviewText'] ?? '',
          'createdAt': data['createdAt'] as Timestamp,
          'userId': userId, // Có thể thêm nếu cần
        });
      }

      return reviews;
    } catch (e) {
      print('❌ Lỗi khi lấy reviews: $e');
      throw e;
    }
  }

  // Thêm hàm này vào class _ProductDetailScreenState
  Future<String> _getUserName(String userId) async {
    try {
      if (userId.isEmpty) return 'Người dùng';

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users') // Thay đổi tên collection nếu cần
              .doc(userId)
              .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        // Tuỳ chỉnh field name theo cấu trúc database của bạn
        return userData?['name'] ??
            userData?['userName'] ??
            userData?['displayName'] ??
            'Người dùng';
      }

      return 'Người dùng';
    } catch (e) {
      print('❌ Lỗi khi lấy tên người dùng: $e');
      return 'Người dùng';
    }
  }

  // ==================== UI WIDGETS ====================
  Future<void> _loadReviews() async {
    try {
      setState(() {
        _isLoadingReviews = true;
        _reviewsError = null;
      });

      final reviews = await _getProductReviewsData();

      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });

      print('✅ DEBUG - Đã load ${_reviews.length} reviews vào state');
    } catch (e) {
      setState(() {
        _reviewsError = e.toString();
        _isLoadingReviews = false;
      });
      print('❌ DEBUG - Lỗi load reviews: $e');
    }
  }

  // Sửa lại widget dùng state
  Widget _buildRatingOverview() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviewsError != null) {
      return Center(
        child: Text(
          'Lỗi tải đánh giá: $_reviewsError',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có đánh giá nào',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    print('🎯 DEBUG - Hiển thị ${_reviews.length} reviews');

    double totalRating = 0;
    final ratingCounts = List.filled(5, 0);

    for (final review in _reviews) {
      final rating = review['rating'] as double;
      totalRating += rating;

      final starIndex = rating.floor() - 1;
      if (starIndex >= 0 && starIndex < 5) {
        ratingCounts[starIndex]++;
      }
    }

    final averageRating = totalRating / _reviews.length;
    final roundedRating = double.parse(averageRating.toStringAsFixed(1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Điểm rating trung bình
          Column(
            children: [
              Text(
                roundedRating.toString(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              RatingBar.builder(
                initialRating: roundedRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 16,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder:
                    (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (_) {},
                ignoreGestures: true,
              ),
              const SizedBox(height: 4),
              Text(
                '${_reviews.length} đánh giá',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Phân bố rating theo sao
          Expanded(
            child: Column(
              children:
                  List.generate(5, (index) {
                    final starCount = 5 - index;
                    final count = ratingCounts[4 - index];
                    final percentage =
                        _reviews.isNotEmpty
                            ? (count / _reviews.length) * 100
                            : 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$starCount',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.amber,
                              ),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_isLoadingReviews || _reviews.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        ..._reviews.take(5).map((review) {
          return _buildReviewItem(review);
        }).toList(),

        if (_reviews.length > 5)
          TextButton(
            onPressed: () {
              _showAllReviews();
            },
            child: const Text('Xem tất cả đánh giá'),
          ),
      ],
    );
  }

  Widget _buildCartIcon() {
    return StreamBuilder<int>(
      stream: _helper.getCartItemCountStream(widget.idUser),
      builder: (context, snapshot) {
        final itemCount = snapshot.data ?? 0;
        return Stack(
          children: [
            // Icon giỏ hàng chính
            IconButton(
              key: _cartIconKey,
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () {
                // ĐIỀU HƯỚNG ĐẾN CART SCREEN - ĐÃ SỬA
                if (widget.idUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChangeNotifierProvider(
                            create:
                                (context) =>
                                    CartViewModel(userId: widget.idUser!),
                            child: CartScreen(userId: widget.idUser!),
                          ),
                    ),
                  );
                } else {
                  _showSnackBar(
                    'Vui lòng đăng nhập để xem giỏ hàng',
                    isError: true,
                  );
                }
              },
            ),

            // Badge số lượng
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

            // Hiệu ứng rung khi thêm sản phẩm
            if (_showCartAnimation)
              Positioned(
                right: 8,
                top: 8,
                child: AnimatedBuilder(
                  animation: _cartAnimationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle:
                          _cartAnimationController.value *
                          0.1 *
                          Math.sin(_cartAnimationController.value * 10),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 3),
        action: action,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    _cartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết sản phẩm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 207, 221, 247),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [_buildCartIcon()],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSlider(),
              const SizedBox(height: 20),
              // Product Info
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    selectedSize.isEmpty
                        ? _helper.getFormattedMinPrice(sizes)
                        : _helper.getFormattedSizePrice(selectedSize, sizes),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Đã bán: ${widget.product.shopProduct.sold ?? 9}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Rating
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_getSyncedRating()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${_reviews.length ?? 0} đánh giá)",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildColorSelection(),
              const SizedBox(height: 20),
              _buildSizeSelection(),
              const SizedBox(height: 20),
              _buildQuantitySelector(),
              const SizedBox(height: 20),
              _buildDescription(),
              const SizedBox(height: 20),
              _buildProductReviews(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildDescription() {
    return ProductDescriptionWidget(
      description: widget.product.shopProduct.description,
      brandName: _brandName,
      shopAddress: _shopAddress,
      isLoadingAdditionalInfo: _isLoadingAdditionalInfo,
    );
  }

  // Trong build method của ProductDetailScreen, thay thế:
  Widget _buildImageSlider() {
    return ProductImageSlider(
      productImages: productImages,
      pageController: _pageController,
      currentImage: _currentImage,
      onPageChanged: (index) => setState(() => _currentImage = index),
      imageKey: _imageKey,
    );
  }

  Widget _buildColorSelection() {
    return ColorSelectionWidget(
      variants: widget.product.variants,
      selectedColorIndex: selectedColorIndex,
      onColorSelected: _onColorSelected,
      helper: _helper,
    );
  }

  Widget _buildSizeSelection() {
    return SizeSelectionWidget(
      sizes: sizes,
      selectedSize: selectedSize,
      onSizeSelected:
          (size) => setState(() {
            selectedSize = size;
            _quantity = 0;
          }),
      isLoading: _isLoadingSizes,
      helper: _helper,
    );
  }

  Widget _buildQuantitySelector() {
    return QuantitySelectorWidget(
      selectedSize: selectedSize,
      sizes: sizes,
      helper: _helper,
      onQuantityChanged: (quantity) => setState(() => _quantity = quantity),
    );
  }

  Widget _buildActionButtons() {
    return ProductActionButtons(
      selectedSize: selectedSize,
      onAddToCart: _addToCart,
      onBuyNow: _buyNow,
      addToCartButtonKey: _addToCartButtonKey,
      quantity: _quantity,
    );
  }

  void _buyNow() {
    if (widget.idUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để mua hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedSize.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn size'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số lượng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Sau đó chuyển đến checkout
    _navigateToCheckout();
  }

  void _navigateToCheckout() async {
    try {
      // Lấy thông tin sản phẩm đã chọn
      final selectedVariant = widget.product.variants[selectedColorIndex];
      final sizes =
          await _helper
              .listenSizesByVariant(
                productID: widget.product.shopProduct.shopproductID,
                variantID: selectedVariant.shopProductVariantID,
              )
              .first;

      // Tạo CartItem từ sản phẩm đã chọn
      final cartItem = CartItem(
        cartItemId:
            '${widget.product.shopProduct.shopproductID}_${selectedVariant.colorID}_$selectedSize',
        userId: widget.idUser!,
        productId: widget.product.shopProduct.shopproductID,
        productName: widget.product.productDetail.name ?? 'Không tên',
        variantId: selectedVariant.shopProductVariantID,
        shopId: widget.product.shopProduct.shopId ?? '',
        colorId: selectedVariant.colorID,
        sizeId: selectedSize,
        quantity: _quantity,
        price: _helper.getSizePrice(selectedSize, sizes),
        imageUrl:
            selectedVariant.imageUrls.isNotEmpty
                ? selectedVariant.imageUrls
                : '',
        addedAt: DateTime.now(),
        shopProductId: widget.product.shopProduct.shopproductID,
      );

      // Điều hướng đến checkout với sản phẩm đã chọn
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CheckoutScreen(
                userId: widget.idUser!,
                selectedItems: [cartItem],
                isFromCart: false,
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi mua ngay: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // ==================== REVIEW WIDGETS ====================

  // ==================== REVIEW WIDGETS ====================

  Widget _buildProductReviews() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá sản phẩm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Hiển thị tổng quan rating
          _buildRatingOverview(),
          const SizedBox(height: 16),

          // Danh sách đánh giá
          _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin người đánh giá và rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['userName'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              RatingBar.builder(
                initialRating: review['rating'],
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 16,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder:
                    (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (_) {},
                ignoreGestures: true,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Nội dung đánh giá
          if (review['reviewText'] != null &&
              (review['reviewText'] as String).isNotEmpty)
            Text(review['reviewText'], style: const TextStyle(fontSize: 14)),

          const SizedBox(height: 8),

          // Ngày đánh giá
          Text(
            _formatReviewDate((review['createdAt'] as Timestamp).toDate()),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else {
      return 'Vừa xong';
    }
  }

  void _showAllReviews() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tất cả đánh giá'),
            content: const Text('Tính năng đang phát triển'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }
}
