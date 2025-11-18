import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/product_size_model.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_size_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_request_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_productvariant_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopImportgoods extends StatefulWidget {
  final String? shopProductID;
  
  const ShopImportgoods({
    super.key,
    this.shopProductID,
  });

  @override
  State<ShopImportgoods> createState() =>
      _ShopImportgoodsState();
}

class _ShopImportgoodsState extends State<ShopImportgoods> {
  bool _isSaving = false;
  final Set<String> _expandedVariants = {};
  final Map<String, Map<String, ImportData>> _importDataMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.shopProductID != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ColorsViewmodel>().fetchAllColors();
        context.read<ShopProductVariantViewModel>()
            .fetchVariants(widget.shopProductID!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Nhập hàng vào kho',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _confirmImport,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, color: Colors.white, size: 18),
            label: Text(
              _isSaving ? 'Đang lưu...' : 'Xác nhận',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<ShopProductVariantViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.variants.isEmpty) {
            return const Center(child: Text('Không có sản phẩm'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.variants.length,
            itemBuilder: (context, index) => _buildVariantCard(vm.variants[index]),
          );
        },
      ),
    );
  }

  Widget _buildVariantCard(ShopProductVariantModel variant) {
    final variantID = variant.shopProductVariantID;
    final isExpanded = _expandedVariants.contains(variantID);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          _buildVariantHeader(variant, isExpanded),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildSizesList(variantID),
          ],
        ],
      ),
    );
  }

  Widget _buildVariantHeader(ShopProductVariantModel variant, bool isExpanded) {
    return InkWell(
      onTap: () => _toggleVariant(variant.shopProductVariantID),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isExpanded ? Radius.zero : const Radius.circular(12),
            bottomRight: isExpanded ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            _buildVariantImage(variant.imageUrls),
            const SizedBox(width: 16),
            Expanded(child: _buildVariantInfo(variant)),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.blue,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl?.isNotEmpty == true
          ? Image.network(
              imageUrl!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderImage(),
            )
          : _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, size: 30, color: Colors.grey),
    );
  }

  Widget _buildVariantInfo(ShopProductVariantModel variant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variant: ${variant.shopProductVariantID}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Consumer<ColorsViewmodel>(
          builder: (context, colorVM, _) {
            final colorName = colorVM.getColorNameById(variant.colorID);
            return Text(
              'Màu: ${colorName ?? variant.colorID}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ],
    );
  }

  void _toggleVariant(String variantID) {
    setState(() {
      if (_expandedVariants.contains(variantID)) {
        _expandedVariants.remove(variantID);
      } else {
        _expandedVariants.add(variantID);
      }
    });
  }

  Widget _buildSizesList(String variantID) {
    return FutureBuilder<List<ProductSizeModel>>(
      future: context.read<ProductSizeViewmodel>().getSizesForVariant(
        widget.shopProductID ?? '',
        variantID,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Chưa có size cho variant này',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!
              .map((size) => _buildSizeItem(variantID, size))
              .toList(),
        );
      },
    );
  }

  Widget _buildSizeItem(String variantID, ProductSizeModel size) {
    _importDataMap.putIfAbsent(variantID, () => {});
    _importDataMap[variantID]!.putIfAbsent(
      size.sizeID,
      () => ImportData(),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSizeHeader(size),
          const SizedBox(height: 12),
          _buildCostPriceField(variantID, size.sizeID),
          const SizedBox(height: 12),
          _buildSellingPriceField(variantID, size.sizeID),
          const SizedBox(height: 12),
          _buildQuantityField(variantID, size.sizeID),
        ],
      ),
    );
  }

  Widget _buildSizeHeader(ProductSizeModel size) {
    return FutureBuilder<String?>(
      future: context.read<SizesViewmodel>().getSizeNameById(size.sizeID),
      builder: (context, snapshot) {
        final sizeName = snapshot.data ?? size.sizeID;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Size: $sizeName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip('Giá bán', '${size.price}đ', Colors.green),
                const SizedBox(width: 8),
                _buildInfoChip('Tồn kho', '${size.quantity}', Colors.blue),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCostPriceField(String variantID, String sizeID) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Giá nhập',
        hintText: 'Để trống nếu không thay đổi',
        prefixIcon: const Icon(Icons.attach_money, size: 20),
        suffixText: 'đ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      onChanged: (value) {
        final price = double.tryParse(value) ?? 0;
        _importDataMap[variantID]![sizeID]!.costPrice = price;
      },
    );
  }

  Widget _buildSellingPriceField(String variantID, String sizeID) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Giá bán',
        hintText: 'Để trống nếu không thay đổi',
        prefixIcon: const Icon(Icons.sell, size: 20),
        suffixText: 'đ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      onChanged: (value) {
        final price = double.tryParse(value) ?? 0;
        _importDataMap[variantID]![sizeID]!.sellingPrice = price;
      },
    );
  }

  Widget _buildQuantityField(String variantID, String sizeID) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Số lượng nhập thêm',
        hintText: 'Để trống nếu không thay đổi',
        prefixIcon: const Icon(Icons.add_box, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      onChanged: (value) {
        final qty = int.tryParse(value) ?? 0;
        _importDataMap[variantID]![sizeID]!.quantity = qty;
      },
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmImport() async {
    // Validate có dữ liệu nhập
    if (!_hasImportData()) {
      _showSnackBar(
        'Vui lòng nhập số lượng cho ít nhất một size!',
        Colors.orange,
      );
      return;
    }

    // Validate giá nhập
    if (!_hasValidCostPrice()) {
      _showSnackBar(
        'Vui lòng nhập giá nhập cho tất cả size có số lượng!',
        Colors.orange,
      );
      return;
    }

    // Hiển thị dialog xác nhận đơn giản
    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    // Thực hiện nhập kho
    await _performImport();
  }

  bool _hasImportData() {
    for (var variantData in _importDataMap.values) {
      for (var importData in variantData.values) {
        if (importData.quantity > 0) return true;
      }
    }
    return false;
  }

  bool _hasValidCostPrice() {
    for (var variantData in _importDataMap.values) {
      for (var importData in variantData.values) {
        if (importData.quantity > 0 && importData.costPrice <= 0) {
          return false;
        }
      }
    }
    return true;
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận nhập kho'),
        content: const Text('Bạn có chắc chắn muốn nhập hàng vào kho?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _performImport() async {
    setState(() => _isSaving = true);

    try {
      final productSizeVM = context.read<ProductSizeViewmodel>();

      for (var variantEntry in _importDataMap.entries) {
        final variantID = variantEntry.key;
        final sizesData = variantEntry.value;

        for (var sizeEntry in sizesData.entries) {
          final sizeID = sizeEntry.key;
          final importData = sizeEntry.value;

          if (importData.quantity > 0) {
            await _updateProductSize(
              productSizeVM,
              variantID,
              sizeID,
              importData,
            );
          }
        }
      }
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Đã nhập hàng vào kho thành công!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Lỗi: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _updateProductSize(
    ProductSizeViewmodel productSizeVM,
    String variantID,
    String sizeID,
    ImportData importData,
  ) async {
    // Lấy thông tin size hiện tại
    final sizes = await productSizeVM.getSizesForVariant(
      widget.shopProductID!,
      variantID,
    );

    final currentSize = sizes.firstWhere(
      (s) => s.sizeID == sizeID,
      orElse: () => ProductSizeModel(
        sizeID: sizeID,
        quantity: 0,
        price: 0,
        costPrice: 0,
      ),
    );

    final newQuantity = currentSize.quantity + importData.quantity;
    final newSellingPrice = importData.sellingPrice > 0
        ? importData.sellingPrice
        : currentSize.price;
    final newCostPrice = importData.costPrice > 0
        ? importData.costPrice
        : currentSize.costPrice;

    // Cập nhật 
    await productSizeVM.updateSize(
      widget.shopProductID!,
      variantID,
      ProductSizeModel(
        sizeID: sizeID,
        quantity: newQuantity,
        price: newSellingPrice,
        costPrice: newCostPrice,
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class ImportData {
  int quantity;
  double costPrice;      // Giá nhập
  double sellingPrice;   // Giá bán

  ImportData({
    this.quantity = 0,
    this.costPrice = 0,
    this.sellingPrice = 0,
  });
}