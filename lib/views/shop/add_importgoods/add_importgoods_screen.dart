import 'package:fashion_app/data/models/brands_model.dart';
import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/brand_viewmodel.dart';
import 'package:fashion_app/viewmodels/category_viewmodel.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_viewmodel.dart';
import 'package:fashion_app/viewmodels/productdetail_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_productvariant_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildBranchDropdown.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildCategoryDropdown.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildColor_shop.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildProductDropdown.dart';
import 'package:fashion_app/views/shop/add_importgoods/buildSize_shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddImportgoodsScreen extends StatefulWidget {
  const AddImportgoodsScreen({super.key});

  @override
  State<AddImportgoodsScreen> createState() => _AddImportgoodsScreenState();
}

class _AddImportgoodsScreenState extends State<AddImportgoodsScreen> {
  final descriptionController = TextEditingController();
  final Map<String, String> selectedImagesByColor = {}; 
  final Map<String, TextEditingController> importPriceControllers = {};
  final Map<String, TextEditingController> salePriceControllers = {};
  final Map<String, TextEditingController> quantityControllers = {};
  int totalQuantity = 0;

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
      context.read<ColorsViewmodel>().fetchAllColors();
    });
  }

  @override
  void dispose() {
    importPriceControllers.values.forEach((c) => c.dispose());
    salePriceControllers.values.forEach((c) => c.dispose());
    quantityControllers.values.forEach((c) => c.dispose());
    descriptionController.dispose();
    super.dispose();
  }

  TextEditingController _getOrCreateController(
    Map<String, TextEditingController> controllers,
    String colorID,
  ) {
    if (!controllers.containsKey(colorID)) {
      controllers[colorID] = TextEditingController();
    }
    return controllers[colorID]!;
  }

  //  load ảnh cho từng màu
  Future<void> _loadImagesForColors(List<ColorsModel> colors) async {
    if (selectedProduct == null) return;

    for (final color in colors) {
     
      if (selectedImagesByColor.containsKey(color.colorID)) continue;

      final imageUrl = await context
          .read<ProductDetailViewModel>()
          .getImageByID(
            productId: selectedProduct!.productID,
            productDetailId: color.colorID, // Truyền colorID
          );

      if (imageUrl != null && imageUrl.isNotEmpty && mounted) {
        setState(() {
          selectedImagesByColor[color.colorID] = imageUrl;
        });
      }
    }
  }

  // Validate input 
  String? _validateColorInputs() {
    for (final color in selectedColors) {
      final qty = quantityControllers[color.colorID]?.text ?? '';
      final importPrice = importPriceControllers[color.colorID]?.text ?? '';
      final salePrice = salePriceControllers[color.colorID]?.text ?? '';

      if (qty.isEmpty || int.tryParse(qty) == null || int.parse(qty) <= 0) {
        return 'Vui lòng nhập số lượng hợp lệ cho màu ${color.name}';
      }
      if (importPrice.isEmpty || double.tryParse(importPrice) == null) {
        return 'Vui lòng nhập giá nhập hợp lệ cho màu ${color.name}';
      }
      if (salePrice.isEmpty || double.tryParse(salePrice) == null) {
        return 'Vui lòng nhập giá bán hợp lệ cho màu ${color.name}';
      }
    }
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveProduct() async {
    // Validate cơ bản
    if (selectedProduct == null) {
      _showError('Vui lòng chọn sản phẩm');
      return;
    }
    if (selectedSizes.isEmpty) {
      _showError('Vui lòng chọn kích thước');
      return;
    }
    if (selectedColors.isEmpty) {
      _showError('Vui lòng chọn màu sắc');
      return;
    }
    if (selectedBrand == null) {
      _showError('Vui lòng chọn thương hiệu');
      return;
    }

    // Validate inputs cho từng màu
    final errorMsg = _validateColorInputs();
    if (errorMsg != null) {
      _showError(errorMsg);
      return;
    }

    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      // Lấy shopId
      final shopVM = context.read<ShopViewModel>();
      var currentShop = shopVM.currentShop;
      if (currentShop == null) {
        final fetched = await shopVM.fetchShopForCurrentUser();
        currentShop = fetched ?? shopVM.currentShop;
      }
      if (currentShop == null) {
        _showError('Không tìm thấy cửa hàng hiện tại');
        return;
      }
      final shopId = currentShop.shopId;

      // Lấy ảnh đầu tiên từ các màu đã chọn
      final firstImage = selectedImagesByColor.values.firstWhere(
        (url) => url.isNotEmpty,
        orElse: () => '',
      );

      // tính tổng 
      for (final color in selectedColors) {
        final qty = int.parse(quantityControllers[color.colorID]!.text);
        totalQuantity += qty;
      }
      // Tạo ShopProduct
      final newShopProduct = ShopProductModel(
        shopproductID: '',
        shopId: shopId,
        productID: selectedProduct!.productID,
        name: selectedProduct!.name,
        totalQuantity: totalQuantity,
        imageUrls: firstImage,
        rating: 0,
        sold: 0,
      );

      final shopProductVM = context.read<ShopProductViewModel>();
      final createdId = await shopProductVM.addShopProduct(newShopProduct);
      if (createdId == null) {
        _showError('Không thể tạo sản phẩm cho cửa hàng');
        return;
      }

      // Tạo variants
      for (final color in selectedColors) {
        final imageUrl = selectedImagesByColor[color.colorID] ?? '';
        final quantity = int.parse(quantityControllers[color.colorID]!.text);
        final importPrice = double.parse(
          importPriceControllers[color.colorID]!.text,
        );
        final salePrice = double.parse(
          salePriceControllers[color.colorID]!.text,
        );

        for (final size in selectedSizes) {
          final variant = ShopProductVariantModel(
            shopProductVariantID: '',
            colorID: color.colorID,
            sizeIDS: [size.sizeID],
            quantity: quantity,
            price: salePrice,
            costPrice: importPrice,
            imageUrls: imageUrl,
          );

          await context
              .read<ShopProductvariantViewmodel>()
              .addVariant(createdId, variant.toMap());
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sản phẩm thành công!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Lỗi khi lưu sản phẩm: $e');
      _showError('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
                        const Text(
                          'Chọn Thương hiệu',
                          style: TextStyle(fontSize: 16),
                        ),
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
                        const Text(
                          'Chọn Sản phẩm',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Consumer<ProductViewModel>(
                          builder: (context, productVM, _) {
                            if (productVM.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
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
                        const Text(
                          'Chọn Danh mục',
                          style: TextStyle(fontSize: 16),
                        ),
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
                              onColorsSelected: (colors) {
                                setState(() {
                                  selectedColors = colors;

                                  // Khởi tạo controllers
                                  for (var color in colors) {
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

                                  // Xóa data của màu không còn chọn
                                  selectedImagesByColor.removeWhere(
                                    (key, _) =>
                                        !colors.any((c) => c.colorID == key),
                                  );
                                  importPriceControllers.removeWhere(
                                    (key, _) =>
                                        !colors.any((c) => c.colorID == key),
                                  );
                                  salePriceControllers.removeWhere(
                                    (key, _) =>
                                        !colors.any((c) => c.colorID == key),
                                  );
                                  quantityControllers.removeWhere(
                                    (key, _) =>
                                        !colors.any((c) => c.colorID == key),
                                  );
                                });

                                // Auto load ảnh
                                _loadImagesForColors(colors);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Hiển thị ảnh và inputs theo màu
                        if (selectedColors.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  selectedColors.map((color) {
                                    final imageUrl =
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
                                          Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child:
                                                imageUrl == null ||
                                                        imageUrl.isEmpty
                                                    ? const Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 40,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            'Không có ảnh',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      child: Image.network(
                                                        imageUrl,
                                                        width: 200,
                                                        height: 200,
                                                        fit: BoxFit.cover,
                                                        loadingBuilder: (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value:
                                                                  loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                      : null,
                                                            ),
                                                          );
                                                        },
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .error_outline,
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  size: 40,
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Lỗi tải ảnh',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Input fields
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
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "Giá nhập",
                                                        border:
                                                            OutlineInputBorder(),
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
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "Giá bán",
                                                        border:
                                                            OutlineInputBorder(),
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
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "Số lượng",
                                                        border:
                                                            OutlineInputBorder(),
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
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
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
