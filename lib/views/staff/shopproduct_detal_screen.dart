import 'package:fashion_app/core/utils/colorhelper.dart';
import 'package:fashion_app/viewmodels/shop_productvariant_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopproductDetalScreen extends StatefulWidget {
  final String? shopID;
  final String? productDetailID;
  const ShopproductDetalScreen({super.key, this.shopID, this.productDetailID});

  @override
  State<ShopproductDetalScreen> createState() => _ShopproductDetalScreenState();
}

class _ShopproductDetalScreenState extends State<ShopproductDetalScreen> {
  // @override
  // void initState() {
  //   super.initState();
    
  //   final productdetalID = widget.productDetailID;
  //   print("productDetailID in initState: $productdetalID");
    
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<ShopProductvariantViewmodel>().fetchVariants(
  //       productdetalID ?? '',
  //     );
  //   });
  // }

  // Future<void> dialogSend(){
  //   return showDialog(context: context, builder: (context) => AlertDialog(
  //     title: Text(" Yêu cầu nhập sản phẩm mới "),
  //     content: Text(" Bạn có chắc chắn muốn gửi sản phẩm này  không ? "),
  //     actions: [
  //       TextButton(
  //         onPressed: (){
  //           Navigator.pop(context);
  //         },
  //         child: Text("Hủy"),
  //       ),
  //       TextButton(
  //         onPressed: (){
           
  //           Navigator.pop(context);
  //         },
  //         child: Text("Gửi"),
  //       ),
  //     ],
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    //   return Scaffold(
    //     body: Consumer<ShopProductvariantViewmodel>(
    //       builder: (context, shoproductvariantVM, _) {
    //         if (shoproductvariantVM.isLoading) {
    //           return Center(child: CircularProgressIndicator());
    //         }
            
    //         if (shoproductvariantVM.variants.isEmpty) {
    //           return Center(
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(Icons.inbox, size: 80, color: Colors.grey),
    //                 SizedBox(height: 16),
    //                 Text('Không có biến thể sản phẩm'),
    //               ],
    //             ),
    //           );
    //         }
            
    //         return SafeArea(
    //           child: Column(
    //             children: [
    //               // Header
    //               Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //                 child: Row(
    //                   children: [
    //                     IconButton(
    //                       onPressed: () {
    //                         Navigator.pop(context);
    //                       },
    //                       icon: Icon(Icons.arrow_back),
    //                     ),
    //                     const SizedBox(width: 8),
    //                     const Text(
    //                       "Chi tiết sản phẩm",
    //                       style: TextStyle(
    //                         fontSize: 20,
    //                         fontWeight: FontWeight.bold,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               const Divider(height: 1),
                  
    //               // List variants - GROUPED BY COLOR
    //               Expanded(
    //                 child: Builder(
    //                   builder: (context) {
                      
    //                     final groupedVariants = shoproductvariantVM.getGroupedVariants();
                        
    //                     if (groupedVariants.isEmpty) {
    //                       return Center(
    //                         child: Text('Không có biến thể'),
    //                       );
    //                     }
                        
    //                     return ListView.builder(
    //                       padding: EdgeInsets.all(8),
    //                       itemCount: groupedVariants.length,
    //                       itemBuilder: (context, index) {
                        
    //                         final group = groupedVariants[index];
                            
    //                         final colorID = group['colorID'] as String;
    //                         final imageUrl = group['imageUrl'] as String;
    //                         final price = group['price'] as num;
    //                         final sizeIDs = group['sizeIDs'] as List<String>;
    //                         final quantities = group['quantities'] as Map<String, int>;
                            
    //                         final colorName = shoproductvariantVM.getColorName(colorID);
    //                         final colorHex = shoproductvariantVM.getColorHex(colorID);
    //                         final color = ColorHelper.hexToColor(colorHex);
                            
    //                         // Tính tổng số lượng
    //                         final totalQuantity = quantities.values.fold<int>(0, (sum, qty) => sum + qty);
                            
    //                         return Card(
    //                           margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    //                           elevation: 2,
    //                           shape: RoundedRectangleBorder(
    //                             borderRadius: BorderRadius.circular(12),
    //                           ),
    //                           child: Padding(
    //                             padding: EdgeInsets.all(12),
    //                             child: Row(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 // Hình ảnh
    //                                 ClipRRect(
    //                                   borderRadius: BorderRadius.circular(8),
    //                                   child: Image.network(
    //                                     imageUrl,
    //                                     width: 80,
    //                                     height: 80,
    //                                     fit: BoxFit.cover,
    //                                     errorBuilder: (_, __, ___) => Container(
    //                                       width: 80,
    //                                       height: 80,
    //                                       color: Colors.grey[300],
    //                                       child: Icon(Icons.image_not_supported, size: 40),
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 SizedBox(width: 12),
                                    
    //                                 // Thông tin
    //                                 Expanded(
    //                                   child: Column(
    //                                     crossAxisAlignment: CrossAxisAlignment.start,
    //                                     children: [
    //                                       // Màu sắc với ô màu
    //                                       Row(
    //                                         children: [
    //                                           Container(
    //                                             width: 28,
    //                                             height: 28,
    //                                             decoration: BoxDecoration(
    //                                               color: color,
    //                                               border: Border.all(
    //                                                 color: Colors.grey[400]!,
    //                                                 width: 2,
    //                                               ),
    //                                               borderRadius: BorderRadius.circular(6),
    //                                               boxShadow: [
    //                                                 BoxShadow(
    //                                                   color: Colors.black12,
    //                                                   blurRadius: 3,
    //                                                   offset: Offset(0, 2),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ),
    //                                           SizedBox(width: 8),
    //                                           Expanded(
    //                                             child: Text(
    //                                               colorName,
    //                                               style: TextStyle(
    //                                                 fontSize: 16,
    //                                                 fontWeight: FontWeight.bold,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                       SizedBox(height: 8),
                                          
    //                                       // ✅ Kích thước - HIỂN THỊ LIST CHIPS
    //                                       Row(
    //                                         children: [
    //                                           Icon(Icons.straighten, 
    //                                               size: 16, 
    //                                               color: Colors.grey[600]),
    //                                           SizedBox(width: 4),
    //                                           Expanded(
    //                                             child: Wrap(
    //                                               spacing: 6,
    //                                               runSpacing: 6,
    //                                               children: sizeIDs.map((sizeID) {
    //                                                 final sizeName = shoproductvariantVM.getSizeName(sizeID);
    //                                                 final qty = quantities[sizeID] ?? 0;
                                                    
    //                                                 return Container(
    //                                                   padding: EdgeInsets.symmetric(
    //                                                     horizontal: 8,
    //                                                     vertical: 4,
    //                                                   ),
    //                                                   decoration: BoxDecoration(
    //                                                     color: Colors.blue[50],
    //                                                     border: Border.all(
    //                                                       color: Colors.blue[200]!,
    //                                                       width: 1,
    //                                                     ),
    //                                                     borderRadius: BorderRadius.circular(6),
    //                                                   ),
    //                                                   child: Text(
    //                                                     '$sizeName ($qty)',
    //                                                     style: TextStyle(
    //                                                       fontSize: 12,
    //                                                       fontWeight: FontWeight.w600,
    //                                                       color: Colors.blue[700],
    //                                                     ),
    //                                                   ),
    //                                                 );
    //                                               }).toList(),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                       SizedBox(height: 8),
                                          
    //                                       // Số lượng và giá
    //                                       Row(
    //                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                         children: [
    //                                           Container(
    //                                             padding: EdgeInsets.symmetric(
    //                                               horizontal: 10,
    //                                               vertical: 4,
    //                                             ),
    //                                             decoration: BoxDecoration(
    //                                               color: totalQuantity > 0
    //                                                   ? Colors.green[50]
    //                                                   : Colors.red[50],
    //                                               borderRadius: BorderRadius.circular(6),
    //                                             ),
    //                                             child: Text(
    //                                               'Tổng SL: $totalQuantity',
    //                                               style: TextStyle(
    //                                                 color: totalQuantity > 0
    //                                                     ? Colors.green[700]
    //                                                     : Colors.red[700],
    //                                                 fontWeight: FontWeight.bold,
    //                                                 fontSize: 12,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           Text(
    //                                             '${price.toStringAsFixed(0)}đ',
    //                                             style: TextStyle(
    //                                               fontSize: 16,
    //                                               fontWeight: FontWeight.bold,
    //                                               color: Colors.red,
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                         );
    //                       },
    //                     );
    //                   },
    //                 ),
    //               ),
    //             ],
    //           ),
    //         );
    //       },
    //     ),
    //   );
    // }
    return Scaffold(
      body: Center(
        child: Text('Chi tiết sản phẩm'),
      ),
    );
  }
}