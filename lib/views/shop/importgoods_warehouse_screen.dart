import 'package:fashion_app/data/models/shop_product_variant_model.dart';
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
  // bool _isSaving = false;
  
  // // Map lưu số lượng nhập thêm: variantID -> quantity
  // final Map<String, int> _addedQuantities = {};

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.shopProductID != null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       context
  //           .read<ShopProductvariantViewmodel>()
  //           .fetchVariants(widget.shopProductID!);
  //     });
  //   }
  // }

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
    );
  }
  //     body: Consumer<ShopProductvariantViewmodel>(
  //       builder: (context, vm, _) {
  //         if (vm.isLoading) {
  //           return const Center(child: CircularProgressIndicator());
  //         }

  //         final variants = vm.variants;
  //         if (variants.isEmpty) {
  //           return const Center(child: Text('Không có sản phẩm'));
  //         }

  //         return ListView.builder(
  //           padding: const EdgeInsets.all(16),
  //           itemCount: variants.length,
  //           itemBuilder: (context, index) {
  //             final variant = variants[index];
  //             return _buildVariantCard(context, vm, variant);
  //           },
  //         );
  //       },
  //     ),
  //     bottomNavigationBar: _isSaving
  //         ? null
  //         : Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 10,
  //                 ),
  //               ],
  //             ),
  //             child: ElevatedButton(
  //               onPressed: _confirmImport,
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.green,
  //                 padding: const EdgeInsets.symmetric(vertical: 16),
  //               ),
  //               child: const Text(
  //                 'Xác nhận nhập kho',
  //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //               ),
  //             ),
  //           ),
  //   );
  // }

  // Widget _buildVariantCard(
  //   BuildContext context,
  //   ShopProductvariantViewmodel vm,
  //   ShopProductVariantModel variant,
  // ) {
  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Header
  //           Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 12,
  //                   vertical: 6,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: Colors.blue[100],
  //                   borderRadius: BorderRadius.circular(6),
  //                 ),
  //                 child: Text(
  //                   'Size: ${vm.getSizeName(variant.sizeID.first)}',
  //                   style: TextStyle(
  //                     color: Colors.blue[900],
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 12,
  //                   vertical: 6,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: Colors.purple[100],
  //                   borderRadius: BorderRadius.circular(6),
  //                 ),
  //                 child: Text(
  //                   vm.getColorName(variant.colorID),
  //                   style: TextStyle(
  //                     color: Colors.purple[900],
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),

  //           // Info
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               _buildInfo('Giá bán', '${variant.price} đ', Colors.green),
  //               _buildInfo('Giá nhập', '${variant.costPrice} đ', Colors.orange),
  //               _buildInfo('Tồn kho', '${variant.quantity}', Colors.blue),
  //             ],
  //           ),
  //           const SizedBox(height: 12),

  //           // Input số lượng nhập
  //           TextField(
  //             keyboardType: TextInputType.number,
  //             decoration: InputDecoration(
  //               labelText: 'Số lượng nhập thêm',
  //               hintText: '0',
  //               prefixIcon: const Icon(Icons.add_box),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               contentPadding: const EdgeInsets.symmetric(
  //                 horizontal: 16,
  //                 vertical: 12,
  //               ),
  //             ),
  //             onChanged: (value) {
  //               final qty = int.tryParse(value) ?? 0;
  //               variant.quantity. = variant.quantity + qty;
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInfo(String label, String value, Color color) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: TextStyle(fontSize: 11, color: Colors.grey[600]),
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         value,
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w600,
  //           color: color,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Future<void> _confirmImport() async {
  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Xác nhận nhập kho'),
  //       content: const Text(
  //         'Xác nhận nhập sản phẩm vào kho?\nThao tác này không thể hoàn tác.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Hủy'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
  //           child: const Text('Xác nhận'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirm != true) return;

  //   setState(() => _isSaving = true);

  //   try {
  //     final vm = context.read<ShopProductvariantViewmodel>();
      
  //     // Tạo map để update một lần
  //     final updates = <String, Map<String, dynamic>>{};
  //     for (var variant in vm.variants) {
  //       updates[variant.shopProductVariantID] = {
  //         'quantity': variant.quantity,
  //       };
  //     }
      
  //     // Update tất cả variants cùng lúc
  //     await vm.updateMultipleVariants(widget.shopProductID!, updates);

  //     // Cập nhật trạng thái request
  //     await context
  //         .read<ShopProductRequestViewmodel>()
  //         .approvedRequest(widget.productRequestID!);

  //     if (mounted) {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Đã nhập hàng vào kho thành công!'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Lỗi: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isSaving = false);
  //   }
  // }
}