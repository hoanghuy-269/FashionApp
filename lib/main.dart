import 'package:fashion_app/views/shop/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget  {
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
  return Scaffold(
    body: Center(
      child: ShopHome(
      ),
    ),
  );
  }
}
