import 'dart:async';
import 'dart:math' as Math;
import 'package:fashion_app/data/models/User.dart';
import 'package:fashion_app/data/models/cart_model.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:fashion_app/data/repositories/shop_product_repository.dart';
import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/viewmodels/cart_view_model.dart';
import 'package:fashion_app/views/user/notification_screen.dart';
import 'package:fashion_app/views/user/payment_screen.dart';
import 'package:fashion_app/views/user/widget/banner_screen.dart';
import 'package:fashion_app/views/user/widget/bottom_nav.dart';
import 'package:fashion_app/views/user/cart_screen.dart';
import 'package:fashion_app/views/user/widget/category.dart';
import 'package:fashion_app/views/user/filter_drawer.dart';
import 'package:fashion_app/views/user/product_detail.dart';
import 'package:fashion_app/views/user/widget/product_detail_helper.dart';
import 'package:fashion_app/views/user/userprofile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_item.dart';

class HomeScreen extends StatefulWidget {
  final String? idUser;
  const HomeScreen({super.key, this.idUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthViewModel _authVM = AuthViewModel();
  final ShopProductRepository _shopRepo = ShopProductRepository();
  final CategoriesRepository _categoriesRepo = CategoriesRepository();
  final TextEditingController _searchController = TextEditingController();
  final BrandsRepository _brandsRepo = BrandsRepository();
  Map<String, dynamic> _currentFilters = {};
  bool _isFiltering = false;
  String _searchText = "";
  List<ShopProductWithDetail> _cachedProducts = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _allCategories = [];
  List<Map<String, dynamic>> _allBrands = [];
  final ProductDetailHelper _helper = ProductDetailHelper();
  Stream<List<ShopProductWithDetail>>? _bannerProductStream;
  List<ShopProductWithDetail> _bannerProducts = [];
  //Hiệu ứng
  final GlobalKey _imageKey = GlobalKey();
  bool _showCartAnimation = false;
  final GlobalKey _cartIconKey = GlobalKey();
  final GlobalKey _addToCartButtonKey = GlobalKey();
  late AnimationController _cartAnimationController;

  Stream<List<ShopProductWithDetail>>? _productStream;

  // Debounce cho search
  Timer? _searchDebounce;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 300);

  // Cache cho filtered products
  List<ShopProductWithDetail>? _filteredProductsCache;
  String _lastSearchText = "";
  Map<String, dynamic> _lastFilters = {};

  final Map<String, dynamic> _defaultFilters = {
    'brand': 'All',
    'category': 'All',
    'minPrice': 0.0,
    'maxPrice': 1000000.0,
    'rating': 0.0,
  };

  void _navigateToCheckout(
    ShopProductWithDetail product,
    String selectedSize,
    int selectedColorIndex,
    int quantity,
  ) async {
    try {
      final selectedVariant = product.variants[selectedColorIndex];
      final sizes =
          await _helper
              .listenSizesByVariant(
                productID: product.shopProduct.shopproductID,
                variantID: selectedVariant.shopProductVariantID,
              )
              .first;

      // SỬA: Không cần kiểm tra .isNotEmpty vì imageUrls là String
      final cartItem = CartItem(
        cartItemId:
            '${product.shopProduct.shopproductID}_${selectedVariant.colorID}_$selectedSize',
        userId: widget.idUser!,
        productId: product.shopProduct.shopproductID,
        productName: product.productDetail.name ?? 'Không tên',
        variantId: selectedVariant.shopProductVariantID,
        shopId: product.shopProduct.shopId ?? '',
        colorId: selectedVariant.colorID,
        sizeId: selectedSize,
        quantity: quantity,
        price: _helper.getSizePrice(selectedSize, sizes),
        // SỬA: Truyền trực tiếp vào getSafeImageUrl
        imageUrl: getSafeImageUrl(
          selectedVariant.imageUrls, // selectedVariant.imageUrls là String
        ),
        addedAt: DateTime.now(),
        shopProductId: product.shopProduct.shopproductID,
      );

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
      _showSnackBar("❌ Lỗi khi mua ngay: $e", isError: true);
    }
  }

  void _loadCategoriesAndBrands() {
    _categoriesRepo.getCategories().first.then((value) {
      if (mounted) {
        setState(() {
          _allCategories = value;
        });
      }
    });

    _brandsRepo.getBrands().first.then((value) {
      if (mounted) {
        setState(() {
          _allBrands = value;
        });
      }
    });
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

  void _validateProductData(List<ShopProductWithDetail> products) {
    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      print('🔍 Validating product $i: ${product.productDetail.name}');
      print(
        '   - imageUrls type: ${product.shopProduct.imageUrls.runtimeType}',
      );
      print('   - imageUrls value: ${product.shopProduct.imageUrls}');

      // Kiểm tra các trường dễ gây lỗi
      if (product.shopProduct.imageUrls == null) {
        print('   ❌ imageUrls is NULL');
      }
    }
  }

  void _showProductOptionsBottomSheet(ShopProductWithDetail product) async {
    if (!_helper.isSizeCacheLoaded) {
      await _helper.loadAllSizes();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProductOptionsBottomSheet(
          product: product,
          onClose: () => Navigator.pop(context),
          onAddToCart: _addToCartFromHome,
          onAddToCartAnimation: runAddToCartAnimation,
          onBuyNow: (selectedSize, selectedColorIndex, quantity) {
            _navigateToCheckout(
              product,
              selectedSize,
              selectedColorIndex,
              quantity,
            ); // Điều hướng đến checkout
          },
        );
      },
    );
  }

  // Hàm thêm vào giỏ hàng từ home
  Future<void> _addToCartFromHome(
    ShopProductWithDetail product,
    StateSetter setModalState, {
    String? selectedSize,
    int? selectedColorIndex,
    int? quantity,
  }) async {
    if (widget.idUser == null) {
      _showSnackBar('Vui lòng đăng nhập để thêm vào giỏ hàng', isError: true);
      return;
    }

    final cartVM = Provider.of<CartViewModel>(context, listen: false);

    final actualSelectedSize = selectedSize ?? "";
    final actualSelectedColorIndex = selectedColorIndex ?? 0;
    final actualQuantity = quantity ?? 1;

    if (actualSelectedSize.isEmpty) {
      _showSnackBar('Vui lòng chọn size', isError: true);
      return;
    }

    final selectedVariant = product.variants[actualSelectedColorIndex];

    try {
      final sizes =
          await _helper
              .listenSizesByVariant(
                productID: product.shopProduct.shopproductID,
                variantID: selectedVariant.shopProductVariantID,
              )
              .first;

      final cartItem = CartItem(
        cartItemId:
            '${product.shopProduct.shopproductID}_${selectedVariant.colorID}_$actualSelectedSize',
        userId: widget.idUser!,
        productId: product.shopProduct.shopproductID,
        productName: product.productDetail.name ?? 'Không tên',
        variantId: selectedVariant.shopProductVariantID,
        shopId: product.shopProduct.shopId ?? '',
        colorId: selectedVariant.colorID,
        sizeId: actualSelectedSize,
        quantity: actualQuantity,
        price: _helper.getSizePrice(actualSelectedSize, sizes),
        // SỬA: Truyền trực tiếp vào getSafeImageUrl
        imageUrl: getSafeImageUrl(
          selectedVariant.imageUrls, // selectedVariant.imageUrls là String
        ),
        addedAt: DateTime.now(),
        shopProductId: product.shopProduct.shopproductID,
      );

      runAddToCartAnimation();
      await cartVM.addOrUpdateItem(cartItem);
    } catch (e) {
      _showSnackBar("❌ Lỗi thêm giỏ hàng: $e", isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentFilters = Map.from(_defaultFilters);
    _lastFilters = Map.from(_defaultFilters);
    _productStream = _shopRepo.getAllShopProductsWithDetail();
    _bannerProductStream = _createBannerStream();
    _loadCategoriesAndBrands();
    _loadAllSizes();
  }

  // Hàm lấy ảnh an toàn từ dynamic imageUrls
  // Hàm lấy ảnh an toàn từ dynamic imageUrls
  String getSafeImageUrl(dynamic imageUrls) {
    try {
      if (imageUrls == null) {
        return "https://via.placeholder.com/150";
      }

      // Chỉ cần xử lý String và có fallback
      if (imageUrls is String) {
        return imageUrls.isNotEmpty
            ? imageUrls
            : "https://via.placeholder.com/150";
      }

      // Fallback cho các trường hợp khác (nếu có)
      return "https://via.placeholder.com/150";
    } catch (e) {
      print('❌ Error in getSafeImageUrl: $e');
      return "https://via.placeholder.com/150";
    }
  }

  // Hàm tạo banner stream đơn giản
  Stream<List<ShopProductWithDetail>> _createBannerStream() {
    return _shopRepo.getAllShopProductsWithDetail();
  }

  void _loadAllSizes() async {
    await _helper.loadAllSizes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // Thêm hàm chuẩn hóa tiếng Việt
  List<ShopProductWithDetail> _applyFilter() {
    final bool isSameSearch = _searchText == _lastSearchText;
    final bool isSameFilters = _mapEquals(_currentFilters, _lastFilters);

    if (isSameSearch && isSameFilters && _filteredProductsCache != null) {
      return _filteredProductsCache!;
    }

    if (!_isFiltering && _searchText.isEmpty) {
      _filteredProductsCache = _cachedProducts;
      _lastSearchText = _searchText;
      _lastFilters = Map.from(_currentFilters);
      return _cachedProducts;
    }

    final filtered =
        _cachedProducts.where((item) {
          final productName = item.productDetail.name ?? "";

          // TÌM KIẾM THEO TÊN
          final matchesSearch =
              _searchText.isEmpty ||
              productName.toLowerCase().contains(_searchText.toLowerCase());

          if (!matchesSearch) return false;

          // LỌC THEO BRAND
          final selectedBrands =
              (_currentFilters['brand'] is List
                  ? List<String>.from(_currentFilters['brand']!)
                  : []);

          final matchesBrand =
              selectedBrands.isEmpty ||
              selectedBrands.contains('All') ||
              selectedBrands.contains(item.productDetail.brandID);

          if (!matchesBrand) return false;

          // LỌC THEO CATEGORY
          final selectedCategories =
              (_currentFilters['category'] is List
                  ? List<String>.from(_currentFilters['category']!)
                  : []);

          final matchesCategory =
              selectedCategories.isEmpty ||
              selectedCategories.contains('All') ||
              selectedCategories.contains(item.productDetail.categoryID);

          if (!matchesCategory) return false;

          // LỌC THEO GIÁ
          final minPrice = _currentFilters['minPrice'] ?? 0.0;
          final maxPrice = _currentFilters['maxPrice'] ?? double.maxFinite;
          final matchesPrice =
              item.lowestPrice >= minPrice && item.lowestPrice <= maxPrice;

          if (!matchesPrice) return false;

          // LỌC THEO ĐÁNH GIÁ
          final minRating = _currentFilters['rating'] ?? 0;
          final matchesRating = (item.shopProduct.rating ?? 0) >= minRating;

          if (!matchesRating) return false;

          return true;
        }).toList();

    _filteredProductsCache = filtered;
    _lastSearchText = _searchText;
    _lastFilters = Map.from(_currentFilters);

    return filtered;
  }

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (a[key] != b[key]) {
        if (a[key] is List && b[key] is List) {
          final listA = a[key] as List;
          final listB = b[key] as List;
          if (listA.length != listB.length) return false;
          for (int i = 0; i < listA.length; i++) {
            if (listA[i] != listB[i]) return false;
          }
        } else {
          return false;
        }
      }
    }
    return true;
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (mounted) {
        print('🎯 User searched: "$value"');
        setState(() {
          _searchText = value.trim();
          _filteredProductsCache = null;
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchText = "";
      _filteredProductsCache = null;
    });
  }

  void _clearFilter() {
    setState(() {
      _currentFilters = Map.from(_defaultFilters);
      _isFiltering = false;
      _filteredProductsCache = null;
    });
  }

  Widget _buildCartIcon() {
    return StreamBuilder<int>(
      stream: _helper.getCartItemCountStream(widget.idUser),
      builder: (context, snapshot) {
        final itemCount = snapshot.data ?? 0;
        return Stack(
          children: [
            IconButton(
              key: _cartIconKey,
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () {
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng đăng nhập để xem giỏ hàng'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.only(top: 10),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: StreamBuilder<User?>(
                stream: _authVM.getUserById(widget.idUser!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Đang tải...");
                  }
                  if (!snapshot.hasData) {
                    return const Text("Không tìm thấy user");
                  }

                  final user = snapshot.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => UserprofileScreen(idUser: user.id),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.orange.shade300,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            user.name ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildCartIcon(),
                          IconButton(
                            onPressed: () {
                              // Chuyển qua màn hình thông báo
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => NotificationScreen(
                                        userId:
                                            user.id, // Thay bằng userId thực tế
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.notifications_none),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // SEARCH BAR - CỐ ĐỊNH (không cuộn)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                        icon: const Icon(Icons.search),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: _clearSearch,
                                )
                                : null,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await showGeneralDialog<
                          Map<String, dynamic>
                        >(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: '',
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (context, anim1, anim2) {
                            final topPadding =
                                MediaQuery.of(context).padding.top +
                                kToolbarHeight;
                            return Align(
                              alignment: Alignment.centerRight,
                              child: FractionallySizedBox(
                                widthFactor: 0.85,
                                child: Container(
                                  margin: EdgeInsets.only(top: topPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.9,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: FilterDrawer(
                                        initialFilters: _currentFilters,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          transitionBuilder: (context, anim1, anim2, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: anim1,
                                  curve: Curves.easeOut,
                                ),
                              ),
                              child: child,
                            );
                          },
                        );

                        if (result != null) {
                          setState(() {
                            _currentFilters = result;
                            _isFiltering = true;
                            _filteredProductsCache = null;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.filter_list),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_isFiltering)
                      GestureDetector(
                        onTap: _clearFilter,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // BANNER + PRODUCTS - CUỘN CÙNG NHAU
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // BANNER - giờ cuộn cùng sản phẩm
                  StreamBuilder<List<ShopProductWithDetail>>(
                    stream: _bannerProductStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        print('❌ Banner stream error: ${snapshot.error}');
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 40),
                                SizedBox(height: 8),
                                Text(
                                  'Lỗi tải banner',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              'Chưa có sản phẩm nổi bật',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        );
                      }

                      final bannerProducts = snapshot.data!;
                      return BestSellingBanner(
                        products: bannerProducts,
                        idUser: widget.idUser,
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // PRODUCT GRID - cuộn cùng banner
                  StreamBuilder<List<ShopProductWithDetail>>(
                    stream: _productStream,
                    builder: (context, snapshot) {
                      if (_productStream == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        print('❌ Stream error: ${snapshot.error}');
                        print('❌ Stack trace: ${snapshot.stackTrace}');
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 50),
                              SizedBox(height: 10),
                              Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _productStream =
                                        _shopRepo
                                            .getAllShopProductsWithDetail();
                                  });
                                },
                                child: Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("Chưa có sản phẩm nào"),
                        );
                      }

                      final products = snapshot.data!;
                      _validateProductData(products);
                      _cachedProducts = products;

                      final displayedProducts = _applyFilter();

                      return Column(
                        children: [
                          if (_isFiltering || _searchText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Tìm thấy ${displayedProducts.length} sản phẩm',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),

                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(7),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.72,
                                ),
                            itemCount: displayedProducts.length,
                            itemBuilder: (context, index) {
                              try {
                                final item = displayedProducts[index];
                                final product = item.productDetail;
                                final shopInfo = item.shopProduct;

                                final displayImage = getSafeImageUrl(
                                  shopInfo.imageUrls,
                                );

                                return ProductItem(
                                  name: product.name ?? "Không có tên",
                                  price: item.lowestPrice,
                                  rating: shopInfo.rating?.toDouble() ?? 4.0,
                                  imageUrl: displayImage,
                                  onBuyNow: () {
                                    _showProductOptionsBottomSheet(item);
                                  },
                                  onAddToCart: () {
                                    _showProductOptionsBottomSheet(item);
                                  },
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ProductDetailScreen(
                                              product: item,
                                              idUser: widget.idUser,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              } catch (e, stackTrace) {
                                print(
                                  '❌ ERROR building product item at index $index: $e',
                                );
                                print('❌ Stack trace: $stackTrace');

                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.red),
                                      SizedBox(height: 8),
                                      Text(
                                        'Lỗi tải sản phẩm',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void runAddToCartAnimation([GlobalKey? buttonKey]) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // Delay để đảm bảo context đã được render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Sử dụng key từ bottom sheet nếu được cung cấp, hoặc key mặc định
        final addToCartBox =
            (buttonKey ?? _addToCartButtonKey).currentContext
                    ?.findRenderObject()
                as RenderBox?;

        final cartBox =
            _cartIconKey.currentContext?.findRenderObject() as RenderBox?;

        if (addToCartBox == null || cartBox == null) {
          print('❌ Không tìm thấy vị trí cho animation');
          return;
        }

        final startPos = addToCartBox.localToGlobal(Offset.zero);
        final endPos = cartBox.localToGlobal(Offset.zero);

        print('🎯 Animation từ: $startPos đến: $endPos');

        final entry = OverlayEntry(
          builder: (_) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                final double x =
                    startPos.dx + (endPos.dx - startPos.dx) * value;
                final double y =
                    startPos.dy + (endPos.dy - startPos.dy) * value;
                final double curveHeight = -100;
                final double curvedY =
                    y + curveHeight * Math.sin(value * Math.pi);

                return Positioned(
                  left: x,
                  top: curvedY,
                  child: Transform.scale(
                    scale: 1.0 - value * 0.5,
                    child: Opacity(opacity: 1.0 - value * 0.7, child: child),
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
          print('✅ Animation hoàn thành');
        });
      } catch (e) {
        print('❌ Lỗi animation: $e');
      }
    });
  }
}
