import 'package:fashion_app/data/models/employeerole_model.dart';
import 'package:fashion_app/data/models/shop_model.dart';
import 'package:fashion_app/data/repositories/employeerole_repositories.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/views/shop/shop_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestLogin extends StatelessWidget {
  const TestLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopViewModel(),
      child: const _RegisterShopForm(),
    );
  }
}

class _RegisterShopForm extends StatefulWidget {
  const _RegisterShopForm();

  @override
  State<_RegisterShopForm> createState() => _RegisterShopFormState();
}

class _RegisterShopFormState extends State<_RegisterShopForm> {
  final shopNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký Shop")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: shopNameController,
              decoration: const InputDecoration(labelText: "Tên Shop"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Số điện thoại"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Địa chỉ Shop"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email quản lý"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Mật khẩu quản lý"),
              obscureText: true,
            ),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(labelText: "Nhập lại mật khẩu"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
                 (vm.isLoading || _isSubmitting)
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      // basic validation
                      if (passwordController.text != confirmController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Mật khẩu không khớp")),
                        );
                        return;
                      }

                      final email = emailController.text.trim();
                      final password = passwordController.text;
                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập email và mật khẩu")),
                        );
                        return;
                      }

                      try {
                        setState(() {
                          _isSubmitting = true;
                        });

                        // Create Firebase Auth user
                        final userCred = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: email, password: password);

                        final uid = userCred.user?.uid ?? '';

                        final newShop = ShopModel(
                          shopId: '',
                          userId: uid,
                          shopName: shopNameController.text.trim(),
                          phoneNumber: int.tryParse(phoneController.text),
                          address: addressController.text.trim(),
                          activityStatusId: "active",
                          ownerEmail: email,
                        );

                        final created = await vm.createAndAddShop(newShop);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đăng ký shop thành công: ${created?.shopId ?? ''}')),
                        );

                        // clear form
                        shopNameController.clear();
                        phoneController.clear();
                        addressController.clear();
                        emailController.clear();
                        passwordController.clear();
                        
                        confirmController.clear();

                        await Future.delayed(const Duration(milliseconds: 800));

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShopScreen(),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Auth lỗi: ${e.message}')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: $e')),
                        );
                      } finally {
                        setState(() {
                          _isSubmitting = false;
                        });
                      }
                    },
                    child: const Text("Đăng ký Shop"),
                  ),
                  const SizedBox(height: 20), 
                ElevatedButton(onPressed: ()async{
                  final repo = EmployeeroleRepositories();
                  await repo.addSampleRoles();
                }, child: const Text("Quay lại đăng nhập"))
          ],
        ),
      ),
    );
  }
}
