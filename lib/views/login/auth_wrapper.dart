import 'package:fashion_app/views/admin/admin_home_screen.dart';
import 'package:fashion_app/views/login/staff_screen.dart';
import 'package:fashion_app/views/staff/warehouse_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/login_screen.dart';
import '../user/userprofile_screen.dart';
import '../shop/shop_screen.dart';
import '../admin/admindetailrequestshop_dialog.dart';
import '../admin/adminrequestshop_screen.dart'; // nếu admin có màn khác

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
            .where(
              'employeeId',
              isEqualTo: uid,
            ) //  nên check theo employeeId, không phải documentId
            .limit(1)
            .get();

    if (staffQuery.docs.isNotEmpty) {
      final staffDoc = staffQuery.docs.first;
      final data = staffDoc.data();
      return {
        'roleId': data['roleIds'],
        'source': 'staff',
        'id': staffDoc.id,
        'shopId': data['shopId'],
      };
    }

    return null; // không tìm thấy
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

            final data = userDataSnapshot.data;
            if (data == null) {
              return const LoginScreen();
            }

            final role = data['roleId'];
            final source = data['source'];
            final shopId = data['shopId'];

            // ✅ Điều hướng dựa theo role
            switch (role) {
              case 'role001': // Admin
                return const AdminHomeScreen();
              case 'role002': // User (Khách hàng)
                return UserprofileScreen(idUser: user.uid);
              case 'role003': // Chủ shop
                return ShopScreen(idUser: user.uid);
              default:
                // Nếu là nhân viên (staff)
                if (source == 'staff') {
                  return WarehouseScreen();
                } else {
                  return const LoginScreen();
                }
            }
          },
        );
      },
    );
  }
}
