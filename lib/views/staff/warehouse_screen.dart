import 'package:fashion_app/viewmodels/shop_product_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WarehouseScreen extends StatefulWidget {
  final String shopID;
  const WarehouseScreen({super.key, required this.shopID});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  String? shopID;

 @override
void initState() {
  super.initState();

  // Lấy shopID từ widget
  shopID = widget.shopID;

  Future.microtask(() async {
    if (shopID != null) {
      final shopProductVM = context.read<ShopProductViewModel>();

      await shopProductVM.fetchShopProducts(shopID!);
  
    }
  });
}



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Consumer<ShopProductViewModel>(
          builder: (context, shopproductVM, _) {
            if (shopproductVM.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (shopproductVM.shopProducts.isEmpty) {
              return const Center(child: Text('Không có sản phẩm trong kho'));
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(
                              'assets/images/logo_person.png',
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Tên nhân viên',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tổng số đơn
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Tổng số đơn trong kho: ${shopproductVM.shopProducts.length}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Danh sách sản phẩm
                Expanded(
                  child: ListView.builder(
                    itemCount: shopproductVM.shopProducts.length,
                    itemBuilder: (context, index) {
                      final product = shopproductVM.shopProducts[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Số lượng: ${product.totalQuantity}'),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
