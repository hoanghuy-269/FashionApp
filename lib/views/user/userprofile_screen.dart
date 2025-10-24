import 'package:fashion_app/data/models/User.dart';
import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/views/user/requesttoopentshop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserprofileScreen extends StatefulWidget {
    final String? idUser;

  const UserprofileScreen({super.key,  this.idUser});

 
  @override
  State<UserprofileScreen> createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneControler = TextEditingController();
  final TextEditingController addressControler = TextEditingController();
  String? requestStatus;
  late  AuthViewModel auth;
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;
  bool _hasLoadedData = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      auth = AuthViewModel();
      loadUserData();
    }
  );
  }

  @override
  void dispose() {

    nameController.dispose();
    phoneControler.dispose();
    addressControler.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    // Tránh load nhiều lần
    if (_hasLoadedData) return;
    _hasLoadedData = true;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final id = widget.idUser;
      if (id == null || id.isEmpty) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        return;
      }

      final user = await auth.FetchUserById(id);

      if (!mounted) return;
      
      setState(() {
        if (user != null) {
          currentUser = user;
          nameController.text = user.name ?? '';
          if (user.phoneNumbers.isNotEmpty) {
            phoneControler.text = user.phoneNumbers[0];
          }
          if (user.addresses.isNotEmpty) {
            addressControler.text = user.addresses[0];
          }
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Lỗi khi lấy thông tin người dùng: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading state
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thông tin người dùng'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Avatar và button
                CircleAvatar(
                  radius: 60,
                  backgroundImage: const AssetImage(
                    'assets/images/logo_person.png',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () async {
                    // Xử lý đăng kí shop
                    print("Đăng kí shop :${widget.idUser}");
                    
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>
                      RequestToOpenStoreScreen(uid: currentUser?.id)
                    ));
                    
                    if(result == "pending"){
                      setState(() {
                        requestStatus = "pending";
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      requestStatus == "pending" ? Colors.grey : Colors.blue
                    ),
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Colors.blue),
                    ),
                  ),
                  child: Text(
                    requestStatus == "pending" ? "Yêu cầu đang chờ xử lí" : "Đăng kí shop",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if(currentUser?.roleId == "r3") ...[
                  ElevatedButton(onPressed: (){

                  },style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ), child: const Text("Chọn Shop",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  ))
                ],

                // Form fields
                _buildTextField(
                  label: "Email",
                  hintText: currentUser?.email ?? '',
                  icon: Icons.email_outlined,
                  enabled: false, // Email thường không cho edit
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  label: "Họ và tên",
                  controller: nameController,
                  hintText: currentUser?.name ?? '',
                  icon: Icons.person_2_outlined,
                ),
                const SizedBox(height: 16),
                
                _buildPhoneField(),
                const SizedBox(height: 16),
                
                _buildTextField(
                  label: "Địa chỉ",
                  controller: addressControler,
                  hintText: currentUser?.addresses.isNotEmpty == true 
                      ? currentUser!.addresses[0] 
                      : '',
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Hủy",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton(
                          onPressed: _updateUserInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Cập nhật",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? hintText,
    IconData? icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.blue)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Số điện thoại",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: phoneControler,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
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
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            hintText: currentUser?.phoneNumbers.isNotEmpty == true
                ? currentUser!.phoneNumbers[0]
                : '',
          ),
        ),
      ],
    );
  }

  Future<void> _updateUserInfo() async {
   
  }
}