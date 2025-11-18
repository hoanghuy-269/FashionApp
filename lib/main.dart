import 'package:fashion_app/core/utils/firebase_messaging.dart';
import 'package:fashion_app/data/models/User.dart';
import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/viewmodels/brand_viewmodel.dart';
import 'package:fashion_app/viewmodels/category_viewmodel.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/employeerole_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_size_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_viewmodel.dart';
import 'package:fashion_app/viewmodels/productdetail_viewmodel.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_request_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_productvariant_viewmodel.dart';
import 'package:fashion_app/viewmodels/role_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/views/admin/AdminBranch.dart';
import 'package:fashion_app/views/admin/adminrequestshop_screen.dart';
import 'package:fashion_app/views/admin/Admincategories.dart';
import 'package:fashion_app/views/login/auth_wrapper.dart';
import 'package:fashion_app/views/login/login_screen.dart';
import 'package:fashion_app/views/staff/shipper/shipper_screen.dart';
import 'package:fashion_app/views/user/home_screen.dart';
import 'package:fashion_app/views/user/product_detail.dart';
import 'package:fashion_app/views/user/userprofile_screen.dart';
import 'package:fashion_app/views/admin/admin_home_screen.dart';
import 'package:fashion_app/views/admin/admin_manageShop_screen.dart';
import 'package:fashion_app/views/admin/admin_shopAccount_screeen.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFirebaseMessaging();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShopViewModel()),
        ChangeNotifierProvider(create: (_) => StorestaffViewmodel()),
        ChangeNotifierProvider(create: (_) => EmployeeRoleViewmodel()),
        ChangeNotifierProvider(create: (_) => RequestToOpenShopViewModel()),
        Provider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BrandViewmodel()),
        ChangeNotifierProvider(create: (_) => ColorsViewmodel()),
        ChangeNotifierProvider(create: (_) => CategoryViewmodel()),
        ChangeNotifierProvider(create: (_) => SizesViewmodel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()),
        ChangeNotifierProvider(create: (_) => ShopProductViewModel()),
        ChangeNotifierProvider(create: (_) => ShopProductVariantViewModel()),
        ChangeNotifierProvider(create: (_) => ShopProductRequestViewmodel()),
        ChangeNotifierProvider(create: (_) => ProductSizeViewmodel()),
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
    return Scaffold(body: Center(child: AuthWrapper()));
  }
}
