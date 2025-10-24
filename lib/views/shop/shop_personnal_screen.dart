import 'package:another_flushbar/flushbar.dart';
import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/viewmodels/employeerole_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/shop/shop_addpersonal_screen.dart';
import 'package:fashion_app/views/shop/shop_updatepersonnal_screen.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      final roleVm = _roleVm ?? Provider.of<EmployeeRoleViewmodel>(context, listen: false);
      await roleVm.fetchRoles().catchError((e, st) {
        debugPrint(' Role error: $e\n$st');
      });

      final shopVm = _shopVm ?? Provider.of<ShopViewModel>(context, listen: false);
      final shopId = shopVm.currentShop?.shopId;
      if (shopId != null && shopId.isNotEmpty) {
        final staffVm = _staffVm ?? Provider.of<StorestaffViewmodel>(context, listen: false);
        staffVm.fetchStaffsByShop(shopId).catchError((e, st) {
          debugPrint(' Staff error: $e\n$st');
        });
      } else {
        debugPrint(' shopId is null or empty');
      }
    } catch (e, st) {
      debugPrint(' Load data error: $e\n$st');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roleVm = Provider.of<EmployeeRoleViewmodel>(context, listen: false);
    _staffVm = Provider.of<StorestaffViewmodel>(context, listen: false);
    _shopVm = Provider.of<ShopViewModel>(context, listen: false);
  }

  String _getRoleName(BuildContext context, String roleId) {
    if (!mounted) return '';
    final roleVm = Provider.of<EmployeeRoleViewmodel>(context, listen: false);
    return roleVm.getRoleName(roleId, fallback: 'Chưa xác định');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          "Quản lí nhân viên",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => const ShopAddemployCreen(),
              );
            },
            icon: const Icon(Icons.add),
            color: Colors.black,
            iconSize: 30,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Search 
              _buildSearchBar(),

              //  số lượng nhân viên
              _buildStaffHeader(),

              //  Danh sách nhân viên
              Expanded(child: _buildStaffList()),
            ],
          ),
        ),
      ),
    );
  }

  //  Search bar với check loading
  Widget _buildSearchBar() {
    return Consumer<StorestaffViewmodel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: TextField(
            enabled: !vm.isLoading, //  Disable khi đang loading
            onChanged: (value) {
              //  Chỉ search khi không loading và có data
              if (!vm.isLoading && vm.staffs.isNotEmpty) {
                vm.searchStaff(value);
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.search),
              hintText: vm.isLoading 
                  ? "Đang tải dữ liệu..." 
                  : "Tìm kiếm nhân viên ...",
              filled: true,
              fillColor: Colors.grey.shade300,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
    );
  }

  //  Header hiển thị số nhân viên
  Widget _buildStaffHeader() {
    return Consumer<StorestaffViewmodel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Tổng nhân viên: ${vm.filteredStaffs.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  //  Danh sách nhân viên với loading state
  Widget _buildStaffList() {
    return Consumer<StorestaffViewmodel>(
      builder: (context, vm, _) {
        //  Loading state
        if (vm.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        //  Empty state
        if (vm.filteredStaffs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có nhân viên',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        //  List view
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: vm.filteredStaffs.length,
          itemBuilder: (context, index) {
            final staff = vm.filteredStaffs[index];
            return _buildStaffCard(staff);
          },
        );
      },
    );
  }

  //  Staff card
  Widget _buildStaffCard(dynamic staff) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(
            Icons.person,
            color: Colors.blue,
          ),
        ),
        title: Text(
          staff.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Chức vụ: ${_getRoleName(context, staff.roleIds)}',
        ),
        trailing: _buildStaffMenu(staff),
      ),
    );
  }

  //  Menu popup cho staff
  Widget _buildStaffMenu(dynamic staff) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreHorizontal),
      onSelected: (value) {
        if (value == 'edit') {
          _showEditDialog(staff);
        } else if (value == 'delete') {
          _showDeleteDialog(staff);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  //  Show edit dialog
  void _showEditDialog(dynamic staff) {
    showDialog(
      context: context,
      builder: (_) => ShopUpdatestaffScreen(staffToEdit: staff),
    );
  }

  //  Show delete confirmation dialog
  void _showDeleteDialog(dynamic staff) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa nhân viên "${staff.fullName}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => _handleDelete(dialogContext, staff),
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext dialogContext, dynamic staff) async {
    Navigator.pop(dialogContext); 

    try {
      final staffVm = Provider.of<StorestaffViewmodel>(context, listen: false);
      await staffVm.deleteStaff(staff.employeeId);

      if (!mounted) return;
      context.showSuccess("Xóa nhân viên thành công");
    } catch (e) {
      if (!mounted) return;
      debugPrint(' Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
