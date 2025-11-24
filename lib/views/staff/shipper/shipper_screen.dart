import 'package:fashion_app/core/location/provinceService.dart';
import 'package:fashion_app/data/models/location/district_model.dart';
import 'package:fashion_app/data/models/location/province_model.dart';
import 'package:fashion_app/data/models/location/ward_model.dart';
import 'package:fashion_app/viewmodels/oder_item_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/login/login_screen.dart';
import 'package:fashion_app/views/staff/shipper/shipper_myoder_screen.dart';
import 'package:fashion_app/views/staff/shipper/view_oder_screen.dart';
import 'package:fashion_app/views/staff/shipper/widget_shipperscreen/shipper_screen_locationFillter.dart';
import 'package:fashion_app/views/staff/shipper/widget_shipperscreen/shipper_screen_oder_list.dart';
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
  List<ProvinceModel> provinces = [];
  ProvinceModel? selectedProvince;
  District? selectedDistrict;
  WardModel? selectedWard;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StorestaffViewmodel>().fetchStaffById(widget.staffID);
      context.read<OrderItemViewModel>().listenOrderItems(widget.shopID);
    });
    provinces = await ProvinceService.getAllProvinces();
    if (mounted) setState(() {});
  }

  List<dynamic> _filterItems(List<dynamic> items) {
    return items.where((item) {
      if (item.itemStatus != 'status_002') return false;

      final address = item.parentOrder?.customerAddress?.toLowerCase() ?? '';
      return (selectedProvince == null ||
              address.contains(selectedProvince!.name.toLowerCase())) &&
          (selectedDistrict == null ||
              address.contains(selectedDistrict!.name.toLowerCase())) &&
          (selectedWard == null ||
              address.contains(selectedWard!.name.toLowerCase()));
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      selectedProvince = null;
      selectedDistrict = null;
      selectedWard = null;
    });
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

  @override
  Widget build(BuildContext context) {
    final staff = context.watch<StorestaffViewmodel>().currentStaff;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _ShipperHeader(
              staffName: staff?.fullName ?? 'Shipper',
              onLogout: _handleLogout,
            ),
            _ActionButtons(shopID: widget.shopID, staffID: widget.staffID),
            ShipperScreenLocationfillter(
              provinces: provinces,
              selectedProvince: selectedProvince,
              selectedDistrict: selectedDistrict,
              selectedWard: selectedWard,
              onProvinceChanged:
                  (p) => setState(() {
                    selectedProvince = p;
                    selectedDistrict = null;
                    selectedWard = null;
                  }),
              onDistrictChanged:
                  (d) => setState(() {
                    selectedDistrict = d;
                    selectedWard = null;
                  }),
              onWardChanged: (w) => setState(() => selectedWard = w),
              onReset: _resetFilters,
            ),
            Expanded(
              child: ShipperScreenOderList(
                shopID: widget.shopID,
                staffID: widget.staffID,
                filterItems: _filterItems,
                expandedItems: _expandedItems,
                onToggleExpand: (index) {
                  setState(() {
                    _expandedItems.contains(index)
                        ? _expandedItems.remove(index)
                        : _expandedItems.add(index);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipperHeader extends StatelessWidget {
  final String staffName;
  final VoidCallback onLogout;

  const _ShipperHeader({required this.staffName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage('assets/images/logo_person.png'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staffName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Nhân viên giao hàng',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: onLogout,
            style: IconButton.styleFrom(backgroundColor: Colors.red[50]),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String shopID;
  final String staffID;

  const _ActionButtons({required this.shopID, required this.staffID});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.local_shipping,
              label: "Đơn của tôi",
              color: Colors.blue,
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ShipperMyoderScreen(
                            shopID: shopID,
                            staffID: staffID,
                          ),
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.qr_code_scanner,
              label: "Xem đơn hàng",
              color: Colors.green,
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              ViewOderScreen(shopID: shopID, staffID: staffID),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
