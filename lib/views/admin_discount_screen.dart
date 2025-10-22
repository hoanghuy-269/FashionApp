import 'package:fashion_app/viewmodels/admin_discount_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/voucher.dart';

class AdminDiscountScreen extends StatefulWidget {
  const AdminDiscountScreen({super.key});

  @override
  State<AdminDiscountScreen> createState() => _AdminDiscountScreenState();
}

class _AdminDiscountScreenState extends State<AdminDiscountScreen> {
  late final AdminDiscountViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = AdminDiscountViewModel();
    _initialize();
  }

  Future<void> _initialize() async {
    await _vm.init();
    await _vm.fetch();
    setState(() {});
  }

  Future<void> _openDiscountDialog({int? index, Voucher? discount}) async {
    final isEdit = index != null;
    final formKey = GlobalKey<FormState>();
    final codeCtl = TextEditingController(text: isEdit ? discount?.maVoucher : "");
    final nameCtl = TextEditingController(text: isEdit ? discount?.tenVoucher : "");
    final amountCtl = TextEditingController(text: isEdit ? discount?.soTien : "");
    final soLuongCtl = TextEditingController(text: isEdit ? discount?.soLuong?.toString() : "");

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? 'Sửa mã giảm giá' : 'Thêm mã giảm giá'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeCtl,
                decoration: const InputDecoration(
                    labelText: 'Mã', prefixIcon: Icon(Icons.confirmation_number_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mã' : null,
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: nameCtl,
                decoration: const InputDecoration(
                    labelText: 'Tên', prefixIcon: Icon(Icons.label_important_outline)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: amountCtl,
                decoration: const InputDecoration(
                    labelText: 'Số tiền', prefixIcon: Icon(Icons.sell_outlined)),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.%đĐ\s]'))],
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: soLuongCtl,
                decoration: const InputDecoration(
                    labelText: 'Số lượng', prefixIcon: Icon(Icons.format_list_numbered)),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final v = Voucher(
                voucherId: isEdit ? discount!.voucherId : 'new_id',
                shopId: isEdit ? discount!.shopId : 'S001',
                maVoucher: codeCtl.text.trim(),
                tenVoucher: nameCtl.text.trim(),
                soTien: amountCtl.text.trim(),
                soLuong: int.tryParse(soLuongCtl.text.trim()),
                daSuDung: 0,
                ngayBatDau: Timestamp.now(),
                ngayKetThuc: Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
                trangThaiVoucher: 'Đang hoạt động',
                trangThaiId: '1',
              );
              if (isEdit) {
                await _vm.update(discount!.voucherId, v);
              } else {
                await _vm.add(v);
              }
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: Text(isEdit ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Voucher v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa mã giảm giá'),
        content: Text('Bạn có chắc muốn xóa "${v.maVoucher}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _vm.delete(v.voucherId);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final vouchers = _vm.vouchers;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Quản lý mã giảm giá',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 78, 139, 223)),
                    onPressed: _openDiscountDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Danh sách
            Expanded(
              child: _vm.error != null
                  ? Center(child: Text('Lỗi: ${_vm.error}'))
                  : vouchers.isEmpty
                      ? const Center(child: Text('Không có mã giảm giá'))
                      : ListView.builder(
                          itemCount: vouchers.length,
                          itemBuilder: (context, i) {
                            final v = vouchers[i];
                            return DiscountCard(
                              isTablet: isTablet,
                              code: v.maVoucher,
                              name: v.tenVoucher,
                              amount: v.soTien ?? '',
                              isUsed: v.daSuDung == 1,
                              onEdit: () => _openDiscountDialog(index: i, discount: v),
                              onDelete: () => _confirmDelete(v),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscountCard extends StatelessWidget {
  final bool isTablet;
  final String code;
  final String name;
  final String amount;
  final bool isUsed;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DiscountCard({
    super.key,
    required this.isTablet,
    required this.code,
    required this.name,
    required this.amount,
    required this.isUsed,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  code,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 16 : 14,
                    color: const Color(0xFF274582),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: isTablet ? 16 : 14)),
                    const SizedBox(height: 6),
                    Text(amount,
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: isTablet ? 14 : 12)),
                    const SizedBox(height: 6),
                    Text(
                      isUsed ? 'Đã sử dụng' : 'Chưa sử dụng',
                      style: TextStyle(
                          color: isUsed ? Colors.green : Colors.red,
                          fontSize: isTablet ? 14 : 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Sửa',
                    icon: Icon(Icons.edit, color: Colors.green[700], size: isTablet ? 22 : 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Xóa',
                    icon:
                        Icon(Icons.delete_outline, color: Colors.red[700], size: isTablet ? 22 : 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
