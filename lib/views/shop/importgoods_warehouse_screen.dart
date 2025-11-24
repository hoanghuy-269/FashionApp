import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/product_size_model.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_size_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_request_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_productvariant_viewmodel.dart';
import 'package:fashion_app/views/shop/add_importgoods/add_new_variant_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImportgoodsWarehouseScreen extends StatefulWidget {
  final String? shopProductID;
  final String? productRequestID;

  const ImportgoodsWarehouseScreen({
    super.key,
    this.shopProductID,
    this.productRequestID,
  });

  @override
  State<ImportgoodsWarehouseScreen> createState() =>
      _ImportgoodsWarehouseScreenState();
}

class _ImportgoodsWarehouseScreenState
    extends State<ImportgoodsWarehouseScreen> {
  final Set<String> _expandedVariants = {};

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
      ),
      body: Consumer<ShopProductVariantViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildAddVariantButton(),
              Expanded(
                child:
                    vm.variants.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: vm.variants.length,
                          itemBuilder:
                              (context, index) =>
                                  _buildVariantCard(vm.variants[index]),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddVariantButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddVariantDialog,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Nhập Sản phẩm mới',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
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
          const SizedBox(height: 8),
          Text(
            'Nhấn nút ở trên để thêm variant mới',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddVariantDialog() async {
    if (widget.shopProductID == null) {
      _showSnackBar('Không có thông tin sản phẩm!', Colors.red);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) =>
              AddNewVariantScreen(shopProductID: widget.shopProductID!),
    );

    if (result == true && mounted) {
      context.read<ShopProductVariantViewModel>().fetchVariants(
        widget.shopProductID!,
      );
    }
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
      child:
          imageUrl?.isNotEmpty == true
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
          children:
              snapshot.data!.map((size) => _buildSizeItem(size)).toList(),
        );
      },
    );
  }

  Widget _buildSizeItem(ProductSizeModel size) {
    return FutureBuilder<String?>(
      future: context.read<SizesViewmodel>().getSizeNameById(size.sizeID),
      builder: (context, snapshot) {
        final sizeName = snapshot.data ?? size.sizeID;
        
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
              
              // Thông tin chi tiết
              Row(
                children: [
                  // Giá bán
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giá bán',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${size.price}đ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Giá nhập
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giá nhập',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${size.costPrice}đ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tồn kho
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tồn kho',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${size.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
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

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}