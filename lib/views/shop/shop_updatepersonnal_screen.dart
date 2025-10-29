import 'dart:io';
import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/data/models/storestaff_model.dart';
import 'package:fashion_app/viewmodels/employeerole_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ShopUpdatestaffScreen extends StatefulWidget {
  const ShopUpdatestaffScreen({super.key, this.staffToEdit});

  final StorestaffModel? staffToEdit;

  @override
  State<ShopUpdatestaffScreen> createState() => _ShopUpdatestaffScreenState();
}

class _ShopUpdatestaffScreenState extends State<ShopUpdatestaffScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cccdController = TextEditingController();
  bool isLoading = false;
  String _selectedRole = "";
  File? _frontID;
  File? _backID;

  bool get _isEditing => widget.staffToEdit != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadRoles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cccdController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final staff = widget.staffToEdit;
    if (staff != null) {
      _nameController.text = staff.fullName;
      _emailController.text = staff.email;
      _cccdController.text = staff.nationalId ?? '';
      _selectedRole = staff.roleIds;
    }
  }

  void _loadRoles() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeRoleViewmodel>().fetchRoles();
    });
  }

  bool _validateEmployee() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _cccdController.text.trim().isEmpty) {
      context.showError('Vui lòng điền đầy đủ thông tin');
      return false;
    }

    if (!_hasValidImages()) {
      context.showError(
        'Vui lòng tải đầy đủ hình ảnh CCCD (mặt trước và mặt sau)',
      );
      return false;
    }

    if (_selectedRole.isEmpty) {
      context.showError('Vui lòng chọn chức vụ');
      return false;
    }

    return true;
  }

  bool _hasValidImages() {
    final hasFront =
        _frontID != null || widget.staffToEdit?.nationalIdFront != null;
    final hasBack =
        _backID != null || widget.staffToEdit?.nationalIdBack != null;
    return hasFront && hasBack;
  }

  Future<void> _pickImage(bool isFront) async {
    final image = await GalleryUtil.pickImageFromGallery();
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontID = image;
        } else {
          _backID = image;
        }
      });
    }
  }

 Future<void> _updateStaff() async {
  if (!_validateEmployee()) return;
  
  setState(() {
    isLoading = true;
  });

  final base = widget.staffToEdit;


  final model = StorestaffModel(
    employeeId: base!.employeeId, 
    shopId: base.shopId,
    fullName: _nameController.text.trim(),
    email: base.email, 
    nationalId: _cccdController.text.trim(),
    nationalIdFront: base.nationalIdFront,
    nationalIdBack: base.nationalIdBack,
    roleIds: _selectedRole,
    createdAt: base.createdAt, 
  );

  try {
    await context.read<StorestaffViewmodel>().updateStaff(
      model,
      front: _frontID,
      back: _backID,
    );
    
    if (!mounted) return;
    
    setState(() {
      isLoading = false;
    });
    
    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;
    setState(() {
      isLoading = false; 
    });
    context.showError('Lưu thất bại: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildInputField(
                    "Tên nhân viên",
                    _nameController,
                    hintText: "Nhập vào tên đầy đủ",
                    prefixIcon: Icons.person,
                  ),
                  _buildInputField(
                    "Email",
                    _emailController,
                    hintText: "Nhập vào email",
                    prefixIcon: Icons.email,
                  ),
                  _buildInputField(
                    'Căn cước công dân',
                    _cccdController,
                    hintText: 'Nhập vào 12 số CCCD',
                    prefixIcon: Icons.badge,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildImageSection(),
                  const SizedBox(height: 20),
                  _buildRoleSection(),
                ],
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
        
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: (){
            Navigator.of(context).pop();
          }, icon: const Icon(Icons.close, color: Colors.black, size: 24),),
          const SizedBox(width: 5),
          Text(
            "Cập nhật nhân viên",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: (){
              _updateStaff();
            },
            icon: const Icon(Icons.save, color: Colors.black, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildImageBox(
          "Mặt trước",
          file: _frontID,
          imageUrl: widget.staffToEdit?.nationalIdFront,
          onTap: () => _pickImage(true),
          onDelete: () => setState(() => _frontID = null),
        ),
        _buildImageBox(
          "Mặt sau",
          file: _backID,
          imageUrl: widget.staffToEdit?.nationalIdBack,
          onTap: () => _pickImage(false),
          onDelete: () => setState(() => _backID = null),
        ),
      ],
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chức vụ",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Consumer<EmployeeRoleViewmodel>(
            builder: (context, roleViewModel, _) {
              return Row(
                children:
                    roleViewModel.roles
                        .map(
                          (role) =>
                              _buildRoleOption(role.roleName, role.roleId),
                        )
                        .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildImageBox(
    String label, {
    File? file,
    String? imageUrl,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final hasImage = file != null || (imageUrl != null && imageUrl.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasImage ? Colors.blue.shade300 : Colors.grey.shade300,
            width: 1.3,
          ),
          color: Colors.white,
        ),
        child:
            hasImage
                ? _buildImageContent(label, file, imageUrl, onDelete)
                : _buildPlaceholder(label),
      ),
    );
  }

  Widget _buildImageContent(
    String label,
    File? file,
    String? imageUrl,
    VoidCallback onDelete,
  ) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                file != null
                    ? Image.file(file, fit: BoxFit.cover)
                    : Image.network(imageUrl!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: InkWell(
            onTap: onDelete,
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          left: 6,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo, color: Colors.grey, size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    String? hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              prefixIcon:
                  prefixIcon != null
                      ? Icon(prefixIcon, color: Colors.blue)
                      : null,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String roleName, String roleId) {
    final isSelected = _selectedRole == roleId;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = roleId),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Text(
          roleName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
