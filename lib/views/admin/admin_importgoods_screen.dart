import 'dart:collection';
import 'dart:io';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/core/utils/pick_image_bottom_sheet.dart';
import 'package:fashion_app/data/models/brands_model.dart';
import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/models/productsdetail_model.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/brand_viewmodel.dart';
import 'package:fashion_app/viewmodels/category_viewmodel.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_viewmodel.dart';
import 'package:fashion_app/viewmodels/productdetail_viewmodel.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildBranchDropdown.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildCategoryDropdown.dart';
import 'package:fashion_app/views/admin/buildsize.dart';
import 'package:fashion_app/views/admin/builldcolor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminImportgoodsScreen extends StatefulWidget {
  const AdminImportgoodsScreen({super.key});

  @override
  State<AdminImportgoodsScreen> createState() => _AdminImportgoodsScreenState();
}

class _AdminImportgoodsScreenState extends State<AdminImportgoodsScreen> {
  final nameController = TextEditingController();
  final importPriceController = TextEditingController();
  final descriptionController = TextEditingController();

  Map<String, File?> selectedImagesByColor = {};
  BrandsModel? selectedBrand;
  CategoryModel? selectedCategory;
  List<SizesModel> selectedSizes = [];
  List<ColorsModel> selectedColors = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BrandViewmodel>().fetchAllBrands();
      context.read<CategoryViewmodel>().fetchCategories();
      context.read<ColorsViewmodel>().fetchAllColors();
    });
  }

  Future<void> pickImageForColor(String colorID) async {
    final image = await showPickImageBottomSheet(context);
    if (image != null) {
      setState(() {
        selectedImagesByColor[colorID] = image;
      });
    }
  }

  Future<void> saveImportGoods() async {
    if (nameController.text.isEmpty ||
        selectedBrand == null ||
        selectedCategory == null ||
        selectedSizes.isEmpty ||
        selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Vui lòng nhập đầy đủ thông tin!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final newProduct = ProductsModel(
        productID: '',
        name: nameController.text,
        categoryID: selectedCategory!.categoryID,
        brandID: selectedBrand!.brandID,
        description: descriptionController.text,
      );

      final productId =
          await context.read<ProductViewModel>().addProduct(newProduct.toMap());
      for (final size in selectedSizes) {
        for (final color in selectedColors) {
              final imageFile = selectedImagesByColor[color.colorID]!;
          final imageUrl  = await GalleryUtil.uploadImageToFirebase(
            imageFile,
            folderName: 'products/$productId/${color.colorID}/${size.sizeID}',
          );

          if (imageUrl == null) {
            throw Exception('Lỗi tải lên hình ảnh cho màu ${color.name} và size ${size.name}');
          }


          final productDetail = ProductsdetailModel(
            productsDetailID: "",
            productID: productId,
            sizeID: size.sizeID,
            colorID: color.colorID,
            imageUrls: imageFile.path,
          );

          await context
              .read<ProductDetailViewModel>()
              .addProductDetail(productId, productDetail.toMap());
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Lưu sản phẩm thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); 
      Navigator.of(context).pop(); 
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' Lỗi khi lưu sản phẩm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandVM = context.watch<BrandViewmodel>();
    final categoryVM = context.watch<CategoryViewmodel>();
    final colorVM = context.watch<ColorsViewmodel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Thương hiệu
                    brandVM.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Buildbranchdropdown(
                            onBrandSelected: (b) =>
                                setState(() => selectedBrand = b),
                          ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      label: 'Tên sản phẩm',
                      controller: nameController,
                      icon: Icons.wallet,
                    ),
                    const SizedBox(height: 20),

                    // Danh mục
                    categoryVM.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Buildcategorydropdown(
                            onCategorySelected: (c) =>
                                setState(() => selectedCategory = c),
                          ),
                    const SizedBox(height: 20),

                    // Size
                    const Text('Chọn Size', style: TextStyle(fontSize: 16)),
                    brandVM.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Buildsize(
                            onSizeToggled: (s, sel) {
                              setState(() => sel
                                  ? selectedSizes.add(s)
                                  : selectedSizes
                                      .removeWhere((e) => e.sizeID == s.sizeID));
                            },
                          ),
                    const SizedBox(height: 20),

                    // Màu
                    const Text('Chọn Màu', style: TextStyle(fontSize: 16)),
                    colorVM.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Builldcolor(
                            onColorsSelected: (c) {
                              setState(() {
                                selectedColors = c;

                                // Cập nhật map ảnh cho từng màu
                                for (var color in selectedColors) {
                                  selectedImagesByColor.putIfAbsent(
                                      color.colorID, () => null);
                                }
                                selectedImagesByColor.removeWhere(
                                  (key, value) => !selectedColors
                                      .any((c) => c.colorID == key),
                                );
                              });
                            },
                          ),

                    const SizedBox(height: 20),

                    // --- Ảnh cho từng màu ---
                    if (selectedColors.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            ...selectedColors.map((color) {
                              final image = selectedImagesByColor[color.colorID];
                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(color.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () =>
                                            pickImageForColor(color.colorID),
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: image != null
                                                ? DecorationImage(
                                                    image: FileImage(image),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: image == null
                                              ? const Center(
                                                  child: Icon(Icons.add_a_photo,
                                                      size: 40, color: Colors.grey),
                                                )
                                              : Align(
                                                  alignment: Alignment.topRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(20),
                                                    child: GestureDetector(
                                                      onTap: () => setState(() =>
                                                          selectedImagesByColor[
                                                              color.colorID] = null),
                                                      child: const CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            Colors.black54,
                                                        child: Icon(Icons.close,
                                                            color: Colors.white,
                                                            size: 18),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                    const SizedBox(height: 20),
                    _buildDescription(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 30),
          ),
          const Spacer(),
          const Text(
            'Sản phẩm mới',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              saveImportGoods();
            },
            icon: const Icon(Icons.check, size: 30),
          ),
        ],
      );

  Widget _buildDescription() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mô tả', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          TextFormField(
            controller: descriptionController,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Nhập mô tả',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description, color: Colors.blue),
            ),
          ),
        ],
      );

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    IconData? icon,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              border: const OutlineInputBorder(),
              prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
            ),
          ),
        ],
      );
}
