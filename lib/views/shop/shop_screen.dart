import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/views/shop/shop_personnal_screen.dart';
import 'package:fashion_app/views/shop/shop_profile_screen.dart';
import 'package:fashion_app/views/shop/storerevenue_detail_screen.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = Provider.of<ShopViewModel>(context, listen: false);
      try {
        if (widget.idShop != null && widget.idShop!.isNotEmpty) {
          if (vm.currentShop == null || vm.currentShop?.shopId != widget.idShop) {
            await vm.fetchShopById(widget.idShop!);
          }
        } else if (widget.idUser != null && widget.idUser!.isNotEmpty) {
          
          if (vm.currentShop == null || vm.currentShop?.userId != widget.idUser) {
            await vm.fetchShopByUserId(widget.idUser!);
          }
        } else {
          if (vm.currentShop == null) {
            await vm.fetchShopForCurrentUser();
          }
        }
      } catch (e) {
        debugPrint('Lỗi lấy thông tin cửa hàng: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi lấy thông tin cửa hàng: $e')),
          );
        }
      }
    });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<ShopViewModel>(
                    builder: (context, vm, _) {
                      if (vm.isLoading) {
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: width * 0.05,
                              backgroundColor: Colors.grey.shade100,
                              child: const Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: width * 0.03),
                            const CircularProgressIndicator(),
                          ],
                        );
                      }
                      final shop = vm.currentShop;
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShopProfileScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: width * 0.05,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage:
                                  shop?.logo != null
                                      ? NetworkImage(shop!.logo!)
                                      : null,
                              child:
                                  shop?.logo == null
                                      ? const Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                      )
                                      : null,
                            ),
                          ),
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
                  ),

                  CircleAvatar(
                    radius: width * 0.05,
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(
                      Icons.notifications_none,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),

              Text(
                "Tạm tính hôm nay",
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: height * 0.015),
              _buildRevenueCard(),
              // danh sách các chức năng
              SizedBox(height: height * 0.04),
              Text(
                "Quản lí cửa hàng",
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: height * 0.02),

              GridView.count(
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
                  _buildGridItem("Kho", LucideIcons.warehouse, Colors.green),
                  _buildGridItem(
                    "Thanh toán/Trả",
                    LucideIcons.creditCard,
                    Colors.purple,
                  ),
                  _buildGridItem(
                    "Quản lí nhân viên ",
                    LucideIcons.users,
                    const Color.fromARGB(255, 202, 141, 44),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopPersonnalScreen(),
                        ),
                      );
                    },
                  ),
                  _buildGridItem(
                    "Thống kê",
                    LucideIcons.barChart2,
                    const Color.fromARGB(255, 128, 57, 141),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StorerevenueDetailScreen(),
          ),
        );
      },
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
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                count > 0
                    ? Badge.count(
                      count: count,
                      backgroundColor: Colors.red,
                      child: Icon(icon, color: color, size: 32),
                    )
                    : Icon(icon, color: color, size: 24),
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
}
