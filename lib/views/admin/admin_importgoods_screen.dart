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
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
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
  final descriptionController = TextEditingController();

  // Lưu ảnh theo màu
  Map<String, File?> selectedImagesByColor = {};
  
  // THAY ĐỔI: Lưu sizes theo từng màu (List structure)
  Map<String, List<SizesModel>> selectedSizesByColor = {};
  // colorID -> [SizesModel]
  
  BrandsModel? selectedBrand;
  CategoryModel? selectedCategory;
  List<ColorsModel> selectedColors = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BrandViewmodel>().fetchAllBrands();
      context.read<CategoryViewmodel>().fetchCategories();
      context.read<ColorsViewmodel>().fetchAllColors();
      context.read<SizesViewmodel>().getAllSizes();
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
    // Validate
    if (nameController.text.isEmpty) {
      _showError('Vui lòng nhập tên sản phẩm');
      return;
    }
    if (selectedBrand == null) {
      _showError('Vui lòng chọn thương hiệu');
      return;
    }
    if (selectedCategory == null) {
      _showError('Vui lòng chọn danh mục');
      return;
    }
    if (selectedColors.isEmpty) {
      _showError('Vui lòng chọn ít nhất 1 màu');
      return;
    }

    // Validate từng màu phải có ít nhất 1 size và 1 ảnh
    for (var color in selectedColors) {
      final sizes = selectedSizesByColor[color.colorID];
      if (sizes == null || sizes.isEmpty) {
        _showError('Vui lòng chọn ít nhất 1 size cho màu ${color.name}');
        return;
      }
      
      if (selectedImagesByColor[color.colorID] == null) {
        _showError('Vui lòng chọn ảnh cho màu ${color.name}');
        return;
      }
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Tạo Product
      final newProduct = ProductsModel(
        productID: '',
        name: nameController.text,
        categoryID: selectedCategory!.categoryID,
        brandID: selectedBrand!.brandID,
      );

      final productId = await context
          .read<ProductViewModel>()
          .addProduct(newProduct.toMap());

      if (productId == null || productId.isEmpty) {
        throw Exception('Lỗi tạo sản phẩm');
      }

      // 2. Tạo ProductDetail cho từng màu (với Map sizes)
      for (final color in selectedColors) {
        final sizesMap = selectedSizesByColor[color.colorID]!;
        final imageFile = selectedImagesByColor[color.colorID]!;

        // Upload ảnh
        final imageUrl = await GalleryUtil.uploadImageToFirebase(
          imageFile,
          folderName: 'products/$productId/${color.colorID}',
        );

        if (imageUrl == null) {
          throw Exception('Lỗi tải lên hình ảnh cho màu ${color.name}');
        }

        // Convert List<SizesModel> -> List<String> cho sizeIDs
        final sizeIDs = sizesMap.map((s) => s.sizeID).toList();

        // Tạo ProductDetail với List sizeIDs
        final productDetail = ProductsdetailModel(
          productsDetailID: "",
          productID: productId,
          colorID: color.colorID,
          imageUrls: imageUrl,
          sizeIDs: sizeIDs, // List: [size_s, size_m]
        );

        await context
            .read<ProductDetailViewModel>()
            .addProductDetail(productId, productDetail.toMap());
      }

      Navigator.of(context).pop(); // Close loading
      _showSuccess('✅ Lưu sản phẩm thành công!');
      Navigator.of(context).pop(); // Back to previous screen
      
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      _showError('Lỗi khi lưu sản phẩm: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
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
                      icon: Icons.shopping_bag,
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

                    // Màu
                    const Text('Chọn Màu', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    colorVM.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Builldcolor(
                            onColorsSelected: (colors) {
                              setState(() {
                                selectedColors = colors;

                                // Cập nhật map ảnh và sizes cho từng màu
                                for (var color in selectedColors) {
                                  selectedImagesByColor.putIfAbsent(
                                    color.colorID, () => null);
                                  selectedSizesByColor.putIfAbsent(
                                    color.colorID, () => []);
                                }
                                
                                // Xóa màu không còn chọn
                                selectedImagesByColor.removeWhere(
                                  (key, _) => !selectedColors
                                      .any((c) => c.colorID == key),
                                );
                                selectedSizesByColor.removeWhere(
                                  (key, _) => !selectedColors
                                      .any((c) => c.colorID == key),
                                );
                              });
                            },
                          ),

                    const SizedBox(height: 20),

                    // Hiển thị từng màu với ảnh và sizes
                    if (selectedColors.isNotEmpty)
                      ...selectedColors.map((color) => _buildColorSection(color)),

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

  // Build section cho từng màu
  Widget _buildColorSection(ColorsModel color) {
    final image = selectedImagesByColor[color.colorID];
    final selectedSizesList = selectedSizesByColor[color.colorID] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color name + preview
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.hexCode.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                color.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Image picker
          GestureDetector(
            onTap: () => pickImageForColor(color.colorID),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                image: image != null
                    ? DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: image == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Chọn ảnh', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() =>
                                selectedImagesByColor[color.colorID] = null),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Size selector
          const Text(
            'Chọn Sizes:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildSizeSelector(color),

          // Hiển thị sizes đã chọn
          if (selectedSizesList.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: selectedSizesList.map((size) {
                return Chip(
                  label: Text(size.name),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      selectedSizesByColor[color.colorID]
                          ?.removeWhere((s) => s.sizeID == size.sizeID);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Build size selector với Map
  Widget _buildSizeSelector(ColorsModel color) {
    return Consumer<SizesViewmodel>(
      builder: (context, vm, _) {
        // Filter sizes theo category
        final availableSizes = selectedCategory != null
            ? vm.sizesList.where((s) => s.categoryID == selectedCategory!.categoryID).toList()
            : vm.sizesList;

        if (availableSizes.isEmpty) {
          return const Text('Không có size nào', style: TextStyle(fontSize: 12));
        }

        final selectedSizesList = selectedSizesByColor[color.colorID] ?? [];

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSizes.map((size) {
            final isSelected = selectedSizesList.any((s) => s.sizeID == size.sizeID);

            return FilterChip(
              label: Text(size.name),
              selected: isSelected,
              selectedColor: Colors.blue.shade100,
              onSelected: (selected) {
                setState(() {
                  if (!selectedSizesByColor.containsKey(color.colorID)) {
                    selectedSizesByColor[color.colorID] = [];
                  }

                  final list = selectedSizesByColor[color.colorID]!;
                  if (selected) {
                    // Thêm size vào List nếu chưa có
                    if (!list.any((s) => s.sizeID == size.sizeID)) {
                      list.add(size);
                    }
                  } else {
                    // Xóa size khỏi List
                    list.removeWhere((s) => s.sizeID == size.sizeID);
                  }
                });
              },
            );
          }).toList(),
        );
      },
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
            onPressed: saveImportGoods,
            icon: const Icon(Icons.check, size: 30, color: Colors.green),
          ),
        ],
      );

  Widget _buildDescription() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mô tả', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Nhập mô tả sản phẩm...',
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
          Text(label, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Nhập $label',
              border: const OutlineInputBorder(),
              prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
            ),
          ),
        ],
      );
}