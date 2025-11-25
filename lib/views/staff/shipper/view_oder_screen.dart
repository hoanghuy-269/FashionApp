import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/oder_item_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ViewOderScreen extends StatefulWidget {
  final String staffID;
  final String shopID;
  const ViewOderScreen({
    super.key,
    required this.shopID,
    required this.staffID,
  });

  @override
  State<ViewOderScreen> createState() => _ViewOderScreenState();
}

class _ViewOderScreenState extends State<ViewOderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _expandedItems = {};
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final staffVM = context.read<StorestaffViewmodel>();
      staffVM.fetchStaffById(widget.staffID);
      final orderItemVM = context.read<OrderItemViewModel>();
      orderItemVM.listenOrderItems(widget.shopID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quản lý đơn hàng",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.blue,
          tabs: const [Tab(text: "Khách nhận "), Tab(text: "Khách hủy")],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [data("status_004"), data("status_005")],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget data(String status) {
    final colorVM = context.watch<ColorsViewmodel>();
    final sizeVM = context.watch<SizesViewmodel>();
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Column(
      children: [
        Expanded(
          child: Consumer<OrderItemViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Lỗi: ${vm.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => vm.listenOrderItems(widget.shopID),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (vm.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final filteredItems =
                  vm.items.where((item) => item.itemStatus == status).toList();
              return RefreshIndicator(
                onRefresh: () async {
                  vm.listenOrderItems(widget.shopID);
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isExpanded = _expandedItems.contains(index);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(12),

                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  (item.imageUrl.trim().isEmpty)
                                      ? Container(
                                        width: 64,
                                        height: 64,
                                        color: Colors.grey[300],
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.photo,
                                          size: 28,
                                        ),
                                      )
                                      : CachedNetworkImage(
                                        imageUrl: item.imageUrl!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (_, __, ___) => Container(
                                              width: 64,
                                              height: 64,
                                              color: Colors.grey[300],
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.broken_image,
                                              ),
                                            ),
                                      ),
                            ),

                            title: FutureBuilder<String>(
                              future: vm.getUserNameCached(
                                item.parentOrder?.userId ?? '',
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Lỗi tải tên',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[300],
                                      fontSize: 16,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    snapshot.data ?? 'Khách hàng',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  );
                                }
                              },
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "SĐT ${item.parentOrder?.customerPhone ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${formatter.format(item.totalPrice)}đ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedItems.remove(index);
                                      } else {
                                        _expandedItems.add(index);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          if (isExpanded)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border(
                                  top: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                    icon: Icons.shopping_bag,
                                    label: "Mã đơn hàng",
                                    value: item.parentOrder?.orderId ?? 'N/A',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    icon: Icons.countertops,
                                    label: "Số lượng",
                                    value: item.quantity.toString(),
                                  ),
                                  const SizedBox(height: 8),
                                  FutureBuilder<String?>(
                                    future: colorVM.fetchColorName(
                                      item.colorId,
                                    ),
                                    builder: (context, snapshot) {
                                      return _buildDetailRow(
                                        icon: Icons.color_lens,
                                        label: "Màu sắc",
                                        value:
                                            snapshot.data ?? "Không xác định",
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  FutureBuilder<String?>(
                                    future: sizeVM.getSizeNameById(item.sizeId),
                                    builder: (context, snapshot) {
                                      return _buildDetailRow(
                                        icon: Icons.straighten,
                                        label: "Kích thước",
                                        value:
                                            snapshot.data ?? "Không xác định",
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    icon: Icons.location_on,
                                    label: "Địa chỉ",
                                    value:
                                        item.parentOrder?.customerAddress ??
                                        'N/A',
                                  ),
                                  const SizedBox(height: 8),
                                  
                                    _buildDetailRow(
                                    icon: Icons.description,
                                    label: " Lý do từ chối đơn hàng",
                                    value:
                                        item.parentOrder?.cancellationReason ??
                                        'N/A',
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
