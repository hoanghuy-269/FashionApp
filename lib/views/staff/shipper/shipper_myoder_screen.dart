import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/oder_item_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/staff/shipper/order_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ShipperMyoderScreen extends StatefulWidget {
  final String shopID;
  final String staffID;

  const ShipperMyoderScreen({
    super.key,
    required this.shopID,
    required this.staffID,
  });

  @override
  State<ShipperMyoderScreen> createState() => _ShipperMyoderScreenState();
}

class _ShipperMyoderScreenState extends State<ShipperMyoderScreen> {
  final Set<int> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final staffVM = context.read<StorestaffViewmodel>();
      staffVM.fetchStaffById(widget.staffID);
      final orderItemVM = context.read<OrderItemViewModel>();
      orderItemVM.listenOrderItems(widget.shopID);
    });
  }

  Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1 Kiểm tra GPS có bật chưa
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng bật GPS để sử dụng tính năng này.'),
        ),
      );
      return false;
    }

    // 2️ Kiểm tra quyền truy cập vị trí
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn đã từ chối quyền truy cập vị trí.'),
          ),
        );
        return false;
      }
    }

    // 3️ Nếu user từ chối vĩnh viễn
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng cấp quyền vị trí trong Cài đặt để tiếp tục.'),
        ),
      );
      return false;
    }

    return true; // Quyền OK
  }

  Future<void> goToDelivery(String address) async {
    if (!await handleLocationPermission(context)) return;

    try {
      // 1️1 Chuyển địa chỉ khách sang toạ độ
      final locations = await locationFromAddress(address);
      final destLat = locations.first.latitude;
      final destLng = locations.first.longitude;

      // 2️ Lấy vị trí hiện tại
      final pos = await Geolocator.getCurrentPosition();
      final currentLat = pos.latitude;
      final currentLng = pos.longitude;

      // 3️ Tạo URL Google Maps
      final Uri mapUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1"
        "&origin=$currentLat,$currentLng"
        "&destination=$destLat,$destLng"
        "&travelmode=driving",
      );

      // 4️ Mở Google Maps
      await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // gọi người dùng
  Future<void> opentPhone(String phone) async {
    final Uri phoneUrl = Uri(scheme: 'tel', path: phone);
    await launchUrl(phoneUrl, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorVM = context.watch<ColorsViewmodel>();
    final sizeVM = context.watch<SizesViewmodel>();
    final staffVM = context.watch<StorestaffViewmodel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: Column(
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
                    vm.items.where((item) {
                      return item.itemStatus == 'status_003';
                    }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Không tìm thấy đơn hàng ",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                }

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
                                child: Image.network(
                                  item.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    );
                                  },
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
                                        "${item.totalPrice.toStringAsFixed(0)}đ",
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
                                      future: sizeVM.getSizeNameById(
                                        item.sizeId,
                                      ),
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
                                    const SizedBox(height: 16),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () async {
                                                  await goToDelivery(
                                                    item
                                                            .parentOrder
                                                            ?.customerAddress ??
                                                        '',
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.delivery_dining,
                                                  size: 20,
                                                ),
                                                label: const Text(
                                                  'Đi giao hàng',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green.shade600,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  elevation: 3,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () async {
                                                  try {
                                                    await vm
                                                        .updateOrderItemStatus(
                                                          item.orderItemId,
                                                          "status_002",
                                                        );
                                                  } catch (e) {
                                                    print(
                                                      'Lỗi khi hủy đơn hàng: $e',
                                                    );
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.cancel,
                                                  size: 20,
                                                ),
                                                label: const Text('Hủy đơn'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red.shade600,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  elevation: 3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () async {
                                                  await opentPhone(
                                                    item
                                                            .parentOrder
                                                            ?.customerPhone ??
                                                        '',
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.phone,
                                                  size: 20,
                                                ),
                                                label: const Text('Gọi khách'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue.shade600,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  elevation: 3,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () async {
                                                  await showDialog<bool>(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => OrderConfirmationDialog(
                                                          oderitemID:
                                                              item.orderItemId,
                                                          staffID:
                                                              widget.staffID,
                                                          oderID:
                                                              item
                                                                  .parentOrder
                                                                  ?.orderId ??
                                                              '',
                                                        ),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.check_circle,
                                                  size: 20,
                                                ),
                                                label: const Text(
                                                  'Xác nhận đơn',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green.shade600,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  elevation: 3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
}
