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
  @override
  void initState() {
    super.initState();
    
    final productdetalID = widget.productDetailID;
    print("productDetailID in initState: $productdetalID");
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProductvariantViewmodel>().fetchVariants(
        productdetalID ?? '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ShopProductvariantViewmodel>(
        builder: (context, shoproductvariantVM, _) {
          if (shoproductvariantVM.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (shoproductvariantVM.variants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Không có biến thể sản phẩm'),
                ],
              ),
            );
          }
          
          return SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Chi tiết sản phẩm",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // List variants
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: shoproductvariantVM.variants.length,
                    itemBuilder: (context, index) {
                      // ✅ Khai báo variant trước
                      final variant = shoproductvariantVM.variants[index];
                      
                      // ✅ Sau đó mới dùng variant
                      final colorName = shoproductvariantVM.getColorName(variant.colorID);
                      final colorHex = shoproductvariantVM.getColorHex(variant.colorID);
                      final color = ColorHelper.hexToColor(colorHex);
                      
                      // Lấy tên các size
                      final sizeNames = variant.sizeIDS
                          .map((sizeID) => shoproductvariantVM.getSizeName(sizeID))
                          .join(', ');
                      
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hình ảnh
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  variant.imageUrls,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported, size: 40),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              
                              // Thông tin
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Màu sắc với ô màu
                                    Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: color,
                                            border: Border.all(
                                              color: Colors.grey[400]!,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 3,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            colorName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    
                                    // Kích thước
                                    Row(
                                      children: [
                                        Icon(Icons.straighten, 
                                            size: 16, 
                                            color: Colors.grey[600]),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Size: $sizeNames',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    
                                    // Số lượng và giá
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: variant.quantity > 0
                                                ? Colors.green[50]
                                                : Colors.red[50],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'SL: ${variant.quantity}',
                                            style: TextStyle(
                                              color: variant.quantity > 0
                                                  ? Colors.green[700]
                                                  : Colors.red[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${variant.price.toStringAsFixed(0)}đ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Nút edit
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  // Xử lý chỉnh sửa
                                  print('Edit variant: ${variant.shopProductVariantID}');
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}