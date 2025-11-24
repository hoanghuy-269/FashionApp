import 'package:fashion_app/views/admin/admin_home_screen.dart';
import 'package:fashion_app/views/login/staff_screen.dart';
import 'package:fashion_app/views/staff/cashier.dart';
import 'package:fashion_app/views/staff/shipper/shipper_screen.dart';
import 'package:fashion_app/views/staff/warehousemanagement/warehouse_screen.dart';
import 'package:fashion_app/views/user/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/login_screen.dart';
import '../user/userprofile_screen.dart';
import '../shop/shop_screen.dart';
import '../admin/admindetailrequestshop_dialog.dart';
import '../admin/adminrequestshop_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // 🔹 Hàm lấy role theo uid
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    final firestore = FirebaseFirestore.instance;

    // 1️⃣ Kiểm tra trong "users"
    final userDoc = await firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return {'roleId': userDoc['roleId'], 'source': 'users', 'id': userDoc.id};
    }

    // 2️⃣ Nếu không có trong users → kiểm tra trong collectionGroup("staff")
    final staffQuery =
        await firestore
            .collectionGroup('staff')
            .where('employeeId', isEqualTo: uid)
            .limit(1)
            .get();

    if (staffQuery.docs.isNotEmpty) {
      final staffDoc = staffQuery.docs.first;
      final data = staffDoc.data();
      return {
        'roleId': data['roleIds'], // Lưu ý: roleIds có thể là List
        'source': 'staff',
        'id': staffDoc.id,
        'shopId': data['shopId'],
        'staffData': data, // Thêm toàn bộ data staff để sử dụng
      };
    }

    return null; // không tìm thấy
  }

  // 🔹 Hàm xử lý chuyển hướng cho staff
  Widget _handleStaffNavigation(Map<String, dynamic> data) {
    final roleIds = data['roleId'];
    final shopId = data['shopId'];
    final staffId = data['id'];
    final staffData = data['staffData'];

    // Kiểm tra nếu roleIds là List và chứa role cụ thể
    if (roleIds is List) {
      if (roleIds.contains('R01')) {
        // Role R01: Shipper
        return ShipperScreen(shopID: shopId, staffID: staffId);
      } else if (roleIds.contains('R02')) {
        // Role R02: Cashier
        return Cashier(shopID: shopId, staffID: staffId);
      } else if (roleIds.contains('R03')) {
        // Role R03: Warehouse
        return WarehouseScreen(shopID: shopId, staffID: staffId);
      }
    }
    // Fallback nếu roleIds là String
    else if (roleIds is String) {
      if (roleIds == 'R01') {
        return ShipperScreen(shopID: shopId, staffID: staffId);
      } else if (roleIds == 'R02') {
        return Cashier(shopID: shopId, staffID: staffId);
      } else if (roleIds == 'R03') {
        return WarehouseScreen(shopID: shopId, staffID: staffId);
      }
    }

    // Nếu không có role phù hợp
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) return const LoginScreen();

        return FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(user.uid),
          builder: (context, userDataSnapshot) {
            if (userDataSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userDataSnapshot.hasError) {
              print('Lỗi khi lấy user data: ${userDataSnapshot.error}');
              return const LoginScreen();
            }

            final data = userDataSnapshot.data;
            if (data == null) {
              return const LoginScreen();
            }

            final role = data['roleId'];
            final source = data['source'];

            //  Điều hướng dựa theo role
            if (source == 'staff') {
              return _handleStaffNavigation(data);
            } else {
              // Xử lý các role khác
              switch (role) {
                case 'role001': // Admin
                  return const AdminHomeScreen();
                case 'role002': // User (Khách hàng)
                  return HomeScreen(idUser: user.uid);
                case 'role003': // Chủ shop
                  return ShopScreen(idUser: user.uid);
                default:
                  return const LoginScreen();
              }
            }
          },
        );
      },
    );
  }
}
