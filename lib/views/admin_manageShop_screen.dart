import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminManageshopScreen extends StatefulWidget {
  const AdminManageshopScreen({super.key});

  @override
  State<AdminManageshopScreen> createState() => _AdminManageshopScreenState();
}

class _AdminManageshopScreenState extends State<AdminManageshopScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isDialogOpen = false; // 🔒 chốt chống mở nhiều dialog

  // Helper: mở dialog chỉ-1-lần
  Future<T?> _openDialogOnce<T>(Future<T?> Function() open) async {
    if (_isDialogOpen) return null;         // nếu đang mở -> bỏ qua
    _isDialogOpen = true;
    try {
      final res = await open();             // mở dialog
      return res;
    } finally {
      _isDialogOpen = false;                // đóng xong mới được mở lại
    }
  }

  // Fetch all shops from Firestore
  Future<List<Map<String, dynamic>>> fetchShops() async {
    final snapshot = await _firestore.collection('shops').get();
    return snapshot.docs.map((doc) {
      final m = doc.data();
      m['shopId'] = m['shopId'] ?? doc.id;  // đảm bảo có id
      return m;
    }).toList();
  }

  // Show shop details (1 lần duy nhất cho mỗi lần nhấn)
  Future<void> _viewShopDetailsDialog(String shopId) async {
    if (_isDialogOpen) return;
    await _openDialogOnce(() async {
      final shopSnapshot = await _firestore.collection('shops').doc(shopId).get();
      final shopData = shopSnapshot.data();
      if (shopData == null) return null;

      return showDialog(
        context: context,
        barrierDismissible: false, // tránh bấm nền để mở nhanh dialog khác
        builder: (context) => AlertDialog(
          title: const Text('Thông tin shop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tên Shop: ${shopData['shopName'] ?? '—'}'),
              Text('Số điện thoại: ${shopData['phoneNumber'] ?? '—'}'),
              Text('Địa chỉ: ${shopData['address'] ?? '—'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // đóng dialog hiện tại
                // đợi 1 tick để _isDialogOpen được reset trong finally
                await Future.delayed(const Duration(milliseconds: 10));
                _editShopDialog(shopId); // mở dialog chỉnh sửa (cũng được chốt 1 lần)
              },
              child: const Text('Chỉnh sửa'),
            ),
          ],
        ),
      );
    });
  }

  // Edit shop dialog (cũng khóa mở nhiều lần)
  Future<void> _editShopDialog(String shopId) async {
    if (_isDialogOpen) return;
    await _openDialogOnce(() async {
      final shopSnapshot = await _firestore.collection('shops').doc(shopId).get();
      final shopData = shopSnapshot.data();
      if (shopData == null) return null;

      final nameController = TextEditingController(text: shopData['shopName']);
      final phoneController = TextEditingController(text: shopData['phoneNumber'].toString());

      final addressController = TextEditingController(text: shopData['address']);

      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Chỉnh sửa thông tin shop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên Shop')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Địa chỉ')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            TextButton(
              onPressed: () async {
                await _firestore.collection('shops').doc(shopId).update({
                  'shopName': nameController.text.trim(),
                  'phoneNumber': phoneController.text.trim(),
                  'address': addressController.text.trim(),
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
                }
                if (context.mounted) Navigator.pop(context);
                setState(() {}); // refresh
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      );
    });
  }

  // Delete shop
  Future<void> _deleteShop(String shopId) async {
    await _firestore.collection('shops').doc(shopId).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop đã bị xóa')));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withOpacity(.08),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Quản lý shop', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchShops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi lấy dữ liệu'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có shop nào'));
          }

          final shops = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shops.length,
            itemBuilder: (_, index) {
              final shop = shops[index];
              final id = shop['shopId']?.toString() ?? '';
              return ShopCard(
                name: shop['shopName'] ?? 'Không có tên',
                code: id.isEmpty ? 'Không có mã' : id,
                onView: () => _viewShopDetailsDialog(id),
                onDelete: () => _deleteShop(id),
              );
            },
          );
        },
      ),
    );
  }
}

// ===== ITEM CARD =====
class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.name,
    required this.code,
    required this.onView,
    required this.onDelete,
  });

  final String name, code;
  final VoidCallback onView, onDelete;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8ECF2)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onView, // nhấn -> mở dialog (đã chốt 1 lần trong màn hình)
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16), bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.12),
                  child: Text(
                    name.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('Mã: $code', style: const TextStyle(fontSize: 12.5)),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Tùy chọn',
                  onSelected: (value) {
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [Icon(Icons.delete, size: 18), SizedBox(width: 8), Text('Xóa')]),
                    ),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.more_vert, color: Colors.black54, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension _Initials on String {
  String get initials {
    final p = trim().split(RegExp(r'\s+'));
    return (p.isEmpty ? 'S' : (p.first[0] + (p.length > 1 ? p.last[0] : ''))).toUpperCase();
  }
}
