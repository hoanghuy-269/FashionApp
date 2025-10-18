import 'package:flutter/material.dart';
import 'dart:math' as math;

class AdminConfirmScreen extends StatefulWidget {
  const AdminConfirmScreen({super.key});

  @override
  State<AdminConfirmScreen> createState() => _AdminConfirmScreenState();
}

class _AdminConfirmScreenState extends State<AdminConfirmScreen> {
  final List<Map<String, String>> requests = [
    {
      'id': 'U001',
      'name': 'Người dùng 1',
      'address': '123 Nguyễn Văn A, TP.HCM',
      'idCard': '0123456789',
      'phone': '0987654321',
      'time': '09:10',
    },
    {
      'id': 'U002',
      'name': 'Người dùng 2',
      'address': '456 Lê Lợi, Hà Nội',
      'idCard': '9876543210',
      'phone': '0911223344',
      'time': '09:10',
    },
    {
      'id': 'U003',
      'name': 'Người dùng 3',
      'address': '789 Phan Bội Châu, Đà Nẵng',
      'idCard': '1122334455',
      'phone': '0909009009',
      'time': '09:10',
    },
  ];

  // ===== Responsive helpers =====
  bool get _isDesktop {
    final w = MediaQuery.of(context).size.width;
    return w >= 1024;
  }

  bool get _isTablet {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1024;
  }

  double sx(double base) {
    // Scale theo chiều rộng, clamp để không bị quá to/nhỏ
    final w = MediaQuery.of(context).size.width;
    final factor = math.max(0.85, math.min(1.25, w / 390));
    // Desktop tăng nhẹ
    final deskBoost = _isDesktop ? 1.05 : 1.0;
    return base * factor * deskBoost;
  }

  EdgeInsets pagePadding() {
    if (_isDesktop) return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    if (_isTablet) return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    return const EdgeInsets.all(12);
    }

  Future<void> _confirmDecision({
    required String title,
    required String message,
    required VoidCallback onOk,
    String okText = 'Xác nhận',
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: Text(okText)),
        ],
      ),
    );
    if (ok == true) onOk();
  }

  void _handleApprove(int index) {
    final uid = requests[index]['id']!;
    _confirmDecision(
      title: 'Chấp nhận yêu cầu',
      message: 'Xác nhận duyệt yêu cầu của ${requests[index]['name']} (ID: $uid)?',
      okText: 'Duyệt',
      onOk: () {
        setState(() => requests.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã chấp nhận yêu cầu $uid')));
      },
    );
  }

  void _handleReject(int index) {
    final uid = requests[index]['id']!;
    _confirmDecision(
      title: 'Không chấp nhận',
      message: 'Bạn chắc chắn từ chối yêu cầu của ${requests[index]['name']} (ID: $uid)?',
      okText: 'Từ chối',
      onOk: () {
        setState(() => requests.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã từ chối yêu cầu $uid')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = sx(18);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withOpacity(.08),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Quay lại',
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_mall_directory_rounded, color: Colors.blue[700], size: sx(22)),
            const SizedBox(width: 8),
            Text(
              'Xác nhận lập shop',
              style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.w700,
                fontSize: titleSize,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),

      // Giữ nguyên vị trí: List trong body, nhưng canh giữa và giới hạn maxWidth
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = _isDesktop ? 980.0 : (_isTablet ? 820.0 : constraints.maxWidth);
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: ListView.builder(
                padding: pagePadding(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return _RequestCard(
                    sx: sx,
                    isTablet: _isTablet,
                    id: req['id']!,
                    name: req['name']!,
                    address: req['address']!,
                    idCard: req['idCard']!,
                    phone: req['phone']!,
                    time: req['time']!,
                    onApprove: () => _handleApprove(index),
                    onReject: () => _handleReject(index),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Card yêu cầu — responsive: font/đệm/icon co giãn theo kích thước.
/// Bố cục vẫn: icon trái | nội dung + nút | thời gian phải.
class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.sx,
    required this.isTablet,
    required this.id,
    required this.name,
    required this.address,
    required this.idCard,
    required this.phone,
    required this.time,
    required this.onApprove,
    required this.onReject,
  });

  final double Function(double) sx;
  final bool isTablet;
  final String id;
  final String name;
  final String address;
  final String idCard;
  final String phone;
  final String time;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final iconSize = sx(22);
    final titleSize = sx(15.5);
    final subSize = sx(14);
    final chipPadH = sx(6);
    final pad = EdgeInsets.all(sx(12));
    final gap = SizedBox(width: sx(12));
    final vGapSmall = SizedBox(height: sx(6));
    final vGapMed = SizedBox(height: sx(10));

    return Container(
      margin: EdgeInsets.only(bottom: sx(12)),
      padding: pad,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sx(16)),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: sx(10),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon trái
          Container(
            padding: EdgeInsets.all(sx(10)),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(sx(12)),
            ),
            child: Icon(Icons.person_outline, size: iconSize),
          ),
          gap,

          // Nội dung + nút
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dòng đầu: ID - Tên + Chip
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ID: $id — $name',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: titleSize),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: sx(8)),
                    Chip(
                      label: Text('Chờ duyệt', style: TextStyle(fontSize: sx(12.5))),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      padding: EdgeInsets.symmetric(horizontal: chipPadH),
                    ),
                  ],
                ),
                vGapSmall,
                _line(icon: Icons.place_outlined, text: address, size: subSize),
                _line(icon: Icons.badge_outlined, text: 'CCCD: $idCard', size: subSize),
                _line(icon: Icons.phone_outlined, text: 'SĐT: $phone', size: subSize),
                vGapMed,

                // Hành động: dùng Wrap để tự xuống dòng màn nhỏ (giữ vị trí dưới phần thông tin)
                Wrap(
                  spacing: sx(10),
                  runSpacing: sx(8),
                  children: [
                    FilledButton.icon(
                      onPressed: onApprove,
                      
                      label: Text('Chấp nhận', style: TextStyle(fontSize: sx(14))),
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 75, 133, 208),
                        padding: EdgeInsets.symmetric(
                          horizontal: sx(14),
                          vertical: sx(10),
                          
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sx(12))),
                      ),
                      
                    ),
                    OutlinedButton.icon(
                      onPressed: onReject,
                     
                      label: Text('Không chấp nhận', style: TextStyle(fontSize: sx(14))),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: sx(12),
                          vertical: sx(10),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sx(12))),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Thời gian phải (giữ nguyên vị trí)
          SizedBox(width: sx(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: sx(13),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line({required IconData icon, required String text, required double size}) {
    return Padding(
      padding: EdgeInsets.only(bottom: sx(2)),
      child: Row(
        children: [
          Icon(icon, size: sx(16.5), color: Colors.black54),
          SizedBox(width: sx(6)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: size, color: Colors.black87, height: 1.2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
