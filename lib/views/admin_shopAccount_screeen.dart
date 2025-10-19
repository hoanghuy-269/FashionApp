import 'package:flutter/material.dart';

class AdminShopaccountScreeen extends StatefulWidget {
  const AdminShopaccountScreeen({super.key});
  @override
  State<AdminShopaccountScreeen> createState() => _AdminShopaccountScreeenState();
}

class _AdminShopaccountScreeenState extends State<AdminShopaccountScreeen> {
  final List<Map<String, String>> shopAccounts = [
    {'id': 'S001', 'name': 'user 1', 'phone': '0981234567'},
    {'id': 'S002', 'name': 'Shop Quần Áo B', 'phone': '0978765432'},
    {'id': 'S003', 'name': 'Shop Mỹ Phẩm C', 'phone': '0911223344'},
    {'id': 'S004', 'name': 'Shop Giày Dép D', 'phone': '0909876543'},
    {'id': 'S005', 'name': 'Shop Phụ Kiện E', 'phone': '0933445566'},
  ];

  // Danh sách tài khoản bị khóa
  List<Map<String, String>> lockedAccounts = [];

  // ===== Dialogs gọn =====
  Future<void> _confirmLock(Map<String, String> acc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Khóa tài khoản'),
        content: Text('Bạn có chắc muốn khóa tài khoản “${acc['name']}”?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Khóa')),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        lockedAccounts.add(acc); // Thêm tài khoản vào danh sách khóa
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã khóa “${acc['name']}”')));
    }
  }

  Future<void> _unlockAccount(Map<String, String> acc) async {
    setState(() {
      lockedAccounts.remove(acc); // Mở khóa tài khoản
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã mở khóa “${acc['name']}”')));
  }

  void _showLockedAccounts() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Tài khoản bị khóa'),
        content: lockedAccounts.isEmpty
            ? const Text('Không có tài khoản nào bị khóa.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: lockedAccounts.length,
                itemBuilder: (context, index) {
                  final acc = lockedAccounts[index];
                  return ListTile(
                    title: Text(acc['name']!),
                    subtitle: Text(acc['phone']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.lock_open),
                      onPressed: () => _unlockAccount(acc),
                    ),
                  );
                },
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
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
        title: Text('Quản lý tài khoản user',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: titleSize, letterSpacing: .2)),
        actions: [
          // Icon ổ khóa hiển thị danh sách tài khoản bị khóa
          IconButton(
            icon: const Icon(Icons.lock, color: Colors.black54),
            onPressed: _showLockedAccounts,
          ),
        ],
      ),
      body: ListView.builder(
        padding: context.pagePadding,
        itemCount: shopAccounts.length,
        itemBuilder: (_, i) => _AccountCard(
          data: shopAccounts[i],
          onLock: () => _confirmLock(shopAccounts[i]),
        ),
      ),
    );
  }
}

// ===== Item Card gọn mà pro =====
class _AccountCard extends StatefulWidget {
  const _AccountCard({required this.data, required this.onLock});
  final Map<String, String> data;
  final VoidCallback onLock;

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sx = context.sx;
    final name = widget.data['name'] ?? '';
    final id = widget.data['id'] ?? '';
    final phone = widget.data['phone'] ?? '';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(bottom: sx(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sx(16)),
          border: Border.all(color: const Color(0xFFE8ECF2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(_hover ? .08 : .04), blurRadius: sx(10), offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sx(14), vertical: sx(12)),
          child: Row(
            children: [
              // Viền nhấn trái
              Container(
                width: sx(5),
                height: sx(56),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(sx(16)),
                    bottomLeft: Radius.circular(sx(16)),
                  ),
                ),
              ),
              SizedBox(width: sx(12)),
              // Avatar initials
              CircleAvatar(
                radius: sx(22),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.12),
                child: Text(name.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: sx(14),
                      color: Theme.of(context).colorScheme.primary,
                    )),
              ),
              SizedBox(width: sx(12)),
              // Thông tin
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: sx(16)), overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: sx(8)),
                    Chip(
                      label: Text('ID: $id', style: TextStyle(fontSize: sx(12.5))),
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.symmetric(horizontal: sx(6)),
                    ),
                  ]),
                  SizedBox(height: sx(4)),
                  Row(children: [
                    Icon(Icons.phone_outlined, size: sx(16.5), color: Colors.black54),
                    SizedBox(width: sx(6)),
                    Expanded(child: Text(phone, style: TextStyle(fontSize: sx(13.5), color: Colors.black87))),
                  ]),
                ]),
              ),
              // Menu
              PopupMenuButton<String>(
                tooltip: 'Tùy chọn',
                onSelected: (v) => v == 'lock' ? widget.onLock() : null,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'lock', child: Row(children: [Icon(Icons.lock, size: 18), SizedBox(width: 8), Text('Khóa tài khoản')])),
                ],
                child: Padding(padding: EdgeInsets.all(sx(6)), child: Icon(Icons.more_vert, color: Colors.black54, size: sx(22))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Tiện ích rút gọn & responsive =====
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

extension _Initials on String {
  String get initials {
    final p = trim().split(RegExp(r'\s+'));
    final f = p.isNotEmpty ? p.first[0] : '';
    final l = p.length > 1 ? p.last[0] : '';
    return (f + l).toUpperCase();
  }
}
