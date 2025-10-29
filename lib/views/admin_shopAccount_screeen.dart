import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fashion_app/viewmodels/auth_viewmodel.dart';

class AdminShopaccountScreen extends StatefulWidget {
  const AdminShopaccountScreen({super.key});

  @override
  State<AdminShopaccountScreen> createState() => _AdminShopaccountScreenState();
}

class _AdminShopaccountScreenState extends State<AdminShopaccountScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  Future<void> _dismissKeyboardAndWait() async {
    _dismissKeyboard();
    await Future.delayed(const Duration(milliseconds: 150));
  }

  /// 🔹 Hiển thị chi tiết người dùng
  Future<void> _showUserDetails(
      Map<String, dynamic> userData, String userId, AuthViewModel viewModel) async {
    await _dismissKeyboardAndWait();
    if (!mounted) return;

    final phones = (userData['phoneNumbers'] as List?) ?? [];
    final name = userData['name'] ?? 'Không có tên';
    final email = userData['email'] ?? 'Không có email';
    final status = userData['status'] ?? true;
    final createdAt = userData['createdAt'];
    final address = userData['address'] ?? 'Chưa cập nhật';

    showDialog(
      context: context,
      builder: (context) {
        final isActive = status == true;
        final gradientColors = isActive
            ? [Colors.green.shade400, Colors.green.shade600]
            : [Colors.red.shade400, Colors.red.shade600];

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          isActive ? Icons.person : Icons.lock_person,
                          size: 48,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      _statusChip(isActive),
                    ],
                  ),
                ),

                // 🔹 Chi tiết người dùng
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _detailItem(Icons.badge_outlined, 'User ID', userId),
                      _detailItem(Icons.email_outlined, 'Email', email),
                      _detailItem(Icons.phone_outlined, 'Số điện thoại',
                          phones.isEmpty ? 'Chưa cập nhật' : phones.join(', ')),
                      _detailItem(Icons.location_on_outlined, 'Địa chỉ', address),
                      _detailItem(Icons.calendar_today_outlined, 'Ngày tạo',
                          createdAt != null ? _formatTimestamp(createdAt) : 'Không có'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (isActive)
              TextButton.icon(
                icon: const Icon(Icons.lock_outline, color: Colors.red),
                label: const Text('Khóa tài khoản', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                  _confirmLock({'id': userId, 'name': name}, viewModel);
                },
              ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
          ],
        );
      },
    );
  }

  Widget _statusChip(bool active) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? Icons.check_circle : Icons.lock,
                size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(active ? 'Hoạt động' : 'Đã khóa',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _detailItem(IconData icon, String title, String value) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ]),
            ),
          ],
        ),
      );

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final d = timestamp.toDate();
      return '${d.day}/${d.month}/${d.year}';
    }
    return 'Không có';
  }

  Future<void> _confirmLock(Map<String, String> acc, AuthViewModel vm) async {
    await _dismissKeyboardAndWait();
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Khóa tài khoản'),
        content: Text('Bạn có chắc muốn khóa tài khoản "${acc['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Khóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await vm.lockUser(acc['id']!);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Đã khóa tài khoản "${acc['name']}"'),
            backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Lỗi khi khóa: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        title: const Text('Quản lý tài khoản user',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock, color: Colors.black54),
            tooltip: 'Tài khoản bị khóa',
            onPressed: () => _showLockedAccounts(vm),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 🔍 Ô tìm kiếm
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên hoặc ID...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchTerm.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchTerm = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() => _searchTerm = v.trim()),
              ),

              const SizedBox(height: 10),

              // 📋 Danh sách người dùng
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: vm.usersStream(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting || vm.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snap.hasError) {
                      return Center(child: Text('Lỗi: ${snap.error}'));
                    }

                    final docs = snap.data?.docs ?? [];
                    final activeUsers = docs
                        .where((d) => (d.data() as Map<String, dynamic>)['status'] == true)
                        .toList();

                    final filtered = _searchTerm.isEmpty
                        ? activeUsers
                        : activeUsers.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final text = _searchTerm.toLowerCase();
                            return (data['name'] ?? '').toString().toLowerCase().contains(text) ||
                                (data['email'] ?? '').toString().toLowerCase().contains(text) ||
                                doc.id.toLowerCase().contains(text);
                          }).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text('Không tìm thấy kết quả phù hợp'));
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        final crossAxisCount = isWide ? 2 : 1;

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: isWide ? 4 : 3.6,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final doc = filtered[i];
                            final data = doc.data() as Map<String, dynamic>;
                            final phones = (data['phoneNumbers'] as List?) ?? [];
                            final phone =
                                phones.isNotEmpty ? phones.first : 'Không có SĐT';
                            final name = data['name'] ?? 'Không có tên';
                            final email = data['email'] ?? 'Không có email';

                            return InkWell(
                              onTap: () => _showUserDetails(data, doc.id, vm),
                              borderRadius: BorderRadius.circular(12),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: isTablet ? 34 : 28,
                                        backgroundColor: Colors.green.shade100,
                                        child: Icon(Icons.person,
                                            size: isTablet ? 34 : 26,
                                            color: Colors.green.shade700),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis),
                                            Text(email,
                                                style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 14)),
                                            Row(
                                              children: [
                                                const Icon(Icons.phone, size: 14),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(phone,
                                                      style: TextStyle(
                                                          color: Colors.grey.shade600,
                                                          fontSize: 13),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline,
                                            color: Colors.blueAccent),
                                        onPressed: () =>
                                            _showUserDetails(data, doc.id, vm),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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

  /// 🔹 Dialog xem danh sách tài khoản bị khóa (rút gọn version)
  Future<void> _showLockedAccounts(AuthViewModel vm) async {
    await _dismissKeyboardAndWait();
    if (!mounted) return;
    vm.isLoading = true;

    try {
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: false)
          .get();
      final docs = qs.docs;

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Tài khoản bị khóa (${docs.length})'),
          content: docs.isEmpty
              ? const Text('Không có tài khoản nào bị khóa.')
              : SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final d = docs[i];
                      final name = d['name'] ?? d.id;
                      return ListTile(
                        leading:
                            const Icon(Icons.lock, color: Colors.redAccent),
                        title: Text(name),
                        subtitle: Text(d['email'] ?? 'Không có email'),
                        trailing: IconButton(
                          icon: const Icon(Icons.lock_open, color: Colors.green),
                          onPressed: () async {
                            await vm.unlockUser(d.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Đã mở khóa "$name"'),
                                  backgroundColor: Colors.green),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))
          ],
        ),
      );
    } finally {
      vm.isLoading = false;
    }
  }
}
