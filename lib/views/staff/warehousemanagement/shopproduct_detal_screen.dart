import 'package:fashion_app/data/models/product_size_model.dart';
import 'package:fashion_app/data/sources/color_source.dart';
import 'package:fashion_app/viewmodels/colors_viewmodel.dart';
import 'package:fashion_app/viewmodels/sizes_viewmodel.dart';
import 'package:fashion_app/viewmodels/product_size_viewmodel.dart';
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
  ColorsViewmodel colorsViewmodel = ColorsViewmodel();
  
  @override
  void initState() {
    super.initState();
    
    final productdetalID = widget.productDetailID;
    print("productDetailID in initState: $productdetalID");
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ColorsViewmodel>().fetchAllColors();
            context.read<ShopProductVariantViewModel>().fetchVariants(
        productdetalID ?? '',
      );
    });
  }

  Future<void> dialogSend() {
    return showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("Yêu cầu nhập sản phẩm mới"),
        content: Text("Bạn có chắc chắn muốn gửi sản phẩm này không?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement send logic
              Navigator.pop(context);
            },
            child: Text("Gửi"),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ShopProductVariantViewModel>(
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
                
                // List variants với sizes
                Expanded(
                  child: ListView.builder(
                    itemCount: shoproductvariantVM.variants.length,
                    itemBuilder: (context, index) {
                      final variant = shoproductvariantVM.variants[index];
                      final colorID = variant.colorID;
                      final imageURL = variant.imageUrls ?? '';
                      final variantID = variant.shopProductVariantID;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: ExpansionTile(
                          leading: imageURL.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageURL,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.broken_image, color: Colors.grey),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.image, size: 30, color: Colors.grey),
                                ),
                          title: Row(
                            children: [
                              Text(
                                'Màu: ',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              FutureBuilder<Color>(
                                future: colorsViewmodel.getColorFromFirestore(colorID),
                                builder: (context, snapshot) {
                                  return Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: snapshot.data ?? Colors.grey,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: snapshot.connectionState == ConnectionState.waiting
                                        ? SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : null,
                                  );
                                },
                              ),
                              SizedBox(width: 8),
                              
                              Consumer<ColorsViewmodel>(
                                builder: (context, colorVM, _) {
                                  final colorName = colorVM.getColorNameById(colorID);
                                  return Text(
                                    colorName ?? colorID ?? 'Không xác định',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  );
                                },
                              ),
                            ],
                          ),
                          subtitle: Text('Variant ID: $variantID'),
                          children: [
                            FutureBuilder<List<ProductSizeModel>>(
                              future: context.read<ProductSizeViewmodel>().getSizesForVariant(
                                widget.productDetailID ?? '',
                                variantID,
                              ),
                              
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.red),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Lỗi: ${snapshot.error}',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Empty state
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.inbox_outlined, 
                                            size: 40, 
                                            color: Colors.grey[400]
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Chưa có size cho variant này',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final sizes = snapshot.data!;
                                return Column(
                                  children: [
                                    ...sizes.map((size) {
                                      return ListTile(
                                        title: FutureBuilder<String?>(
                                          future: context.read<SizesViewmodel>().getSizeNameById(size.sizeID ?? ''),
                                          builder: (context, sizeSnapshot) {
                                            if (sizeSnapshot.connectionState == ConnectionState.waiting) {
                                              return Row(
                                                children: [
                                                  Text(
                                                    'Size: ',
                                                    style: TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                  SizedBox(
                                                    width: 12,
                                                    height: 12,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                ],
                                              );
                                            }
                                            
                                            final sizeName = sizeSnapshot.data ?? size.sizeID ?? 'N/A';
                                            return Text(
                                              'Size: $sizeName',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            );
                                          },
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.inventory_2_outlined, 
                                                  size: 16, 
                                                  color: Colors.grey[600]
                                                ),
                                                SizedBox(width: 4),
                                                Text('Số lượng: ${size.quantity ?? 0}'),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: Text(
                                          '${size.price ?? 0}đ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                );
                              },
                            ),
                          ],
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