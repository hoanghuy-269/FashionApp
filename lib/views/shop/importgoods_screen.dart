import 'package:fashion_app/viewmodels/shop_product_request_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/views/shop/add_importgoods/add_importgoods_screen.dart';
import 'package:fashion_app/views/shop/add_variant_request.dart';
import 'package:fashion_app/views/shop/importgoods_warehouse_screen.dart';
import 'package:fashion_app/data/models/product_request_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImportgoodsCreen extends StatefulWidget {
  final String? shopID;
  final String? productRequestID;
  const ImportgoodsCreen({super.key, this.shopID, this.productRequestID});

  @override
  State<ImportgoodsCreen> createState() => _ImportgoodsCreenState();
}

class _ImportgoodsCreenState extends State<ImportgoodsCreen> {
  Stream<List<ProductRequestModel>>? _requestsStream;
  String? _shopID;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopID = context.read<ShopViewModel>().currentShop?.shopId;
      if (shopID != null) {
        context.read<ShopProductRequestViewmodel>().fetchAllRequestsByShop(
          shopID,
        );

        // Lưu stream và shopID vào state để tránh tạo stream mới mỗi lần rebuild
        if (mounted) {
          setState(() {
            _shopID = shopID;
            _requestsStream = context
                .read<ShopProductRequestViewmodel>()
                .getAllRequestsByShopStream(shopID);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem shop đã được load chưa
    final shopVM = context.watch<ShopViewModel>();

    if (shopVM.currentShop == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải thông tin cửa hàng...'),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 10),

              // Tab bar
              const TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [Tab(text: "Yêu cầu nhập"), Tab(text: "Đã nhập")],
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPendingRequestsTab(),
                    _buildApprovedRequestsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
          ),
          const Spacer(),
          const Text(
            "Nhập hàng",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddImportgoodsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 30, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // Tab 1: Yêu cầu nhập (pending)
  Widget _buildPendingRequestsTab() {
    if (_shopID == null || _requestsStream == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải dữ liệu...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return StreamBuilder<List<ProductRequestModel>>(
      stream: _requestsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _requestsStream = context
                            .read<ShopProductRequestViewmodel>()
                            .getAllRequestsByShopStream(_shopID!);
                      });
                    }
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final pendingRequests =
            (snapshot.data ?? [])
                .where((request) => request.status == 'pending')
                .toList();

        if (pendingRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Chưa có yêu cầu nhập hàng nào",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: pendingRequests.length,
          itemBuilder: (context, index) {
            final request = pendingRequests[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pending_actions,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
                title: Text(
                  'Sản phẩm: ${request.shopProductID}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số lượng: ${request.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ghi chú: ${request.note.isNotEmpty ? request.note : "Không có"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddVariantRequest(
                            shopProductID: request.shopProductID,
                            productRequestID: request.productRequestID,
                          ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApprovedRequestsTab() {
  if (_shopID == null) {
    return const Center(child: Text('Đang tải...'));
  }

  return StreamBuilder<List<ProductRequestModel>>(
    stream: context
        .read<ShopProductRequestViewmodel>()
        .getAllRequestsByShopStream(_shopID!),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final approvedRequests = snapshot.data!
          .where((request) => request.status == 'approved')
          .toList();

      if (approvedRequests.isEmpty) {
        return const Center(
          child: Text(
            'Chưa có đơn hàng nào được duyệt',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: approvedRequests.length,
        itemBuilder: (context, index) {
          final request = approvedRequests[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),

              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2, color: Colors.green),
              ),

              title: Text(
                'Mã Sản phẩm: ${request.shopProductID}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    "Thời gian  ${request.createdAt}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Đã nhập kho",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}


  @override
  void dispose() {
    // Stream sẽ tự động dispose khi widget bị destroy
    super.dispose();
  }
}
