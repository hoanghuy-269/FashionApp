import 'package:fashion_app/data/models/brands_model.dart';
import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/data/models/product_size_model.dart';
import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/viewmodels/brand_viewmodel.dart';
import 'package:fashion_app/viewmodels/category_viewmodel.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_size_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_viewmodel.dart';
import 'package:fashion_app/viewmodels/productdetail_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_productvariant_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
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
  final _descriptionController = TextEditingController();

  // Lưu image theo màu
  final Map<String, String> _imagesByColor = {};

  final Map<String, Map<String, _SizeData>> _dataBySizeColor = {};

  BrandsModel? _selectedBrand;
  CategoryModel? _selectedCategory;
  ProductsModel? _selectedProduct;
  List<SizesModel> _selectedSizes = [];
  List<ColorsModel> _selectedColors = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BrandViewmodel>().fetchAllBrands();
      context.read<CategoryViewmodel>().fetchCategories();
      context.read<ColorsViewmodel>().fetchAllColors();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    // Dispose tất cả controllers
    for (var colorMap in _dataBySizeColor.values) {
      for (var data in colorMap.values) {
        data.dispose();
      }
    }
    super.dispose();
  }

  // Lấy hoặc tạo data cho size + color
  _SizeData _getSizeData(String colorID, String sizeID) {
    if (!_dataBySizeColor.containsKey(colorID)) {
      _dataBySizeColor[colorID] = {};
    }
    if (!_dataBySizeColor[colorID]!.containsKey(sizeID)) {
      _dataBySizeColor[colorID]![sizeID] = _SizeData();
    }
    return _dataBySizeColor[colorID]![sizeID]!;
  }

  // Load ảnh cho màu
  Future<void> _loadImages() async {
    if (_selectedProduct == null) return;

    final detailVM = context.read<ProductDetailViewModel>();

    for (var color in _selectedColors) {
      if (_imagesByColor.containsKey(color.colorID)) continue;

      try {
        final imageUrl = await detailVM.getImageByID(
          productId: _selectedProduct!.productID,
          productDetailId: color.colorID,
        );

        if (imageUrl != null && imageUrl.isNotEmpty && mounted) {
          setState(() {
            _imagesByColor[color.colorID] = imageUrl;
          });
        }
      } catch (e) {
        debugPrint('Lỗi load ảnh: $e');
      }
    }
  }

  // Validate dữ liệu
  String? _validate() {
    if (_selectedProduct == null) return 'Chọn sản phẩm';
    if (_selectedBrand == null) return 'Chọn thương hiệu';
    if (_selectedSizes.isEmpty) return 'Chọn ít nhất 1 size';
    if (_selectedColors.isEmpty) return 'Chọn ít nhất 1 màu';

    // Kiểm tra từng màu + size
    for (var color in _selectedColors) {
      for (var size in _selectedSizes) {
        final data = _dataBySizeColor[color.colorID]?[size.sizeID];
        if (data == null) {
          return 'Nhập đủ thông tin cho ${color.name} - ${size.name}';
        }

        final qty = int.tryParse(data.quantity.text);
        final importPrice = double.tryParse(data.importPrice.text);
        final salePrice = double.tryParse(data.salePrice.text);

        if (qty == null || qty <= 0) {
          return 'Số lượng không hợp lệ: ${color.name} - ${size.name}';
        }
        if (importPrice == null || importPrice <= 0) {
          return 'Giá nhập không hợp lệ: ${color.name} - ${size.name}';
        }
        if (salePrice == null || salePrice <= 0) {
          return 'Giá bán không hợp lệ: ${color.name} - ${size.name}';
        }
      }
    }
    return null;
  }

  // Tính tổng số lượng
  int _getTotalQuantity() {
    int total = 0;
    for (var colorMap in _dataBySizeColor.values) {
      for (var data in colorMap.values) {
        total += int.tryParse(data.quantity.text) ?? 0;
      }
    }
    return total;
  }

  // Lấy shop ID
  Future<String?> _getShopId() async {
    final shopVM = context.read<ShopViewModel>();
    var shop = shopVM.currentShop;

    if (shop == null) {
      shop = await shopVM.fetchShopForCurrentUser();
    }

    return shop?.shopId;
  }

  // Lưu sản phẩm
  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Lấy shopId
      final shopId = await _getShopId();
      if (shopId == null) {
        _showError('Không tìm thấy cửa hàng');
        return;
      }

      // 2. Tạo ShopProduct
      final shopProduct = ShopProductModel(
        shopproductID: '',
        shopId: shopId,
        productID: _selectedProduct!.productID,
        name: _selectedProduct!.name,
        totalQuantity: _getTotalQuantity(),
        imageUrls: _imagesByColor.values.firstOrNull ?? '',
        totalPrice: 0.0,
        rating: 0,
        sold: 0,
        description: _descriptionController.text.trim(),
        
      );

      final shopProductVM = context.read<ShopProductViewModel>();
      final shopProductId = await shopProductVM.addShopProduct(shopProduct);

      if (shopProductId == null) {
        _showError('Lỗi tạo shop product');
        return;
      }

      // 3. Tạo variants + sizes
      await _createVariantsAndSizes(shopProductId);

      if (mounted) {
        _showSuccess('Thêm sản phẩm thành công!');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Lỗi save: $e');
      _showError('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Tạo variants và sizes
  Future<void> _createVariantsAndSizes(String shopProductId) async {
    final variantVM = context.read<ShopProductVariantViewModel>();
    final sizeVM = context.read<ProductSizeViewmodel>();

    for (var color in _selectedColors) {
      // Tạo variant cho màu này
      final variant = ShopProductVariantModel(
        shopProductVariantID: '',
        colorID: color.colorID,
        imageUrls: _imagesByColor[color.colorID] ?? '',
      );

      final variantId = await variantVM.addVariant(
        shopProductId,
        variant.toMap(),
      );
      if (variantId == null || variantId.isEmpty) {
        debugPrint('Lỗi tạo variant cho màu: ${color.colorID}');
        continue;
      }

      // Tạo sizes cho variant này
      for (var size in _selectedSizes) {
        final data = _dataBySizeColor[color.colorID]?[size.sizeID];
        if (data == null) continue;

        final productSize = ProductSizeModel(
          sizeID: size.sizeID,
          quantity: int.parse(data.quantity.text),
          costPrice: double.parse(data.importPrice.text),
          price: double.parse(data.salePrice.text),
        );

        try {
          await sizeVM.addSize(shopProductId, variantId, productSize);
        } catch (e) {
          debugPrint('Lỗi thêm size ${size.sizeID}: $e');
        }
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'Nhập sản phẩm',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _save,
                        icon: const Icon(Icons.check, color: Colors.green),
                      ),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand
                        const Text(
                          'Thương hiệu',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Consumer<BrandViewmodel>(
                          builder:
                              (context, vm, _) => Buildbranchdropdown(
                                onBrandSelected: (brand) async {
                                  setState(() {
                                    _selectedBrand = brand;
                                    _selectedProduct = null;
                                    _selectedSizes.clear();
                                    _selectedColors.clear();
                                    _imagesByColor.clear();
                                    _dataBySizeColor.clear();
                                  });
                                  if (brand != null) {
                                    await context
                                        .read<ProductViewModel>()
                                        .fetchProductsByBrand(brand.brandID);
                                  }
                                },
                              ),
                        ),

                        const SizedBox(height: 16),

                        // Product
                        const Text(
                          'Sản phẩm',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Consumer<ProductViewModel>(
                          builder:
                              (context, vm, _) => BuildProductDropdown(
                                brandID: _selectedBrand?.brandID ?? '',
                                onProductSelected: (product) {
                                  setState(() {
                                    _selectedProduct = product;
                                    _selectedSizes.clear();
                                    _selectedColors.clear();
                                    _imagesByColor.clear();
                                    _dataBySizeColor.clear();
                                  });
                                },
                              ),
                        ),

                        const SizedBox(height: 16),

                        // Category
                        const Text(
                          'Danh mục',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Consumer<CategoryViewmodel>(
                          builder:
                              (context, vm, _) => Buildcategorydropdown(
                                onCategorySelected:
                                    (cat) => setState(() {
                                      _selectedCategory = cat;
                                      _selectedProduct = null;
                                      _selectedSizes.clear();
                                      _selectedColors.clear();
                                      _imagesByColor.clear();
                                      _dataBySizeColor.clear();
                                    }),
                              ),
                        ),

                        const SizedBox(height: 16),

                        // Size
                        const Text(
                          'Kích thước',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Consumer<SizesViewmodel>(
                          builder:
                              (context, vm, _) => BuildsizeShop(
                                onSizeToggled: (size, selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedSizes.add(size);
                                    } else {
                                      // Xóa size khỏi danh sách
                                      _selectedSizes.removeWhere(
                                        (s) => s.sizeID == size.sizeID,
                                      );

                                      // Xóa data liên quan đến size này an toàn bằng removeWhere
                                      _dataBySizeColor.forEach((
                                        colorId,
                                        colorMap,
                                      ) {
                                        colorMap.removeWhere(
                                          (sizeId, _) => sizeId == size.sizeID,
                                        );
                                      });
                                    }
                                  });
                                },
                              ),
                        ),

                        const SizedBox(height: 16),

                        // Color
                        const Text(
                          'Màu sắc',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Consumer<ColorsViewmodel>(
                          builder:
                              (context, vm, _) => BuildcolorShop(
                                onColorsSelected: (colors) {
                                  setState(() {
                                    _selectedColors = colors;
                                    // Xóa data của màu không còn chọn
                                    _dataBySizeColor.removeWhere(
                                      (colorId, _) =>
                                          !colors.any(
                                            (c) => c.colorID == colorId,
                                          ),
                                    );
                                  });
                                  _loadImages();
                                },
                              ),
                        ),

                        const SizedBox(height: 24),

                        // Input fields
                        if (_selectedColors.isNotEmpty &&
                            _selectedSizes.isNotEmpty)
                          ..._selectedColors.map(
                            (color) => _buildColorSection(color),
                          ),

                        const SizedBox(height: 16),

                        // Description
                        const Text(
                          'Mô tả',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập mô tả...',
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColorSection(ColorsModel color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color name + image
          Row(
            children: [
              Text(
                color.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(color.hexCode.replaceFirst('#', '0xFF')),
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Image
          if (_imagesByColor.containsKey(color.colorID))
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imagesByColor[color.colorID]!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Size inputs
          ..._selectedSizes.map((size) => _buildSizeInput(color, size)),
        ],
      ),
    );
  }

  Widget _buildSizeInput(ColorsModel color, SizesModel size) {
    final data = _getSizeData(color.colorID, size.sizeID);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Size: ${size.name}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: data.quantity,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: data.importPrice,
                  decoration: const InputDecoration(
                    labelText: 'Giá nhập',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: data.salePrice,
                  decoration: const InputDecoration(
                    labelText: 'Giá bán',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Class lưu data cho 1 size
class _SizeData {
  final quantity = TextEditingController();
  final importPrice = TextEditingController();
  final salePrice = TextEditingController();

  void dispose() {
    quantity.dispose();
    importPrice.dispose();
    salePrice.dispose();
  }
}
