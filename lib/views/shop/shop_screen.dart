import 'package:fashion_app/data/models/User.dart';
import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/views/shop/shop_personnal_screen.dart';
import 'package:fashion_app/views/shop/shop_profile_screen.dart';
import 'package:fashion_app/views/shop/storerevenue_detail_screen.dart';
import 'package:fashion_app/views/user/userprofile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ShopScreen extends StatefulWidget {
  final String? idUser;
  final String? idShop;

  const ShopScreen({super.key, this.idUser, this.idShop});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    _setupSystemUI();
    _loadShopData();
  }

  void _setupSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _loadShopData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final vm = Provider.of<ShopViewModel>(context, listen: false);

      try {
        await _fetchShopBasedOnParameters(vm);
      } catch (e) {
        debugPrint('Lỗi lấy thông tin cửa hàng: $e');
        if (mounted) {
          _showErrorMessage('Lỗi lấy thông tin cửa hàng: $e');
        }
      }
    });
  }

  Future<void> _fetchShopBasedOnParameters(ShopViewModel vm) async {
    if (widget.idShop != null && widget.idShop!.isNotEmpty) {
      if (vm.currentShop?.shopId != widget.idShop) {
        await vm.fetchShopById(widget.idShop!);
      }
    } else if (widget.idUser != null && widget.idUser!.isNotEmpty) {
      if (vm.currentShop?.userId != widget.idUser) {
        await vm.fetchShopByUserId(widget.idUser!);
      }
    } else {
      if (vm.currentShop == null) {
        await vm.fetchShopForCurrentUser();
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShopProfileScreen(),
      ),
    );
  }

  void _navigateToRevenue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StorerevenueDetailScreen(),
      ),
    );
  }

  void _navigateToPersonnel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShopPersonnalScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.015),
              _buildHeader(width),
              SizedBox(height: height * 0.03),
              _buildSectionTitle("Tạm tính hôm nay", width),
              SizedBox(height: height * 0.015),
              _buildRevenueCard(),
              SizedBox(height: height * 0.04),
              _buildSectionTitle("Quản lí cửa hàng", width),
              SizedBox(height: height * 0.02),
              _buildFeatureGrid(width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShopInfo(width),
        Row(
          children: [
            _buildNotificationIcon(width),
            SizedBox(width: width * 0.03),
            _buildLogOut(width),
          ],
        ),
      ],
    );
  }

  Widget _buildShopInfo(double width) {
    return Consumer<ShopViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return _buildLoadingShopInfo(width);
        }

        final shop = vm.currentShop;
        return Row(
          children: [
            _buildShopAvatar(shop?.logo, width),
            SizedBox(width: width * 0.03),
            Text(
              shop?.shopName ?? 'Cửa hàng',
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingShopInfo(double width) {
    return Row(
      children: [
        CircleAvatar(
          radius: width * 0.05,
          backgroundColor: Colors.grey.shade100,
          child: const Icon(Icons.person, color: Colors.blue),
        ),
        SizedBox(width: width * 0.03),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildShopAvatar(String? logoUrl, double width) {
    return GestureDetector(
      onTap: _navigateToProfile,
      child: CircleAvatar(
        radius: width * 0.05,
        backgroundColor: Colors.grey.shade100,
        backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
        child: logoUrl == null
            ? const Icon(Icons.person, color: Colors.blue)
            : null,
      ),
    );
  }

  Widget _buildNotificationIcon(double width) {
    return CircleAvatar(
      radius: width * 0.05,
      backgroundColor: Colors.blue.shade50,
      child: const Icon(Icons.notifications_none, color: Colors.blue),
    );
  }
 Widget _buildLogOut(double width) {
  final _shopViewModel = Provider.of<ShopViewModel>(context, listen: false);
  print("User ID: ${_shopViewModel.currentShop?.userId}");
  return GestureDetector(
    onTap: () async {
      final userId = _shopViewModel.currentShop?.userId;
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Đăng xuất'),
            ),
          ],
        ),
      );

      if (shouldProceed == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserprofileScreen(idUser: userId),
          ),
        );
      }
    },
    child: CircleAvatar(
      radius: width * 0.05,
      backgroundColor: Colors.blue.shade50,
      child: const Icon(Icons.logout, color: Colors.blue),
    ),
  );
}

  Widget _buildSectionTitle(String title, double width) {
    return Text(
      title,
      style: TextStyle(
        fontSize: width * 0.04,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildRevenueCard() {
    return GestureDetector(
      onTap: _navigateToRevenue,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Doanh thu hôm nay",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "5.200.000 ₫",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(double width) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: width * 0.02,
      mainAxisSpacing: width * 0.02,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildGridItem(
          "Đơn hàng",
          LucideIcons.fileText,
          Colors.orange,
          count: 1,
        ),
        _buildGridItem(
          "Đóng gói",
          LucideIcons.packageCheck,
          Colors.blue,
          count: 1,
        ),
        _buildGridItem(
          "Kho",
          LucideIcons.warehouse,
          Colors.green,
        ),
        _buildGridItem(
          "Thanh toán/Trả",
          LucideIcons.creditCard,
          Colors.purple,
        ),
        _buildGridItem(
          "Quản lí nhân viên",
          LucideIcons.users,
          const Color.fromARGB(255, 202, 141, 44),
          onTap: _navigateToPersonnel,
        ),
        _buildGridItem(
          "Thống kê",
          LucideIcons.barChart2,
          const Color.fromARGB(255, 128, 57, 141),
        ),
      ],
    );
  }

  Widget _buildGridItem(
    String title,
    IconData icon,
    Color color, {
    int count = 0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGridIcon(icon, color, count),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridIcon(IconData icon, Color color, int count) {
    if (count > 0) {
      return Badge.count(
        count: count,
        backgroundColor: Colors.red,
        child: Icon(icon, color: color, size: 32),
      );
    }
    return Icon(icon, color: color, size: 24);
  }
}