import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserprofileScreen extends StatefulWidget {
  const UserprofileScreen({super.key});

  @override
  State<UserprofileScreen> createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneControler = TextEditingController();
  final TextEditingController addressControler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(
                        'assets/images/logo_person.png',
                      ),
                    ),
                    SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                        side: WidgetStateProperty.all(
                          BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: Text(
                        "đăng kí shop",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Họ và tên ",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: "Nhập họ và tên",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.person_2_outlined,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Số điện thoại",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: phoneControler,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // nhập Số
                              LengthLimitingTextInputFormatter(12), // giới hạn
                            ],
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  "assets/icons/vietnam.png",
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              hintText: "Hiển thị số điện thoại",
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Địa chỉ",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: addressControler,
                            decoration: const InputDecoration(
                              hintText: "hiển thị địa chỉ ",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
