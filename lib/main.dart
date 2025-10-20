import 'package:fashion_app/viewmodels/employee_role_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/user/userprofile_screen.dart';
import 'package:fashion_app/views/admin_confirm_screen.dart';
import 'package:fashion_app/views/admin_home_screen.dart';
import 'package:fashion_app/views/admin_manageShop_screen.dart';
import 'package:fashion_app/views/admin_shopAccount_screeen.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/views/register_screen.dart';
import 'package:fashion_app/views/shop/shop_screen.dart';
import 'package:fashion_app/views/shop/test_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print(" đã kết nối thành công!");
  } catch (e) {
    print(" Lỗi kết nối Firebase: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShopViewModel()),
        ChangeNotifierProvider(create: (_) => StorestaffViewmodel()),
        ChangeNotifierProvider(create: (_) => EmployeeRoleViewmodel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(body: Center(child: TestLogin()));
    //return Scaffold(body: Center(child: AdminHomeScreen()));
  }
}
