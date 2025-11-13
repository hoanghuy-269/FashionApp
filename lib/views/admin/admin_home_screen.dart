
import 'package:fashion_app/views/admin/AdminBranch.dart';
import 'package:fashion_app/views/admin/Admincategories.dart';

import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/views/admin/admin_importgoods_screen.dart';

import 'package:fashion_app/views/admin/admin_manageShop_screen.dart';
import 'package:fashion_app/views/admin/adminrequestshop_screen.dart';
import 'package:fashion_app/views/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'admin_discount_screen.dart';
import 'admin_shopAccount_screeen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}


class _AdminHomeScreenState extends State<AdminHomeScreen> {

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authVM = AuthViewModel();
      await authVM.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600 && size.width <= 1024;
    final isDesktop = size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 48 : isTablet ? 24 : 16),
          child: Column(
            children: [
              // ---------------- HEADER ----------------
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : isTablet ? 24 : 16,
                  vertical: isDesktop ? 24 : isTablet ? 18 : 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: isTablet ? 28 : 24,
                      backgroundColor: Colors.teal,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: isTablet ? 32 : 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      iconSize: isTablet ? 30 : 26,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminrequestshopScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        size: isTablet ? 30 : 26,
                      ),
                      color: Colors.blueGrey[700],
                      onPressed: () {
                        _handleLogout();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---------------- DANH SÁCH CHỨC NĂNG (CUỘN) ----------------
              Expanded(
                child: ListView(
                  children: [
                    _buildGridItemFullWidth(
                      Icons.people_alt_rounded,
                      'Khách hàng',
                      Colors.teal,
                      const AdminShopaccountScreen(),
                    ),
                    SizedBox(height: isTablet ? 18 : 14),
                    _buildGridItemFullWidth(
                      Icons.manage_accounts_rounded,
                      'Quản lý shop',
                      Colors.deepPurple,
                      const AdminManageshopScreen(),
                    ),

                    SizedBox(height: isTablet ? 18 : 14),
                    _buildGridItemFullWidth(
                      Icons.local_offer_rounded,
                      'Mã giảm giá',
                      Colors.pinkAccent,
                      const AdminDiscountScreen(),
                    ),
                    SizedBox(height: isTablet ? 18 : 14),
                    _buildGridItemFullWidth(
                      Icons.branding_watermark,
                      'Hãng',
                      Colors.indigo,
                      const BrandScreen(),
                    ),
                    SizedBox(height: isTablet ? 18 : 14),
                    _buildGridItemFullWidth(
                      Icons.category,
                      'Danh mục',
                      Colors.blue,
                      const Categories(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  ),
                ],
              ),

              SizedBox(
                height:
                    isDesktop
                        ? 32
                        : isTablet
                        ? 24
                        : 20,
              ),

              // --- 3 ô chính, mỗi ô một dòng ---
              Expanded(
                child:
                    isDesktop
                        ? GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          children: [
                            _buildGridItemFullWidth(
                              Icons.people_alt_rounded,
                              'Khách hàng',
                              Colors.teal,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AdminShopaccountScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildGridItemFullWidth(
                              Icons.manage_accounts_rounded,
                              'Quản lý shop',
                              Colors.deepPurple,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AdminManageshopScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildGridItemFullWidth(
                              Icons.local_offer_rounded,
                              'Mã giảm giá',
                              Colors.pinkAccent,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AdminDiscountScreen(),
                                  ),
                                );
                              },
                            ),
                    
                          ],
                        )
                        : ListView(
                          children: [
                            _buildGridItemFullWidth(
                              Icons.people_alt_rounded,
                              'Khách hàng',
                              Colors.teal,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AdminShopaccountScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            _buildGridItemFullWidth(
                              Icons.manage_accounts_rounded,
                              'Quản lý shop',
                              Colors.deepPurple,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AdminManageshopScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            _buildGridItemFullWidth(
                              Icons.local_offer_rounded,
                              'Mã giảm giá',
                              Colors.pinkAccent,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AdminDiscountScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            _buildGridItemFullWidth(
                              Icons.local_offer_rounded,
                              'Quản lí sản phẩm',
                              Colors.pinkAccent,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AdminImportgoodsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatButton(
    String title,
    String value,
    bool isTablet,
    VoidCallback toggle,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,

                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ITEM CHỨC NĂNG GIỮ Y HỆT KÍCH THƯỚC BAN ĐẦU
  Widget _buildGridItemFullWidth(
    IconData icon,
    String title,
    Color color,
    Widget page,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        height: 120, //  giữ nguyên size ban đầu
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.18),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }
}
