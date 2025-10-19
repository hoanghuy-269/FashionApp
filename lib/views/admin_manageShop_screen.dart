import 'package:flutter/material.dart';

class AdminManageshopScreen extends StatefulWidget {
  const AdminManageshopScreen({super.key});
  @override
  State<AdminManageshopScreen> createState() => _AdminManageshopScreenState();
}

class _AdminManageshopScreenState extends State<AdminManageshopScreen> {
  final List<Map<String, String>> shopList = [
    {'code': 'S001', 'name': 'Shop Hoa Tươi'},
    {'code': 'S002', 'name': 'Shop Quần Áo'},
    {'code': 'S003', 'name': 'Shop Mỹ Phẩm'},
    {'code': 'S004', 'name': 'Shop Điện Tử'},
    {'code': 'S005', 'name': 'Shop Đồ Ăn'},
  ];

  Future<void> _editDialog(int index) async {
    final s = shopList[index];
    final key = GlobalKey<FormState>();
    final codeCtl = TextEditingController(text: s['code']);
    final nameCtl = TextEditingController(text: s['name']);

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: key,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                _IconBadge(icon: Icons.store_mall_directory_outlined),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chỉnh sửa thông tin Shop',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Cập nhật mã và tên shop (mã nên viết hoa, ngắn gọn).',
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              TextFormField(
                controller: codeCtl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Mã Shop',
                  hintText: 'VD: S001',
                  prefixIcon: Icon(Icons.tag_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập mã'
                    : (!RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(v.trim()))
                        ? 'Chỉ cho phép chữ/số/gạch'
                        : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nameCtl,
                decoration: const InputDecoration(
                  labelText: 'Tên Shop',
                  hintText: 'VD: Shop Điện Tử',
                  prefixIcon: Icon(Icons.storefront_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                const SizedBox(width: 6),
                FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Lưu'),
                  onPressed: () {
                    if (!key.currentState!.validate()) return;
                    setState(() => shopList[index] = {
                          'code': codeCtl.text.trim().toUpperCase(),
                          'name': nameCtl.text.trim(),
                        });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
                  },
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa “${shopList[index]['name']}”?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => shopList.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa shop')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = context.sx(18);
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
        title: Text('Quản lý shop',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: titleSize, letterSpacing: .2)),
      ),
      body: ListView.builder(
        padding: context.pagePadding,
        itemCount: shopList.length,
        itemBuilder: (_, i) => ShopCard(
          name: shopList[i]['name']!,
          code: shopList[i]['code']!,
          onEdit: () => _editDialog(i),
          onDelete: () => _confirmDelete(i),
        ),
      ),
    );
  }
}

// ===== ITEM CARD =====
class ShopCard extends StatefulWidget {
  const ShopCard({super.key, required this.name, required this.code, required this.onEdit, required this.onDelete});
  final String name, code;
  final VoidCallback onEdit, onDelete;

  @override
  State<ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sx = context.sx;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: EdgeInsets.only(bottom: sx(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sx(16)),
          border: Border.all(color: const Color(0xFFE8ECF2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(_hover ? .08 : .04), blurRadius: sx(10), offset: const Offset(0, 4))
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(sx(16)),
          onTap: widget.onEdit,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sx(14), vertical: sx(12)),
            child: Row(
              children: [
                Container(
                  width: sx(5),
                  height: sx(56),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(sx(16)), bottomLeft: Radius.circular(sx(16))),
                  ),
                ),
                SizedBox(width: sx(12)),
                CircleAvatar(
                  radius: sx(22),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.12),
                  child: Text(widget.name.initials,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: sx(14),
                          color: Theme.of(context).colorScheme.primary)),
                ),
                SizedBox(width: sx(12)),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(widget.name,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: sx(16)),
                            overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(width: sx(8)),
                      Chip(
                        label: Text('Mã: ${widget.code}', style: TextStyle(fontSize: sx(12.5))),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.symmetric(horizontal: sx(6)),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Tùy chọn',
                  onSelected: (v) => v == 'edit' ? widget.onEdit() : widget.onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Chỉnh sửa')])),
                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18), SizedBox(width: 8), Text('Xóa')])),
                  ],
                  child: Padding(padding: EdgeInsets.all(sx(6)), child: Icon(Icons.more_vert, color: Colors.black54, size: sx(22))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Tiện ích =====
extension _CtxX on BuildContext {
  double get _w => MediaQuery.of(this).size.width;
  double sx(double base) {
    final factor = (_w / 390).clamp(0.85, 1.25);
    return base * ((_w >= 1024) ? 1.05 : 1.0) * factor;
  }

  EdgeInsets get pagePadding => _w >= 1024
      ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
      : _w >= 600
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      );
}

extension _Initials on String {
  String get initials {
    final p = trim().split(RegExp(r'\s+'));
    return (p.isEmpty ? 'S' : (p.first[0] + (p.length > 1 ? p.last[0] : ''))).toUpperCase();
  }
}
