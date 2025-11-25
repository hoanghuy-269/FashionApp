import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/viewmodels/employeerole_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/shop/shop_addpersonal_screen.dart';
import 'package:fashion_app/views/shop/shop_updatepersonnal_screen.dart';
import 'package:fashion_app/views/shop/widget/shop_personnal_cart.dart';
import 'package:fashion_app/views/shop/widget/shop_personnal_searchbar.dart';
import 'package:fashion_app/views/shop/widget/shop_personnal_stat_cart.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:provider/provider.dart';

class ShopPersonnalScreen extends StatefulWidget {
  const ShopPersonnalScreen({super.key});

  @override
  State<ShopPersonnalScreen> createState() => _ShopPersonnalScreenState();
}

class _ShopPersonnalScreenState extends State<ShopPersonnalScreen> {
  bool _hasInited = false;
  EmployeeRoleViewmodel? _roleVm;
  StorestaffViewmodel? _staffVm;
  ShopViewModel? _shopVm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasInited) return;
      _hasInited = true;
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roleVm = Provider.of<EmployeeRoleViewmodel>(context, listen: false);
    _staffVm = Provider.of<StorestaffViewmodel>(context, listen: false);
    _shopVm = Provider.of<ShopViewModel>(context, listen: false);
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      final roleVm = _roleVm ?? Provider.of<EmployeeRoleViewmodel>(context, listen: false);
      await roleVm.fetchRoles().catchError((e, st) {
        debugPrint('Role error: $e\n$st');
      });

      final shopVm = _shopVm ?? Provider.of<ShopViewModel>(context, listen: false);
      final shopId = shopVm.currentShop?.shopId;
      if (shopId != null && shopId.isNotEmpty) {
        final staffVm = _staffVm ?? Provider.of<StorestaffViewmodel>(context, listen: false);
        staffVm.fetchStaffsByShop(shopId).catchError((e, st) {
          debugPrint('Staff error: $e\n$st');
        });
      } else {
        debugPrint('shopId is null or empty');
      }
    } catch (e, st) {
      debugPrint('Load data error: $e\n$st');
    }
  }

  String _getRoleName(String roleId) {
    if (!mounted) return '';
    final roleVm = Provider.of<EmployeeRoleViewmodel>(context, listen: false);
    return roleVm.getRoleName(roleId);
  }

  void _showAddEmployeeDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => ShopAddemployCreen(shopId: _shopVm?.currentShop?.shopId),
    );
  }

  void _showEditDialog(dynamic staff) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ShopUpdatestaffScreen(staffToEdit: staff),
    );
  }

  void _showDeleteDialog(dynamic staff) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc muốn xóa nhân viên "${staff.fullName}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleDelete(dialogContext, staff),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext dialogContext, dynamic staff) async {
    Navigator.pop(dialogContext);

    try {
      final staffVm = Provider.of<StorestaffViewmodel>(context, listen: false);
      await staffVm.deleteStaff(staff.shopId, staff.employeeId);

      if (!mounted) return;
      context.showSuccess("Xóa nhân viên thành công");
    } catch (e) {
      if (!mounted) return;
      debugPrint('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa thất bại: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Quản lý nhân viên",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _showAddEmployeeDialog,
              icon: const Icon(Icons.add),
              color: Colors.white,
              tooltip: 'Thêm nhân viên',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            StaffSearchBar(),
            
            // Stats Card
            const StaffStatsCard(),
            
            // Staff List
            Expanded(child: _buildStaffList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffList() {
    return Consumer<StorestaffViewmodel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'Đang tải dữ liệu...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        if (vm.filteredStaffs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có nhân viên',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn nút + để thêm nhân viên mới',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          color: Colors.blue.shade600,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.filteredStaffs.length,
            itemBuilder: (context, index) {
              final staff = vm.filteredStaffs[index];
              return StaffCard(
                staff: staff,
                roleName: _getRoleName(staff.roleIds),
                onEdit: () => _showEditDialog(staff),
                onDelete: () => _showDeleteDialog(staff),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}