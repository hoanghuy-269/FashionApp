import 'package:fashion_app/core/location/provinceService.dart';
import 'package:fashion_app/data/models/location/district_model.dart';
import 'package:fashion_app/data/models/location/province_model.dart';
import 'package:fashion_app/data/models/location/ward_model.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/oder_item_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/login/login_screen.dart';
import 'package:fashion_app/views/staff/shipper/shipper_myoder_screen.dart';
import 'package:fashion_app/views/staff/shipper/view_oder_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShipperScreen extends StatefulWidget {
  final String shopID;
  final String staffID;

  const ShipperScreen({super.key, required this.shopID, required this.staffID});

  @override
  State<ShipperScreen> createState() => _ShipperScreenState();
}

class _ShipperScreenState extends State<ShipperScreen> {
  final Set<int> _expandedItems = {};

  // Filter states
  List<ProvinceModel> provinces = [];
  ProvinceModel? selectedProvince;
  District? selectedDistrict;
  WardModel? selectedWard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final staffVM = context.read<StorestaffViewmodel>();
      staffVM.fetchStaffById(widget.staffID);
      final orderItemVM = context.read<OrderItemViewModel>();
      orderItemVM.listenOrderItems(widget.shopID);
    });
    loadProvinces();
  }

  Future<void> loadProvinces() async {
    final data = await ProvinceService.getAllProvinces();
    setState(() {
      provinces = data;
    });
  }

List<dynamic> _filterAndSortItems(List<dynamic> items) {
  var filtered = items.where((item) => item.itemStatus == 'status_002').toList();

  filtered = filtered.where((item) {
    final address = item.parentOrder?.customerAddress?.toLowerCase() ?? '';

    bool matches = true;

    // Province
    if (selectedProvince != null) {
      matches &= address.contains(selectedProvince!.name.toLowerCase());
    }

    // District
    if (selectedDistrict != null) {
      matches &= address.contains(selectedDistrict!.name.toLowerCase());
    }

    // Ward
    if (selectedWard != null) {
      matches &= address.contains(selectedWard!.name.toLowerCase());
    }

    return matches;
  }).toList();

  return filtered;
}


  Future<void> _handleLogout() async {
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Đăng xuất"),
            content: const Text("Bạn có chắc muốn đăng xuất không?"),
            actions: [
              TextButton(
                child: const Text("Hủy"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Đăng xuất"),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = context.watch<StorestaffViewmodel>().currentStaff;
    final colorVM = context.watch<ColorsViewmodel>();
    final sizeVM = context.watch<SizesViewmodel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(
                          'assets/images/logo_person.png',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff?.fullName ?? 'Shipper',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Text(
                          //    staff?.employeeId ?? 'Mã nhân viên',
                          //   style: const TextStyle(
                          //     fontSize: 16,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ShipperMyoderScreen(
                                  shopID: widget.shopID,
                                  staffID: widget.staffID,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_shipping),
                      label: const Text("Đơn của tôi"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ViewOderScreen(
                                  shopID: widget.shopID,
                                  staffID: widget.staffID,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Xem đơn hàng "),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  DropdownButton<ProvinceModel>(
                    hint: const Text('Chọn Tỉnh/TP'),
                    isExpanded: true,
                    value: selectedProvince,
                    items:
                        provinces
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                    onChanged: (p) {
                      setState(() {
                        selectedProvince = p;
                        selectedDistrict = null;
                        selectedWard = null;
                      });
                    },
                  ),
                  if (selectedProvince != null)
                    DropdownButton<District>(
                      hint: const Text('Chọn Quận/Huyện'),
                      isExpanded: true,
                      value: selectedDistrict,
                      items:
                          selectedProvince!.districts
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d.name),
                                ),
                              )
                              .toList(),
                      onChanged: (d) {
                        setState(() {
                          selectedDistrict = d;
                          selectedWard = null;
                        });
                      },
                    ),
                  if (selectedDistrict != null)
                    DropdownButton<WardModel>(
                      hint: const Text('Chọn Phường/Xã'),
                      isExpanded: true,
                      value: selectedWard,
                      items:
                          selectedDistrict!.wards
                              .map(
                                (w) => DropdownMenuItem(
                                  value: w,
                                  child: Text(w.name),
                                ),
                              )
                              .toList(),
                      onChanged: (w) {
                        setState(() {
                          selectedWard = w;
                        });
                      },
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedProvince = null;
                              selectedDistrict = null;
                              selectedWard = null;
                            });
                          },
                          child: const Text("Đặt lại"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Order Items List
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

                  final filteredItems = _filterAndSortItems(vm.items);

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${item.totalPrice.toStringAsFixed(0)}đ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).primaryColor,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow(
                                        icon: Icons.shopping_bag,
                                        label: "Mã đơn hàng",
                                        value:
                                            item.parentOrder?.orderId ?? 'N/A',
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
                                                snapshot.data ??
                                                "Không xác định",
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
                                                snapshot.data ??
                                                "Không xác định",
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                try {
                                                  await vm
                                                      .updateOrderItemStatus(
                                                        item.orderItemId,
                                                        "status_003",
                                                      );
                                                  await vm.updateOrderShipper(
                                                    item.parentOrder?.orderId ??
                                                        '',
                                                    shipperId: widget.staffID,
                                                  );
                                                } catch (e) {
                                                  print("Lỗi khi nhận đơn: $e");
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.check_circle,
                                                size: 18,
                                              ),
                                              label: const Text('Nhận đơn'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                    ),
                                              ),
                                            ),
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
