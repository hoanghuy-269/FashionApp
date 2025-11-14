import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/product_size_model.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_size_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_product_request_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_productvariant_viewmodel.dart';
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
  bool _isSaving = false;
  
  // Map để tracking variant nào đang mở
  final Set<String> _expandedVariants = {};
  
  // ✅ SỬA: Lưu theo cấu trúc Map lồng nhau để tránh nhầm lẫn khi split
  // Format: {variantID: {sizeID: {quantity, price}}}
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
      ),
      body: Consumer<ShopProductVariantViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final variants = vm.variants;
          if (variants.isEmpty) {
            return const Center(child: Text('Không có sản phẩm'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: variants.length,
            itemBuilder: (context, index) {
              final variant = variants[index];
              return _buildVariantCard(variant);
            },
          );
        },
      ),
      bottomNavigationBar: _isSaving
          ? const LinearProgressIndicator()
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _confirmImport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Xác nhận nhập kho',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
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
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedVariants.remove(variantID);
                } else {
                  _expandedVariants.add(variantID);
                }
              });
            },
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: variant.imageUrls?.isNotEmpty == true
                        ? Image.network(
                            variant.imageUrls!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Variant: $variantID',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildSizesList(variantID),
          ],
        ],
      ),
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

        final sizes = snapshot.data!;
        return Column(
          children: sizes.map((size) => _buildSizeItem(variantID, size)).toList(),
        );
      },
    );
  }

  Widget _buildSizeItem(String variantID, ProductSizeModel size) {
    // ✅ Khởi tạo map nếu chưa có
    _importDataMap.putIfAbsent(variantID, () => {});

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String?>(
            future: context.read<SizesViewmodel>().getSizeNameById(size.sizeID),
            builder: (context, snapshot) {
              final sizeName = snapshot.data ?? size.sizeID;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Size: $sizeName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Input giá nhập
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Giá nhập',
              hintText: 'Nhập giá nhập',
              prefixIcon: const Icon(Icons.attach_money, size: 20),
              suffixText: 'đ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            onChanged: (value) {
              final price = double.tryParse(value) ?? 0;
              _importDataMap[variantID]!.putIfAbsent(
                size.sizeID!,
                () => ImportData(quantity: 0, price: price),
              );
              _importDataMap[variantID]![size.sizeID]!.price = price;
            },
          ),

          const SizedBox(height: 12),

          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Số lượng nhập thêm',
              hintText: '0',
              prefixIcon: const Icon(Icons.add_box, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            onChanged: (value) {
              final qty = int.tryParse(value) ?? 0;
              _importDataMap[variantID]!.putIfAbsent(
                size.sizeID,
                () => ImportData(quantity: qty, price: 0),
              );
              _importDataMap[variantID]![size.sizeID]!.quantity = qty;
            },
          ),
          
        ],
      ),
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmImport() async {
    // ✅ Kiểm tra có dữ liệu nhập không
    bool hasData = false;
    for (var variantData in _importDataMap.values) {
      for (var sizeData in variantData.values) {
        if (sizeData.quantity > 0) {
          hasData = true;
          break;
        }
      }
      if (hasData) break;
    }

    if (!hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số lượng cho ít nhất một size!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ Kiểm tra giá nhập
    bool hasInvalidPrice = false;
    for (var variantData in _importDataMap.values) {
      for (var sizeData in variantData.values) {
        if (sizeData.quantity > 0 && sizeData.price <= 0) {
          hasInvalidPrice = true;
          break;
        }
      }
      if (hasInvalidPrice) break;
    }

    if (hasInvalidPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập giá nhập cho tất cả size có số lượng!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ Hiển thị dialog xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận nhập kho'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin nhập hàng:'),
            const SizedBox(height: 8),
            ..._buildConfirmationList(),
            const SizedBox(height: 12),
            const Text(
              'Xác nhận nhập sản phẩm vào kho?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
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

    if (confirm != true) return;

    setState(() => _isSaving = true);

    try {
      final productSizeVM = context.read<ProductSizeViewmodel>();

      // ✅ Xử lý từng variant và size
      for (var variantEntry in _importDataMap.entries) {
        final variantID = variantEntry.key;
        final sizesData = variantEntry.value;

        for (var sizeEntry in sizesData.entries) {
          final sizeID = sizeEntry.key;
          final importData = sizeEntry.value;

          if (importData.quantity > 0) {
            print('📦 Processing: variantID=$variantID, sizeID=$sizeID');
            
            // Lấy size hiện tại
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

            // Tính số lượng mới
            final newQuantity = (currentSize.quantity) + importData.quantity;

            print('   Current: ${currentSize.quantity}, Adding: ${importData.quantity}, New: $newQuantity');

            // ✅ Update với cấu trúc đúng
            await productSizeVM.updateSize(
              widget.shopProductID!,
              variantID,
              ProductSizeModel(
                sizeID: sizeID,
                quantity: newQuantity,
                price: currentSize.price,  // Giữ nguyên giá bán
                costPrice: importData.price,  // Cập nhật giá nhập
              ),
            );

            print('✅ Updated successfully!');
          }
        }
      }

      // Approve request nếu có
      if (widget.productRequestID != null) {
        await context
            .read<ShopProductRequestViewmodel>()
            .approvedRequest(widget.productRequestID!);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã nhập hàng vào kho thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error in _confirmImport: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ✅ Helper để build danh sách xác nhận
  List<Widget> _buildConfirmationList() {
    final List<Widget> widgets = [];
    
    for (var variantEntry in _importDataMap.entries) {
      final sizesData = variantEntry.value;
      
      for (var sizeEntry in sizesData.entries) {
        final sizeID = sizeEntry.key;
        final importData = sizeEntry.value;
        
        if (importData.quantity > 0) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• Size $sizeID: ${importData.quantity} sản phẩm - ${importData.price}đ',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          );
        }
      }
    }
    
    return widgets;
  }
}

class ImportData {
  int quantity;
  double price;

  ImportData({
    required this.quantity,
    required this.price,
  });
}