import 'package:fashion_app/data/models/product_request_model.dart';
import 'package:fashion_app/viewmodels/shop_product_request_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_viewmodel.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/login/login_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.microtask(() async {
      if (widget.shopID.isNotEmpty) {
        await context.read<ShopProductViewModel>().fetchShopProducts(widget.shopID);
      }
      if (widget.staffID != null) {
        await context.read<StorestaffViewmodel>().fetchStaffById(widget.staffID!);
      }
    });
  }

  List<ShopProductModel> _filterProducts(List<ShopProductModel> products) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeStaff = context.watch<StorestaffViewmodel>().currentStaff;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${storeStaff?.fullName ?? 'Quản lý kho hàng'}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              const SizedBox(height: 4),
              Text("Nhân viên Kho ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  )),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _handleLogout(),
          ),

        ],
      ),
      body: StreamBuilder<List<ShopProductModel>>(
        stream: context
            .read<ShopProductViewModel>()
            .getShopProductsByShopStream(widget.shopID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProducts = snapshot.data ?? [];
          final products = _filterProducts(allProducts);
          final lowStockCount = products.where((p) => p.totalQuantity <= 5).length;

          return Column(
            children: [
              _buildSearchBar(),
              _buildActionButtons(),
              _buildStatistics(products.length, lowStockCount),
              Expanded(
                child: products.isEmpty
                    ? const Center(child: Text('Không tìm thấy sản phẩm'))
                    : _buildProductList(products),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Ordermanagement(shopID: widget.shopID),
                ),
              ),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Đơn hàng'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Orderprocessing(shopID: widget.shopID),
                ),
              ),
              icon: const Icon(Icons.inventory_2),
              label: const Text('Đóng gói'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(int total, int lowStock) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Tổng SP', total.toString(), Colors.blue),
          _buildStatItem('Sắp hết', lowStock.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildProductList(List<ShopProductModel> products) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isLowStock = product.totalQuantity <= 5;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrls,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Icon(
                  isLowStock ? Icons.warning : Icons.check_circle,
                  size: 16,
                  color: isLowStock ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'SL: ${product.totalQuantity}',
                  style: TextStyle(
                    color: isLowStock ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.add_shopping_cart,
                color: isLowStock ? Colors.red : Colors.blue,
              ),
              onPressed: () => _showRestockDialog(product),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopproductDetalScreen(
                  shopID: widget.shopID,
                  productDetailID: product.shopproductID,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRestockDialog(ShopProductModel product) async {
    final quantityController = TextEditingController();
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu nhập hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    product.imageUrls,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Tồn kho: ${product.totalQuantity}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số lượng *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (quantityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập số lượng!')),
                );
                return;
              }
              await _sendRestockRequest(
                product,
                int.tryParse(quantityController.text) ?? 0,
                noteController.text,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRestockRequest(
    ShopProductModel product,
    int quantity,
    String note,
  ) async {
    final requestVM = context.read<ShopProductRequestViewmodel>();

    final request = ProductRequestModel(
      productRequestID: '',
      shopProductID: product.shopproductID,
      shopID: widget.shopID,
      userID: widget.staffID ?? '',
      quantity: quantity,
      status: 'pending',
      note: note,
      createdAt: DateTime.now(),
    );

    final requestID = await requestVM.addProductRequest(request);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            requestID != null
                ? 'Đã gửi yêu cầu thành công!'
                : 'Gửi yêu cầu thất bại!',
          ),
          backgroundColor: requestID != null ? Colors.green : Colors.red,
        ),
      );
    }
  }
   Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Đăng xuất"),
            content: const Text("Bạn có chắc muốn đăng xuất không?"),
            actions: [
              TextButton(
                child: const Text("Hủy"),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Đăng xuất"),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

}