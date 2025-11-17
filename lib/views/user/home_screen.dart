import 'package:fashion_app/data/models/User.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:fashion_app/data/repositories/shop_product_repository.dart';
import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/views/user/filter_drawer.dart';
import 'package:fashion_app/views/user/product_detail.dart';
import 'package:fashion_app/views/user/userprofile_screen.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic> _currentFilters = {}; // Filter hiện tại
  bool _isFiltering = false; // Có đang áp dụng filter không
  String _searchText = "";

  Map<String, dynamic> _defaultFilters = {
    'brand': 'All',
    'category': 'All',
    'minPrice': 0.0,
    'maxPrice': 10000000.0, // Giá trị lớn để hiển thị tất cả
    'rating': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _currentFilters = Map.from(_defaultFilters); // Khởi tạo với filter mặc định
  }

  List<ShopProductWithDetail> _applyFilter(
    List<ShopProductWithDetail> products,
  ) {
    // Nếu không có filter active VÀ không có search text, return tất cả sản phẩm
    if (!_isFiltering && _searchText.isEmpty) {
      return products;
    }

    return products.where((item) {
      // Search filter
      final matchesSearch =
          _searchText.isEmpty ||
          (item.productDetail.name ?? "").toLowerCase().contains(_searchText);

      // Nếu chỉ có search mà không có filter
      if (!_isFiltering) {
        return matchesSearch;
      }

      // Áp dụng các filter khác
      final matchesBrand =
          _currentFilters['brand'] == 'All' ||
          item.productDetail.brandID == _currentFilters['brand'];
      final matchesCategory =
          _currentFilters['category'] == 'All' ||
          item.productDetail.categoryID == _currentFilters['category'];
      final matchesPrice =
          item.lowestPrice >= _currentFilters['minPrice'] &&
          item.lowestPrice <= _currentFilters['maxPrice'];
      final matchesRating =
          (item.shopProduct.rating ?? 0) >= _currentFilters['rating'];

      return matchesSearch &&
          matchesBrand &&
          matchesCategory &&
          matchesPrice &&
          matchesRating;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.shopping_bag_outlined),
                          ),
                          IconButton(
                            onPressed: () {},
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
                        icon: Icon(Icons.search),
                        // THÊM NÚT CLEAR
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchText = "";
                                    });
                                  },
                                )
                                : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchText = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                            MediaQuery.of(context).padding.top + kToolbarHeight;
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
                                    MediaQuery.of(context).size.height * 0.9,
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
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
                        _isFiltering = true; // BẬT chế độ lọc
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
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<ShopProductWithDetail>>(
              stream: _shopRepo.getAllShopProductsWithDetail(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Chưa có sản phẩm nào"));
                }

                final shopProducts = snapshot.data!;
                final filteredProducts = _applyFilter(shopProducts);

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text("Không có sản phẩm phù hợp"));
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(7),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final item = filteredProducts[index];
                    final product = item.productDetail;
                    final shopInfo = item.shopProduct;

                    print("=== Hiển thị sản phẩm ===");
                    print("Tên: ${product.name}");
                    print("Giá: ${item.lowestPrice}");
                    print("Rating: ${shopInfo.rating}");
                    print("Image URLs: ${shopInfo.imageUrls}");

                    String displayImage =
                        "https://via.placeholder.com/150"; // fallback
                    if (shopInfo.imageUrls != null &&
                        shopInfo.imageUrls!.isNotEmpty) {
                      if (shopInfo.imageUrls is String) {
                        displayImage = shopInfo.imageUrls as String;
                      } else if (shopInfo.imageUrls is List<String>) {
                        final images = shopInfo.imageUrls as List<String>;
                        if (images.isNotEmpty) {
                          displayImage = images.first;
                        }
                      }
                    }

                    return ProductItem(
                      name: product.name ?? "Không có tên",
                      price: item.lowestPrice,
                      rating: shopInfo.rating?.toDouble() ?? 4.0,
                      imageUrl: displayImage,
                      onBuyNow: () {
                        print("Mua sản phẩm: ${product.name}");
                      },
                      onAddToCart: () {
                        print("Thêm vào giỏ: ${product.name}");
                      },
                      onTap: () {
                        // THÊM CALLBACK KHI ẤN VÀO SẢN PHẨM
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailScreen(
                                  product: item,
                                  idUser: widget.idUser,
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
