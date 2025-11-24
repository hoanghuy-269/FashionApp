import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'shop_product_model.dart';
import 'products_model.dart';

class ShopProductWithDetail {
  final ShopProductModel shopProduct;
  final ProductsModel productDetail;
  final double lowestPrice;
  final List<ShopProductVariantModel> variants;

  ShopProductWithDetail({
    required this.shopProduct,
    required this.productDetail,
    this.lowestPrice = 0,
    required this.variants,
  });
}
