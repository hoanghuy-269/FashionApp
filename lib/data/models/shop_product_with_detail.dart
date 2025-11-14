import 'shop_product_model.dart';
import 'products_model.dart';

class ShopProductWithDetail {
  final ShopProductModel shopProduct;
  final ProductsModel productDetail;
  final double lowestPrice;

  ShopProductWithDetail({
    required this.shopProduct,
    required this.productDetail,
    this.lowestPrice = 0,
  });
}
