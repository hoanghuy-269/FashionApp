import 'package:fashion_app/data/models/product_request_model.dart';
import 'package:fashion_app/viewmodels/shop_product_request_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_viewmodel.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/staff/cashier.dart';
import 'package:fashion_app/views/staff/warehousemanagement/ordermanagement.dart';
import 'package:fashion_app/views/staff/warehousemanagement/orderprocessing.dart';
import 'package:fashion_app/views/staff/warehousemanagement/shopproduct_detal_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WarehouseScreen extends StatefulWidget {
  final String shopID;
  final String? staffID;
  const WarehouseScreen({super.key, required this.shopID, this.staffID});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  String? shopID;
  String? staffID;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    shopID = widget.shopID;
    staffID = widget.staffID;

    Future.microtask(() async {
      if (shopID != null) {
        final shopProductVM = context.read<ShopProductViewModel>();
        await shopProductVM.fetchShopProducts(shopID!);
      }
      if (staffID != null) {
        final storeStaffVM = context.read<StorestaffViewmodel>();
        await storeStaffVM.fetchStaffById(staffID!);
      }
    });
  }

  // Hàm gửi yêu cầu nhập hàng
  Future<void> _sendRestockRequest(
    BuildContext context,
    dynamic product,
  ) async {
    final requestVM = context.read<ShopProductRequestViewmodel>();

    final request = ProductRequestModel(
      productRequestID: '',
      shopProductID: product.shopproductID,
      shopID: shopID!,
      userID: staffID ?? '',
      quantity: int.tryParse(quantityController.text) ?? 0,
      status: 'pending',
      note: noteController.text,
      createdAt: DateTime.now(),
    );

    // Gửi request
    final requestID = await requestVM.addProductRequest(request);

    if (requestID != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi yêu cầu nhập hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gửi yêu cầu thất bại!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeStaff = context.watch<StorestaffViewmodel>().currentStaff;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<ShopProductModel>>(
          stream: context
              .read<ShopProductViewModel>()
              .getShopProductsByShopStream(shopID!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
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
                          Text(
                            storeStaff?.fullName ?? '',
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

                // nút đơn hàng với xử lí đơn hàng
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      Ordermanagement(shopID: widget.shopID),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Đơn hàng ',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // đơn hàng

                      // Đoạn mã nơi bạn chuyển đến màn hình Orderprocessing
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Orderprocessing(
                                    shopID: widget.shopID,
                                  ), // Truyền shopID
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Đóng gói ',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tổng số đơn
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Tổng số đơn trong kho: ${products.length}",
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
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isLowStock = product.totalQuantity <= 5;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isLowStock ? Colors.red.shade50 : null,
                          border: const Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrls,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ShopproductDetalScreen(
                                            shopID: shopID,
                                            productDetailID:
                                                product.shopproductID,
                                          ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Số lượng: ${product.totalQuantity}',
                                          style: TextStyle(
                                            color:
                                                isLowStock
                                                    ? Colors.red
                                                    : Colors.grey,
                                            fontWeight:
                                                isLowStock
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                        if (isLowStock) ...[
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.warning,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.send,
                                color: isLowStock ? Colors.red : Colors.blue,
                              ),
                              onPressed: () {
                                _showRestockRequestDialog(context, product);
                              },
                            ),
                          ],
                        ),
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

  Future<void> _showRestockRequestDialog(
    BuildContext context,
    dynamic product,
  ) async {
    quantityController.clear();
    noteController.clear();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yêu cầu nhập hàng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng cần nhập',
                ),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _sendRestockRequest(context, product);
                Navigator.of(context).pop();
              },
              child: const Text('Gửi yêu cầu'),
            ),
          ],
        );
      },
    );
  }
}
