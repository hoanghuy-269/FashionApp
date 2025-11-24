import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'shop_product_model.dart';
import 'products_model.dart';

class ShopProductWithDetail {
  final ShopProductModel shopProduct;
  final ProductsModel productDetail;
  final double lowestPrice;
  final List<ShopProductVariantModel> variants;
  final int soldQuantity;

  ShopProductWithDetail({
    required this.shopProduct,
    required this.productDetail,
    this.lowestPrice = 0,
    required this.variants,
    this.soldQuantity = 0,
  });

  ShopProductWithDetail copyWith({
    ShopProductModel? shopProduct,
    ProductsModel? productDetail,
    List<ShopProductVariantModel>? variants,
    double? lowestPrice,
    int? soldQuantity,
  }) {
    return ShopProductWithDetail(
      shopProduct: shopProduct ?? this.shopProduct,
      productDetail: productDetail ?? this.productDetail,
      variants: variants ?? this.variants,
      lowestPrice: lowestPrice ?? this.lowestPrice,
      soldQuantity: soldQuantity ?? this.soldQuantity,
    );
  }
}
