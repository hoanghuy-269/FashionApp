import 'package:fashion_app/viewmodels/rolestaff_viewmodel.dart';
import 'package:fashion_app/views/shop/shop_addpersonal_screen.dart';
import 'package:fashion_app/views/shop/shop_updatestaff_screen.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:fashion_app/viewmodels/shopstaff_viewmodel.dart';

class ShopPersonnalScreen extends StatefulWidget {
  const ShopPersonnalScreen({super.key});

  @override
  State<ShopPersonnalScreen> createState() => _ShopPersonnalScreenState();
}

class _ShopPersonnalScreenState extends State<ShopPersonnalScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final roleVm = Provider.of<RolestaffViewmodel>(context, listen: false);
      roleVm.fetchRoles().catchError((e, st) => debugPrint('role error $e\n$st'));

      final staffVm = Provider.of<ShopStaffViewmodel>(context, listen: false);
      final shopVm = Provider.of<ShopViewModel>(context, listen: false);
      final shopId = shopVm.currentShop?.shopId;
      if (shopId != null && shopId.isNotEmpty) {
        staffVm.fetchStaffsByShop(shopId).catchError((e, st) => debugPrint('staff error $e\n$st'));
      }
    });
  }

  String _getRoleName(BuildContext context, String roleId) {
    final roleVm = Provider.of<RolestaffViewmodel>(context, listen: false);
    
    if(!mounted) return '';
    return roleVm.getRoleName(roleId, fallback: 'Chưa xác định');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "Quản lí nhân viên ",
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
                builder: (_) => ShopAddemployCreen(),
              );
            },
            icon: Icon(Icons.add),
            color: Colors.black,
            iconSize: 30,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // thanh tìm kiếm
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),

                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(LucideIcons.search),
                    hintText: "Tìm kiếm nhân viên ...",
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Consumer<ShopStaffViewmodel>(
                builder: (context, vm, _) {
          final shopId = Provider.of<ShopViewModel>(context, listen: false).currentShop?.shopId ?? '';
          final staffinShop = vm.staffs.where((s) => s.shopId == shopId).toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Text(
                      'Tổng nhân viên: ${staffinShop.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),

              Expanded(
                child: Consumer<ShopStaffViewmodel>(
                  builder: (context, vm, _) {
                    if (vm.isLoading && vm.staffs.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (vm.staffs.isEmpty) {
                      return const Center(child: Text('Không có nhân viên'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: vm.staffs.length,
                      itemBuilder: (context, index) {
                        final staff = vm.staffs[index];
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
                              'Chức vụ : ${_getRoleName(context, staff.roleIds)}',
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(LucideIcons.moreHorizontal),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => ShopUpdatestaffScreen(
                                          staffToEdit: staff,
                                        ),
                                  );
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Xác nhận xóa'),
                                          content: Text(
                                            'Bạn có chắc muốn xóa nhân viên "${staff.fullName}" không?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Hủy'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                // close the dialog first
                                                Navigator.pop(context);
                                                try {
                                                  final staffVm = Provider.of<ShopStaffViewmodel>(context, listen: false);
                                                  await staffVm.deleteStaff(staff.employeeId);
                                                  if (!mounted) return;
                                                  // context.showSuccess('Xóa nhân viên thành công');
                                                } catch (e) {
                                                  if (!mounted) return;
                                                  // context.showError('Xóa thất bại: $e');
                                                }
                                              },
                                              child: const Text(
                                                'Xóa',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                              },
                              itemBuilder:
                                  (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Chỉnh sửa'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(' Xóa'),
                                    ),
                                  ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
