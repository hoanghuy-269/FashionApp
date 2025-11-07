import 'dart:async';
import 'dart:io';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/core/utils/pick_image_bottom_sheet.dart';
import 'package:fashion_app/data/models/brands_model.dart';
import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/models/shop_model.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/brand_viewmodel.dart';
import 'package:fashion_app/viewmodels/category_viewmodel.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_productvariant_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildBranchDropdown.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildCategoryDropdown.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildColor_shop.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildProductDropdown.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildSize_shop.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddImportgoodsScreen extends StatefulWidget {
  const AddImportgoodsScreen({super.key});

  @override
  State<AddImportgoodsScreen> createState() => _AddImportgoodsScreenState();
}

class _AddImportgoodsScreenState extends State<AddImportgoodsScreen> {
  final descriptionController = TextEditingController();
  final Map<String, File?> selectedImagesByColor = {};

  final Map<String, TextEditingController> importPriceControllers = {};
  final Map<String, TextEditingController> salePriceControllers = {};
  final Map<String, TextEditingController> quantityControllers = {};

  BrandsModel? selectedBrand;
  CategoryModel? selectedCategory;
  ProductsModel? selectedProduct;
  List<SizesModel> selectedSizes = [];
  List<ColorsModel> selectedColors = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BrandViewmodel>().fetchAllBrands();
      context.read<CategoryViewmodel>().fetchCategories();
      context.read<ColorsViewmodel>().fetchColors();
    });
  }

  @override
  void dispose() {
    // Giải phóng tất cả controllers
    importPriceControllers.values.forEach((c) => c.dispose());
    salePriceControllers.values.forEach((c) => c.dispose());
    quantityControllers.values.forEach((c) => c.dispose());
    descriptionController.dispose();
    super.dispose();
  }

  // Tạo controller cho màu nếu chưa có
  TextEditingController _getOrCreateController(
    Map<String, TextEditingController> controllers,
    String colorID,
  ) {
    if (!controllers.containsKey(colorID)) {
      controllers[colorID] = TextEditingController();
    }
    return controllers[colorID]!;
  }

  Future<void> pickImageForColor(String colorID) async {
    final image = await showPickImageBottomSheet(context);
    if (image != null) {
      setState(() {
        selectedImagesByColor[colorID] = image;
      });
    }
  }

  Future<void> _saveProduct() async {
    // Kiểm tra validation
    if (selectedProduct == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn sản phẩm')));
      return;
    }
    if (selectedSizes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn kích thước')));
      return;
    }
    if (selectedColors.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn màu sắc')));
      return;
    }
    if (selectedBrand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thương hiệu')),
      );
      return;
    }

    // Kiểm tra từng màu có đủ thông tin không
    for (final color in selectedColors) {
      final qty = quantityControllers[color.colorID]?.text ?? '';
      final importPrice = importPriceControllers[color.colorID]?.text ?? '';
      final salePrice = salePriceControllers[color.colorID]?.text ?? '';

      if (qty.isEmpty || int.tryParse(qty) == null || int.parse(qty) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng nhập số lượng cho màu ${color.name}'),
          ),
        );
        return;
      }
      if (importPrice.isEmpty || double.tryParse(importPrice) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng nhập giá nhập cho màu ${color.name}'),
          ),
        );
        return;
      }
      if (salePrice.isEmpty || double.tryParse(salePrice) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng nhập giá bán cho màu ${color.name}'),
          ),
        );
        return;
      }
    }
    if (isLoading) return;
    setState(() {
      isLoading = true;
    
    });

    try {
      final shopVM = context.read<ShopViewModel>();
    var currentShop = shopVM.currentShop;
    if (currentShop == null) {
      final fetched = await shopVM.fetchShopForCurrentUser();
      currentShop = fetched ?? shopVM.currentShop;
    }
    if (currentShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy cửa hàng hiện tại. Vui lòng thử lại.'),
        ),
      );
      return;
    }
    final shopId = currentShop.shopId;

    // Tạo ShopProduct
    final newShopProduct = ShopProductModel(
      shopproductID: '',
      shopId: shopId,
      productID: selectedProduct!.productID,
      totalQuantity: 0,
      rating: 0,
      sold: 0,
    );

    final shopProductVM = context.read<ShopProductViewModel>();
    final createdId = await shopProductVM.addShopProduct(newShopProduct);
    if (createdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo sản phẩm cho cửa hàng.')),
      );
      return;
    }

    // Tạo variants cho từng màu và size
    for (final color in selectedColors) {
      // Upload ảnh nếu có
      String imageUrl = '';
      if (selectedImagesByColor[color.colorID] != null) {
        final uploadedUrl = await GalleryUtil.uploadImageToFirebase(
          selectedImagesByColor[color.colorID]!,
          folderName: 'product_variants',
        );
        imageUrl = uploadedUrl ?? '';
      }

      // Lấy giá trị riêng cho màu này
      final quantity = int.parse(quantityControllers[color.colorID]!.text);
      final importPrice = double.parse(
        importPriceControllers[color.colorID]!.text,
      );
      final salePrice = double.parse(salePriceControllers[color.colorID]!.text);

      for (final size in selectedSizes) {
        final variant = ShopProductVariantModel(
          shopProductVariantID: '',
          colorID: color.colorID,
          sizeID: size.sizeID,
          quantity: quantity,
          price: salePrice,
          costPrice: importPrice,
          imageUrls: imageUrl,
        );

        await context.read<ShopProductvariantViewmodel>().addShopProductVariant(
          shopProductID: createdId,
          variantData: variant.toMap(),
        );
      }
    }
    } catch (e) {
     print('Lỗi khi lưu sản phẩm: $e');
     return;
    } finally{
      setState(() {
        isLoading = false;
      });
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Thêm sản phẩm thành công!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thương hiệu
                        Text('Chọn Thương hiệu', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Consumer<BrandViewmodel>(
                          builder: (context, brandVM, _) {
                            if (brandVM.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Buildbranchdropdown(
                              onBrandSelected: (b) async {
                                setState(() => selectedBrand = b);
                                if (b != null) {
                                  await context
                                      .read<ProductViewModel>()
                                      .fetchProductsByBrand(b.brandID);
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
          
                        // Sản phẩm
                        Text('Chọn Sản phẩm', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Consumer<ProductViewModel>(
                          builder: (context, productVM, _) {
                            if (productVM.isLoading) {
                              return Center(child: CircularProgressIndicator());
                            }
                            return BuildProductDropdown(
                              brandID: selectedBrand?.brandID ?? '',
                              onProductSelected: (p) {
                                setState(() => selectedProduct = p);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
          
                        // Danh mục
                        const Text('Chọn Danh mục', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Consumer<CategoryViewmodel>(
                          builder: (context, categoryVM, _) {
                            if (categoryVM.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Buildcategorydropdown(
                              onCategorySelected:
                                  (c) => setState(() => selectedCategory = c),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
          
                        // Size
                        const Text('Chọn Size', style: TextStyle(fontSize: 16)),
                        Consumer<BrandViewmodel>(
                          builder: (context, brandVM, _) {
                            if (brandVM.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return BuildsizeShop(
                              onSizeToggled: (s, sel) {
                                setState(() {
                                  if (sel) {
                                    selectedSizes.add(s);
                                  } else {
                                    selectedSizes.removeWhere(
                                      (e) => e.sizeID == s.sizeID,
                                    );
                                  }
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
          
                        // Màu sắc
                        const Text('Chọn Màu', style: TextStyle(fontSize: 16)),
                        Consumer<ColorsViewmodel>(
                          builder: (context, colorVM, _) {
                            if (colorVM.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return BuildcolorShop(
                              onColorsSelected: (c) {
                                setState(() {
                                  selectedColors = c;
          
                                  // Khởi tạo controllers và image map cho màu mới
                                  for (var color in selectedColors) {
                                    selectedImagesByColor.putIfAbsent(
                                      color.colorID,
                                      () => null,
                                    );
                                    _getOrCreateController(
                                      importPriceControllers,
                                      color.colorID,
                                    );
                                    _getOrCreateController(
                                      salePriceControllers,
                                      color.colorID,
                                    );
                                    _getOrCreateController(
                                      quantityControllers,
                                      color.colorID,
                                    );
                                  }
          
                                  // Xóa dữ liệu của màu không còn chọn
                                  selectedImagesByColor.removeWhere(
                                    (key, value) =>
                                        !selectedColors.any(
                                          (c) => c.colorID == key,
                                        ),
                                  );
                                  importPriceControllers.removeWhere(
                                    (key, value) =>
                                        !selectedColors.any(
                                          (c) => c.colorID == key,
                                        ),
                                  );
                                  salePriceControllers.removeWhere(
                                    (key, value) =>
                                        !selectedColors.any(
                                          (c) => c.colorID == key,
                                        ),
                                  );
                                  quantityControllers.removeWhere(
                                    (key, value) =>
                                        !selectedColors.any(
                                          (c) => c.colorID == key,
                                        ),
                                  );
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
          
                        // Ảnh và thông tin theo từng màu
                        if (selectedColors.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  selectedColors.map((color) {
                                    final image =
                                        selectedImagesByColor[color.colorID];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16,
                                        bottom: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            color.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
          
                                          // Ảnh
                                          GestureDetector(
                                            onTap:
                                                () => pickImageForColor(
                                                  color.colorID,
                                                ),
                                            child: Container(
                                              width: 200,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  10,
                                                ),
                                                image:
                                                    image != null
                                                        ? DecorationImage(
                                                          image: FileImage(image),
                                                          fit: BoxFit.cover,
                                                        )
                                                        : null,
                                              ),
                                              child:
                                                  image == null
                                                      ? const Center(
                                                        child: Icon(
                                                          Icons.add_a_photo,
                                                          size: 40,
                                                          color: Colors.grey,
                                                        ),
                                                      )
                                                      : Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          child: GestureDetector(
                                                            onTap:
                                                                () => setState(
                                                                  () =>
                                                                      selectedImagesByColor[color
                                                                              .colorID] =
                                                                          null,
                                                                ),
                                                            child:
                                                                const CircleAvatar(
                                                                  radius: 12,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .black54,
                                                                  child: Icon(
                                                                    Icons.close,
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
          
                                          // Các ô nhập liệu riêng cho màu này
                                          SizedBox(
                                            width: 200,
                                            child: Column(
                                              children: [
                                                TextField(
                                                  controller:
                                                      _getOrCreateController(
                                                        importPriceControllers,
                                                        color.colorID,
                                                      ),
                                                  decoration: const InputDecoration(
                                                    labelText: "Giá nhập",
                                                    border: OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      _getOrCreateController(
                                                        salePriceControllers,
                                                        color.colorID,
                                                      ),
                                                  decoration: const InputDecoration(
                                                    labelText: "Giá bán",
                                                    border: OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      _getOrCreateController(
                                                        quantityControllers,
                                                        color.colorID,
                                                      ),
                                                  decoration: const InputDecoration(
                                                    labelText: "Số lượng",
                                                    border: OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
          
                        const SizedBox(height: 20),
                        _buildDescription(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5), // nền mờ
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
       
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
        'Nhập sản phẩm',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const Spacer(),
      IconButton(
        onPressed: _saveProduct,
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
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: Icon(Icons.description, color: Colors.blue),
        ),
      ),
    ],
  );
}
