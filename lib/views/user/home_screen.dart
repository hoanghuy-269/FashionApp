import 'package:fashion_app/data/models/User.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:fashion_app/data/repositories/shop_product_repository.dart';
import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/views/user/filter_drawer.dart';
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
  Map<String, dynamic> _filters = {
    'brand': 'All',
    'category': 'All',
    'minPrice': 10.0,
    'maxPrice': 100.0,
    'rating': 0.0,
  };
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();

  List<ShopProductWithDetail> _applyFilter(
    List<ShopProductWithDetail> products,
  ) {
    return products.where((item) {
      final matchesBrand =
          _filters['brand'] == 'All' ||
          item.productDetail.brandID == _filters['brand'];
      final matchesCategory =
          _filters['category'] == 'All' ||
          item.productDetail.categoryID == _filters['category'];
      final matchesPrice =
          item.lowestPrice >= _filters['minPrice'] &&
          item.lowestPrice <= _filters['maxPrice'];
      final matchesRating = item.shopProduct.rating! >= _filters['rating'];

      return matchesBrand && matchesCategory && matchesPrice && matchesRating;
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
                            user.name ?? "", // ✅ Dùng user từ stream
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
                      decoration: const InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
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
                    final result =
                        await showGeneralDialog<Map<String, dynamic>>(
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
                                  child: const FilterDrawer(),
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
                        _filters = result;
                      });
                    }
                  },
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

                    return ProductItem(
                      name: product.name,
                      price: item.lowestPrice,
                      rating: shopInfo.rating?.toDouble() ?? 4.0,
                      imageUrl: "https://via.placeholder.com/150",
                      onBuyNow: () {
                        print(
                          "Mua sản phẩm: ${product.name} từ shop ${shopInfo.shopId}",
                        );
                      },
                      onAddToCart: () {},
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
