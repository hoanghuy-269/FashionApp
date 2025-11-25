import 'package:fashion_app/viewmodels/oder_item_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_request_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/shop/importgoods_screen.dart';
import 'package:fashion_app/views/shop/shop_order_management.dart';
import 'package:fashion_app/views/shop/shop_personnal_screen.dart';
import 'package:fashion_app/views/shop/shop_profile_screen.dart';
import 'package:fashion_app/views/shop/warehouse_management.dart';
import 'package:fashion_app/views/user/userprofile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shopVm = Provider.of<ShopViewModel>(context, listen: false);
      shopVm.loadStaffCount(widget.idShop ?? '');

      final shopProductVm = context.read<ShopProductViewModel>();
      await shopProductVm.feachShopProductsID(widget.idShop ?? '');

      final staffVM = context.read<StorestaffViewmodel>();
      await staffVM.fetchStaffsByShop(widget.idShop ?? '');
    });
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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShopProfileScreen()),
    );
  }

  void _navigateToPersonnel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShopPersonnalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildModernHeader()),

            // Revenue Card
            SliverToBoxAdapter(child: _buildModernRevenueSection()),

            // Features Grid
            SliverToBoxAdapter(child: _buildModernFeatureGrid()),

            SliverToBoxAdapter(child: const SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[600]!, Colors.blue[400]!],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildShopInfo()),
              Row(
                children: [
                  const SizedBox(width: 12),
                  _buildHeaderIconButton(
                    LucideIcons.logOut,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGreetingText(),
        ],
      ),
    );
  }

  Widget _buildShopInfo() {
    return Consumer<ShopViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return Row(
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Đang tải...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          );
        }

        final shop = vm.currentShop;
        return GestureDetector(
          onTap: _navigateToProfile,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      shop?.logo != null ? NetworkImage(shop!.logo!) : null,
                  child:
                      shop?.logo == null
                          ? Icon(Icons.store, color: Colors.blue[600], size: 28)
                          : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop?.shopName ?? 'Cửa hàng',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý cửa hàng',
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildGreetingText() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng! ☀️';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều! 🌤️';
    } else {
      greeting = 'Chào buổi tối! 🌙 ';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        greeting,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildModernRevenueSection() {
    final shopProductVm = context.watch<ShopProductViewModel>();
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu hôm nay',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C757D),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[500]!, Colors.blue[700]!],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.trendingUp,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng doanh thu',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatter.format(shopProductVm.totalPrice)} đ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFeatureGrid() {
    final shopID = context.read<ShopViewModel>().currentShop?.shopId ?? '';
    final staffID =
        context.read<StorestaffViewmodel>().currentStaff?.employeeId ?? '';
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý cửa hàng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.8,
            children: [
              Consumer<OrderItemViewModel>(
                builder: (context, orderVm, _) {
                  return StreamBuilder<int?>(
                    stream: orderVm.getTotalOrderItemsByShopStream(shopID),
                    builder: (context, snapshot) {
                      final totalOrders = snapshot.data ?? 0;
                      return _buildStatCard(
                        '$totalOrders',
                        "Đơn hàng",
                        LucideIcons.fileText,
                        Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => (ShopOrderManagement(
                                    shopID: shopID,
                                    staffID: staffID,
                                  )),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              Consumer<ShopProductViewModel>(
                builder: (context, shopVm, _) {
                  return StreamBuilder<int>(
                    stream: shopVm.getTotalProductsByShopStream(shopID),
                    builder: (context, snapshot) {
                      final totalProducts = snapshot.data ?? 0;
                      return _buildStatCard(
                        '$totalProducts',
                        "Kho hàng",
                        LucideIcons.warehouse,
                        Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const WarehouseManagementScreen(),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              Consumer<ShopProductRequestViewmodel>(
                builder: (context, requestVM, _) {
                  return StreamBuilder<int>(
                    stream: requestVM.getTotalProductRequestsByShopStream(
                      shopID,
                    ),
                    builder: (context, snapshot) {
                      final totalRequests = snapshot.data ?? 0;
                      return _buildStatCard(
                        '$totalRequests',
                        "Nhập hàng",
                        LucideIcons.packagePlus,
                        Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImportgoodsCreen(),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),

              Consumer<ShopViewModel>(
                builder: (context, shopVm, _) {
                  return _buildStatCard(
                    '${shopVm.staffCount}',
                    "Nhân viên",
                    LucideIcons.users,
                    Colors.purple,
                    onTap: _navigateToPersonnel,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shopViewModel = Provider.of<ShopViewModel>(context, listen: false);
    final userId = shopViewModel.currentShop?.userId;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Xác nhận đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
    );

    if (shouldLogout == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserprofileScreen(idUser: userId),
        ),
      );
    }
  }
}
