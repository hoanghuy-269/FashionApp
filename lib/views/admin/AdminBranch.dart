import 'dart:io';
import 'package:fashion_app/core/utils/pick_image_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fashion_app/viewmodels/brand_viewmodel.dart';
import 'package:fashion_app/data/models/brands_model.dart';

class BrandScreen extends StatelessWidget {
  const BrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrandViewmodel()..fetchAllBrands(),
      child: const _BrandScreenBody(),
    );
  }
}

//  Tách UI body riêng -> tránh lỗi Provider context
class _BrandScreenBody extends StatefulWidget {
  const _BrandScreenBody({super.key});
  
  @override
  State<_BrandScreenBody> createState() => _BrandScreenBodyState();
}

class _BrandScreenBodyState extends State<_BrandScreenBody> {  

  List<File> selectedImages = [];

  Future<void> _pickImages() async {
    final image = await showPickImageBottomSheet(context);
    if (image != null) {
      setState(() {
        selectedImages.add(image);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<BrandViewmodel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Brand"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),

      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.brands.isEmpty
              ? const Center(child: Text("Chưa có thương hiệu nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: vm.brands.length,
                  itemBuilder: (_, i) => brandItemCard(vm.brands[i], vm),
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddBrand(vm),
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add),
      ),
    );
  }

  //  CARD BRAND
  Widget brandItemCard(BrandsModel b, BrandViewmodel vm) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade200,
          foregroundImage: b.logoUrl.isNotEmpty ? NetworkImage(b.logoUrl) : null,
          child: b.logoUrl.isEmpty ? const Icon(Icons.image_not_supported) : null,
        ),
        title: Text(
          b.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Mã: ${b.brandID}"),
      
        onTap: () => showBrandDetail(b, vm),
      ),
    );
  }

  //  POPUP XEM CHI TIẾT
  void showBrandDetail(BrandsModel b, BrandViewmodel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Chi tiết: ${b.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (b.logoUrl.isNotEmpty)
             GestureDetector(
              child:  SizedBox(height: 120, child: Image.network(b.logoUrl)),
             ),
            const SizedBox(height: 8),
            Text("Mã Brand: ${b.brandID}"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Sửa", style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.pop(context);
              showEditBrand(b, vm);
            },
          ),
          TextButton(
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              confirmDeleteBrand(b, vm);
            },
          ),
          TextButton(
            child: const Text("Đóng"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  //  POPUP XÁC NHẬN XÓA
  void confirmDeleteBrand(BrandsModel b, BrandViewmodel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa thương hiệu"),
        content: Text("Bạn chắc chắn muốn xóa '${b.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              await vm.deleteBrand(b.brandID);
              Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  //  POPUP THÊM BRAND
  //  POPUP THÊM BRAND (không nhập URL, chỉ chọn ảnh)
void showAddBrand(BrandViewmodel vm) {
  final nameC = TextEditingController();
  File? pickedImage;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setStateSB) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Thêm Brand"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Tên brand")),
            
            const SizedBox(height: 12),

            //  Chọn ảnh
            GestureDetector(
              onTap: () async {
                final img = await showPickImageBottomSheet(context);
                if (img != null) {
                  setStateSB(() => pickedImage = img);
                }
              },
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: pickedImage == null
                    ? const Center(child: Text("Chọn logo"))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(pickedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy")),

          TextButton(
            child: const Text("Thêm", style: TextStyle(color: Colors.blue)),
            onPressed: () async {
              if (nameC.text.isEmpty) return;

              await vm.addBrandWithImage(
                nameC.text.trim(),
                pickedImage, // ✅ upload ảnh lên Firebase
              );

              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}


  //  POPUP SỬA BRAND
 //  POPUP SỬA BRAND — KHÔNG NHẬP URL, CHỌN ẢNH CẬP NHẬT LUÔN
void showEditBrand(BrandsModel b, BrandViewmodel vm) {
  final nameC = TextEditingController(text: b.name);
  File? newImageFile;

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text("Sửa Brand"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //  tên brand
              TextField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: "Tên brand")
              ),

              const SizedBox(height: 12),

              //  logo có thể bấm để chọn ảnh
              GestureDetector(
                onTap: () async {
                  File? picked = await showPickImageBottomSheet(context);
                  if (picked != null) {
                    setStateDialog(() {
                      newImageFile = picked;
                    });
                  }
                },
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                    image: newImageFile != null
                        ? DecorationImage(image: FileImage(newImageFile!), fit: BoxFit.cover)
                        : (b.logoUrl.isNotEmpty
                            ? DecorationImage(image: NetworkImage(b.logoUrl), fit: BoxFit.cover)
                            : null),
                  ),
                  child: (newImageFile == null && b.logoUrl.isEmpty)
                      ? const Center(child: Icon(Icons.image_not_supported))
                      : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                await vm.updateBrandWithImage(
                  b.brandID,
                  nameC.text.trim(),
                  newImageFile, // ✅ nếu có chọn ảnh sẽ upload
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
    },
  );
}
}
