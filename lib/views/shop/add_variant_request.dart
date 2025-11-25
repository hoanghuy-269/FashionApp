import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/product_size_model.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_size_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_request_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_productvariant_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddVariantRequest extends StatefulWidget {
  final String? shopProductID;
  final String? productRequestID;

  const AddVariantRequest({
    super.key,
    this.shopProductID,
    this.productRequestID,
  });

  @override
  State<AddVariantRequest> createState() =>
      _AddVariantRequestState();
}

class _AddVariantRequestState
    extends State<AddVariantRequest> {
  final Set<String> _expandedVariants = {};
  final Map<String, Map<String, TextEditingController>> _controllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.shopProductID != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ColorsViewmodel>().fetchAllColors();
        context.read<ShopProductVariantViewModel>().fetchVariants(
          widget.shopProductID!,
        );
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var variantMap in _controllers.values) {
      for (var controller in variantMap.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  TextEditingController _getController(String variantId, String sizeId, String field, String initialValue) {
    final key = '${variantId}_${sizeId}_$field';
    if (!_controllers.containsKey(variantId)) {
      _controllers[variantId] = {};
    }
    if (!_controllers[variantId]!.containsKey(key)) {
      _controllers[variantId]![key] = TextEditingController(text: initialValue);
    }
    return _controllers[variantId]![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Kho hàng',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          // Nút Lưu
          IconButton(
            onPressed: _isLoading ? null : _saveAllChanges,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, color: Colors.green),
          ),
        ],
      ),
      body: Consumer<ShopProductVariantViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return vm.variants.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.variants.length,
                  itemBuilder: (context, index) =>
                      _buildVariantCard(vm.variants[index]),
                );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có variant nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantCard(ShopProductVariantModel variant) {
    final variantID = variant.shopProductVariantID;
    final isExpanded = _expandedVariants.contains(variantID);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildVariantHeader(variant, isExpanded),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildSizesList(variant.shopProductVariantID),
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
              .map((size) => _buildEditableSizeItem(size, variantID))
              .toList(),
        );
      },
    );
  }

  Widget _buildEditableSizeItem(ProductSizeModel size, String variantId) {
    return FutureBuilder<String?>(
      future: context.read<SizesViewmodel>().getSizeNameById(size.sizeID),
      builder: (context, snapshot) {
        final sizeName = snapshot.data ?? size.sizeID;

        // Initialize controllers
        final priceController = _getController(
          variantId,
          size.sizeID,
          'price',
          size.price.toString(),
        );
        final costPriceController = _getController(
          variantId,
          size.sizeID,
          'costPrice',
          size.costPrice.toString(),
        );
        final quantityController = _getController(
          variantId,
          size.sizeID,
          'quantity',
          size.quantity.toString(),
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên size
              Text(
                'Size: $sizeName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),

              // TextField inputs
              Row(
                children: [
                  // Giá nhập
                  Expanded(
                    child: TextField(
                      controller: costPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Giá nhập',
                        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Giá bán
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Giá bán',
                        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tồn kho
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tồn kho',
                        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAllChanges() async {
    if (widget.shopProductID == null) {
      _showSnackBar('Không có thông tin sản phẩm!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final variantVM = context.read<ShopProductVariantViewModel>();
      final sizeVM = context.read<ProductSizeViewmodel>();

      // Lặp qua tất cả variants
      for (var variant in variantVM.variants) {
        final variantId = variant.shopProductVariantID;

        // Lấy danh sách sizes cho variant này
        final sizes = await sizeVM.getSizesForVariant(
          widget.shopProductID!,
          variantId,
        );

        // Cập nhật từng size
        for (var size in sizes) {
          final priceKey = '${variantId}_${size.sizeID}_price';
          final costPriceKey = '${variantId}_${size.sizeID}_costPrice';
          final quantityKey = '${variantId}_${size.sizeID}_quantity';

          // Lấy giá trị mới từ controller
          final newPrice = double.tryParse(
            _controllers[variantId]?[priceKey]?.text ?? '',
          );
          final newCostPrice = double.tryParse(
            _controllers[variantId]?[costPriceKey]?.text ?? '',
          );
          final newQuantity = int.tryParse(
            _controllers[variantId]?[quantityKey]?.text ?? '',
          );

          // Chỉ cập nhật nếu có sự thay đổi
          bool hasChanges = false;
          final updatedSize = ProductSizeModel(
            sizeID: size.sizeID,
            quantity: newQuantity ?? size.quantity,
            costPrice: newCostPrice ?? size.costPrice,
            price: newPrice ?? size.price,
          );

          if (newPrice != null && newPrice != size.price) hasChanges = true;
          if (newCostPrice != null && newCostPrice != size.costPrice) hasChanges = true;
          if (newQuantity != null && newQuantity != size.quantity) hasChanges = true;

          if (hasChanges) {
            await sizeVM.addOrUpdateSize(
              widget.shopProductID!,
              variantId,
              updatedSize,
            );
            debugPrint(' Đã cập nhật size ${size.sizeID}');
          }
        }
      }

      // Cập nhật status thành "approved" nếu có productRequestID
      if (widget.productRequestID != null && widget.productRequestID!.isNotEmpty) {
        final requestVM = context.read<ShopProductRequestViewmodel>();
        final updateSuccess = await requestVM.updateStatus(
          widget.productRequestID!,
          'approved',
        );

        if (!updateSuccess) {
          throw Exception('Không thể cập nhật trạng thái yêu cầu');
        }
        debugPrint(' Đã cập nhật status thành approved');
      }

      if (mounted) {
        _showSnackBar('Lưu thành công!', Colors.green);
        // Refresh data
        variantVM.fetchVariants(widget.shopProductID!);
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint(' Lỗi lưu: $e');
      if (mounted) {
        _showSnackBar('Lỗi: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}