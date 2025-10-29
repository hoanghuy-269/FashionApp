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
  late TabController _tabController;
  final RequestToOpenShopViewModel _requestVm = RequestToOpenShopViewModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _refresh() async {
    setState(() {}); // gọi lại FutureBuilder
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
          _buildRequestList('pending'),
          _buildRequestList('approved'),
          _buildRequestList('rejected'),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  leading: Icon(
                    Icons.storefront,
                    color: status == 'pending' ? Colors.blue : (status == 'approved' ? Colors.green : Colors.red),
                    size: 40,
                  ),
                  title: Text(
                    req.shopName ?? "Shop chưa đặt tên",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Người gửi: ${req.userId}"),
                  trailing: status == 'pending'
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => AdmindetailrequestshopDialog(requestId: req.requestId!),
                            );
                            if (!mounted) return;
                            if (result == 'approved') {
                              await _refresh();
                              _tabController.animateTo(1); // switch to 'Đã duyệt'
                            } else if (result == 'rejected') {
                              await _refresh();
                              _tabController.animateTo(2); // switch to 'Đã hủy'
                            } else {
                              await _refresh();
                            }
                          },
                          child: const Text('Chi tiết'),
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
