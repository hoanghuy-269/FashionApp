import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

extension StringExtension on String {
  String get initials {
    List<String> nameParts = this.split(' ');
    if (nameParts.isNotEmpty) {
      return nameParts.map((part) => part[0]).take(2).join().toUpperCase();
    }
    return '';
  }
}

Map<String, dynamic> _coerceMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  if (v is List && v.isNotEmpty && v.first is Map) {
    return Map<String, dynamic>.from(v.first as Map);
  }
  return <String, dynamic>{};
}

List<String> _coerceList(dynamic v) {
  if (v is List) return v.map((e) => (e ?? '').toString()).where((s) => s.isNotEmpty).toList();
  if (v is String && v.isNotEmpty) return [v];
  return <String>[];
}

class AdminShopaccountScreeen extends StatefulWidget {
  const AdminShopaccountScreeen({super.key});
  @override
  State<AdminShopaccountScreeen> createState() => _AdminShopaccountScreeenState();
}

class _AdminShopaccountScreeenState extends State<AdminShopaccountScreeen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();  // ✅ Thêm FocusNode
  String _searchTerm = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();  // ✅ Dispose FocusNode
    super.dispose();
  }

  // ✅ Helper method để dismiss keyboard an toàn
  void _dismissKeyboard() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
    FocusScope.of(context).unfocus();
  }

  // ✅ Delay sau khi dismiss keyboard để tránh conflict
  Future<void> _dismissKeyboardAndWait() async {
    _dismissKeyboard();
    await Future.delayed(const Duration(milliseconds: 150));
  }

  // Xử lý xác nhận khóa tài khoản
  Future<void> _confirmLock(Map<String, String> acc) async {
    await _dismissKeyboardAndWait();  // ✅ Dismiss keyboard trước
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,  // ✅ Tránh dismiss không mong muốn
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Khóa tài khoản'),
        content: Text('Bạn có chắc muốn khóa tài khoản "${acc['name']}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
            },
            child: const Text('Khóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (ok == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(acc['id']).update({
          'status': false,
          'lockedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã khóa tài khoản "${acc['name']}"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi khóa tài khoản: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hiển thị tài khoản bị khóa
  Future<void> _showLockedAccounts() async {
    await _dismissKeyboardAndWait();  // ✅ Dismiss keyboard trước
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: false)
          .get();
      
      if (!mounted) return;

      var docs = qs.docs;
      
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return StatefulBuilder(builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Text('Tài khoản bị khóa'),
              content: docs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Không có tài khoản nào bị khóa.'),
                    )
                  : SizedBox(
                      width: 420,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final raw = d.data();
                          final name = (raw['name'] ?? d.id).toString();
                          final phones = _coerceList(raw['phoneNumbers']);
                          final phone = phones.isNotEmpty ? phones.first : '';
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade100,
                              child: Icon(Icons.lock, color: Colors.red.shade700, size: 20),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(phone.isEmpty ? 'Không có SĐT' : phone),
                            trailing: IconButton(
                              icon: const Icon(Icons.lock_open, color: Colors.green),
                              tooltip: 'Mở khóa',
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(d.id)
                                      .update({
                                    'status': true,
                                    'unlockedAt': FieldValue.serverTimestamp(),
                                    'lockedAt': FieldValue.delete(),
                                  });
                                  
                                  setDialogState(() {
                                    docs = List.from(docs)..removeAt(i);
                                  });
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Đã mở khóa "$name"')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Lỗi khi mở khóa: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Đóng'),
                ),
              ],
            );
          });
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải danh sách bị khóa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots(includeMetadataChanges: true);
  }

  bool _matchesSearch(String id, String name, String term) {
    if (term.isEmpty) return true;
    final t = term.toLowerCase();
    return id.toLowerCase().contains(t) || name.toLowerCase().contains(t);
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = MediaQuery.of(context).size.width / 375;
    final pagePadding = EdgeInsets.all(16.0);

    return GestureDetector(
      // ✅ Tap vùng trống để dismiss keyboard
      onTap: () => _dismissKeyboard(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 4,
          shadowColor: Colors.black.withOpacity(.08),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () {
              _dismissKeyboard();
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Quản lý tài khoản user',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: titleSize * 18,
              letterSpacing: .2,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.lock, color: Colors.black54),
              tooltip: 'Tài khoản bị khóa',
              onPressed: _showLockedAccounts,
            ),
          ],
        ),
        body: Column(
          children: [
            // ✅ Modern Search Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên hoặc ID...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(14),
                    child: Icon(
                      Icons.search_rounded,
                      color: _searchFocusNode.hasFocus 
                          ? Theme.of(context).colorScheme.primary 
                          : Colors.grey.shade400,
                      size: 22,
                    ),
                  ),
                  suffixIcon: _searchTerm.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchTerm = '');
                              _dismissKeyboard();
                            },
                            splashRadius: 20,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade100,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (v) => setState(() => _searchTerm = v.trim()),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _dismissKeyboard(),
              ),
            ),
            
            // ✅ Search result count (optional)
            if (_searchTerm.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Đang tìm kiếm: "$_searchTerm"',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            
            // ✅ List with proper scroll behavior
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // ✅ Dismiss keyboard khi scroll
                  if (notification is ScrollStartNotification) {
                    if (_searchFocusNode.hasFocus) {
                      _dismissKeyboard();
                    }
                  }
                  return false;
                },
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _usersStream(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (_isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snap.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                              const SizedBox(height: 16),
                              Text('Lỗi Firestore: ${snap.error}'),
                            ],
                          ),
                        ),
                      );
                    }

                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      final isFromCache = snap.data?.metadata.isFromCache ?? false;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            isFromCache
                                ? 'Không có user trong cache (đang offline).'
                                : 'Chưa có user nào trong Firestore.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final visibleDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                    for (final d in docs) {
                      final raw = d.data();
                      final hasStatus = raw.containsKey('status');
                      final isLocked = hasStatus && raw['status'] == false;
                      if (isLocked) continue;

                      final addr = _coerceMap(raw['addresses']);
                      final name = (addr['name'] ?? raw['name'] ?? d.id).toString();

                      if (_matchesSearch(d.id, name, _searchTerm)) {
                        visibleDocs.add(d);
                      }
                    }

                    if (visibleDocs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                _searchTerm.isEmpty
                                    ? 'Không có user hiển thị (tất cả bị khóa).'
                                    : 'Không tìm thấy user phù hợp với "$_searchTerm"',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: pagePadding,
                      itemCount: visibleDocs.length,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,  // ✅ Auto dismiss khi drag
                      itemBuilder: (_, i) {
                        final d = visibleDocs[i];
                        final raw = d.data();

                        final addr = _coerceMap(raw['addresses']);
                        final name = (addr['name'] ?? raw['name'] ?? d.id).toString();
                        final email = (addr['email'] ?? raw['email'] ?? '').toString();
                        final loginMethodId = (addr['loginMethodId'] ?? raw['loginMethodId'] ?? '').toString();
                        final password = (addr['password'] ?? raw['password'] ?? '').toString();

                        final phones = _coerceList(raw['phoneNumbers']);
                        final phone = phones.isNotEmpty ? phones.first : '';

                        final user = <String, String>{
                          'id': d.id,
                          'name': name,
                          'email': email,
                          'phone': phone,
                          'loginMethodId': loginMethodId,
                          'password': password,
                        };

                        return _AccountCard(
                          data: user,
                          onLock: () => _confirmLock({'id': d.id, 'name': name, 'phone': phone}),
                          onDismissKeyboard: _dismissKeyboard,  // ✅ Pass callback
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatefulWidget {
  const _AccountCard({
    required this.data,
    required this.onLock,
    required this.onDismissKeyboard,  // ✅ Nhận callback
  });
  
  final Map<String, String> data;
  final VoidCallback onLock;
  final VoidCallback onDismissKeyboard;  // ✅ Callback để dismiss keyboard

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  bool _hover = false;

  Future<void> _showDetailDialog() async {
    widget.onDismissKeyboard();  // ✅ Dismiss keyboard
    await Future.delayed(const Duration(milliseconds: 150));  // ✅ Đợi keyboard đóng
    
    if (!mounted) return;
    
    final d = widget.data;
    
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Thông tin người dùng'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kv('Tên', d['name']),
              _kv('Gmail', d['email']),
              _kv('Số điện thoại', d['phone']),
              _kv('Phương thức đăng nhập', d['loginMethodId']),
              _kv('Mật khẩu', d['password']),
            ],
          ),
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
    final sx = MediaQuery.of(context).size.width / 375;
    final name = widget.data['name'] ?? '';
    final id = widget.data['id'] ?? '';
    final phone = widget.data['phone'] ?? '';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(bottom: sx * 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sx * 16),
          border: Border.all(color: const Color(0xFFE8ECF2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hover ? .08 : .04),
              blurRadius: sx * 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(sx * 16),
          onTap: _showDetailDialog,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sx * 14, vertical: sx * 12),
            child: Row(
              children: [
                Container(
                  width: sx * 5,
                  height: sx * 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(.9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(sx * 16),
                      bottomLeft: Radius.circular(sx * 16),
                    ),
                  ),
                ),
                SizedBox(width: sx * 12),
                CircleAvatar(
                  radius: sx * 22,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.12),
                  child: Text(
                    name.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: sx * 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: sx * 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: sx * 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: sx * 8),
                          Chip(
                            label: Text(
                              'ID: $id',
                              style: TextStyle(fontSize: sx * 12.5),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.symmetric(horizontal: sx * 6),
                          ),
                        ],
                      ),
                      SizedBox(height: sx * 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: sx * 16.5,
                            color: Colors.black54,
                          ),
                          SizedBox(width: sx * 6),
                          Expanded(
                            child: Text(
                              phone.isEmpty ? 'Không có SĐT' : phone,
                              style: TextStyle(
                                fontSize: sx * 13.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ✅ PopupMenuButton với dismiss keyboard
                PopupMenuButton<String>(
                  tooltip: 'Tùy chọn',
                  onOpened: () => widget.onDismissKeyboard(),  // ✅ Dismiss khi mở menu
                  onSelected: (v) {
                    if (v == 'lock') {
                      widget.onLock();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'lock',
                      child: Row(
                        children: [
                          Icon(Icons.lock, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Khóa tài khoản'),
                        ],
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: EdgeInsets.all(sx * 6),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.black54,
                      size: sx * 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String label, String? value) {
    final v = (value ?? '').isEmpty ? '—' : value!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}