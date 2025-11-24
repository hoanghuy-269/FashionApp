import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:fashion_app/views/user/widget/product_detail_helper.dart';
import 'package:flutter/material.dart';

class StockDisplayWidget extends StatelessWidget {
  final ShopProductWithDetail product;
  final String selectedSize;
  final int selectedColorIndex;
  final ProductDetailHelper helper;

  const StockDisplayWidget({
    required this.product,
    required this.selectedSize,
    required this.selectedColorIndex,
    required this.helper,
  });

  Stream<List<Map<String, dynamic>>> _getSizesStream(
    ShopProductWithDetail product,
  ) {
    if (product.variants.isEmpty) {
      return Stream.value([]);
    }

    final variantID = product.variants[selectedColorIndex].shopProductVariantID;
    final productID = product.shopProduct.shopproductID;

    return helper.listenSizesByVariant(
      productID: productID,
      variantID: variantID,
    );
  }

  double _getSelectedSizeStock(List<Map<String, dynamic>> currentSizes) {
    if (selectedSize.isEmpty) return 0;

    for (final size in currentSizes) {
      if (size['sizeID'] == selectedSize) {
        return (size['quantity'] as num).toDouble();
      }
    }
    return 0;
  }

  double _getCurrentVariantStock(List<Map<String, dynamic>> currentSizes) {
    double total = 0;
    for (final size in currentSizes) {
      total += (size['quantity'] as num).toDouble();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getSizesStream(product),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "Kho: Đang tải...",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final currentSizes = snapshot.data!;
          final stock =
              selectedSize.isEmpty
                  ? _getCurrentVariantStock(currentSizes)
                  : _getSelectedSizeStock(currentSizes);

          return Text(
            "Kho: ${stock.toInt()}",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          );
        }

        return Text(
          "Kho: 0",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        );
      },
    );
  }
}
