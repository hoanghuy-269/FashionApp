import 'package:fashion_app/views/shop/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/data/models/shop_model.dart';

class ApprovedShopDialog extends StatefulWidget {
  final String userId;
  const ApprovedShopDialog({super.key, required this.userId});

  static Future<ShopModel?> show(BuildContext context, String userId) async {
    return showDialog<ShopModel?>(
      context: context,
      builder: (_) => ApprovedShopDialog(userId: userId),
    );
  }

  @override
  State<ApprovedShopDialog> createState() => _ApprovedShopDialogState();
}

class _ApprovedShopDialogState extends State<ApprovedShopDialog> {
  bool _isLoading = true;
  String? _error;
  List<ShopModel> _shops = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShops();
    });
  }

  Future<void> _loadShops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final requestVm = Provider.of<RequestToOpenShopViewModel>(
        context,
        listen: false,
      );
      final shopVm = Provider.of<ShopViewModel>(context, listen: false);

      final approvedRequests = await requestVm.fetchApprovedRequestsByUserId(
        widget.userId,
      );
      if (!mounted) return;

      if (approvedRequests == null || approvedRequests.isEmpty) {
        setState(() {
          _shops = [];
          _isLoading = false;
        });
        return;
      }

      final shopIds =
          approvedRequests
              .map((r) => r.shopId)
              .where((id) => id != null && id.isNotEmpty)
              .cast<String>()
              .toList();

      List<ShopModel> shops = [];

      if (shopIds.isNotEmpty) {
        final allUserShops = await shopVm.fetchShopsByUserId(widget.userId);
        print(' thong All user shops: $allUserShops');
        shops = allUserShops.where((s) => shopIds.contains(s.shopId)).toList();
        print("✅ Approved shops: $shops");
      }
      if (!mounted) return;
      setState(() {
        _shops = shops;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Lỗi khi tải danh sách shop: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn Shop đã được duyệt'),
      content: SizedBox(width: double.maxFinite, child: _buildContent()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Hủy'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadShops, child: const Text('Thử lại')),
        ],
      );
    }

    if (_shops.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('Bạn chưa có shop nào được duyệt.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _shops.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final shop = _shops[index];
        return ListTile(
          leading: const Icon(Icons.store),
          title: Text(shop.shopName),
          subtitle: Text(shop.address ?? ''),
          onTap: () {
            print("Selected shop: ${shop.shopId}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopScreen(idShop: shop.shopId),
              ),
            );
          },
        );
      },
    );
  }
}
