import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:fashion_app/views/admin/admindetailrequestshop_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';

class AdminrequestshopScreen extends StatefulWidget {
  const AdminrequestshopScreen({super.key});

  @override
  State<AdminrequestshopScreen> createState() => _AdminrequestshopScreenState();
}

class _AdminrequestshopScreenState extends State<AdminrequestshopScreen>
    with SingleTickerProviderStateMixin {
  // Constants
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_APPROVED = 'approved';
  static const String STATUS_REJECTED = 'rejected';

  // Tab indexes
  static const int TAB_APPROVED = 1;
  static const int TAB_REJECTED = 2;

  late TabController _tabController;
  final RequestToOpenShopViewModel _requestVm = RequestToOpenShopViewModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý yêu cầu mở shop'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Đã duyệt'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestList(STATUS_PENDING),
          _buildRequestList(STATUS_APPROVED),
          _buildRequestList(STATUS_REJECTED),
        ],
      ),
    );
  }

  Widget _buildRequestList(String status) {
    return FutureBuilder<List<RequesttoopentshopModel>>(
      future: _requestVm.fetchRequestsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(child: Text('Không có yêu cầu nào.'));
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(req.shopName),
                  subtitle: Text("Người gửi: ${req.userId}"),
                  trailing:
                      status == STATUS_PENDING
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  final result = await showDialog(
                                    context: context,
                                    builder:
                                        (context) =>
                                            AdmindetailrequestshopDialog(
                                              requestId: req.requestId,
                                            ),
                                  );
                                  if (!mounted) return;

                                  // Dùng constants thay vì string để tránh typo
                                  if (result == STATUS_APPROVED) {
                                    await _refresh();
                                    _tabController.animateTo(TAB_APPROVED);
                                  } else if (result == STATUS_REJECTED) {
                                    await _refresh();
                                    _tabController.animateTo(TAB_REJECTED);
                                  } else {
                                    await _refresh();
                                  }
                                },
                                child: const Text('Chi tiết'),
                              ),
                            ],
                          )
                          : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
