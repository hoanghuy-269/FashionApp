import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';

class ProductDetailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, String> _sizeNameCache = {};
  final Map<String, String> _colorNameCache = {};

  // ==================== LOAD SIZES ====================

  /// Load toàn bộ size từ collection sizes
  Future<void> loadAllSizes() async {
    final snapshot = await _firestore.collection('sizes').get();
    for (var doc in snapshot.docs) {
      final name = doc.data()['name'] as String? ?? 'Unknown';
      _sizeNameCache[doc.id] = name;
    }
  }

  // ==================== LOAD BRAND + SHOP ====================

  Future<Map<String, String?>> loadAdditionalInfo({
    required String? brandID,
    required String? shopId,
  }) async {
    try {
      String? brandName;
      String? shopAddress;

      if (brandID != null) {
        final doc = await _firestore.collection('brands').doc(brandID).get();
        brandName = doc.data()?['name'];
      }

      if (shopId != null) {
        final doc = await _firestore.collection('shops').doc(shopId).get();
        shopAddress = doc.data()?['address'];
      }

      return {'brandName': brandName, 'shopAddress': shopAddress};
    } catch (_) {
      return {'brandName': null, 'shopAddress': null};
    }
  }

  // ==================== REAL-TIME SIZES ====================

  Stream<List<Map<String, dynamic>>> listenSizesByVariant({
    required String productID,
    required String variantID,
  }) {
    return _firestore
        .collection('shop_products')
        .doc(productID)
        .collection('shop_product_variants')
        .doc(variantID)
        .collection('product_sizes')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return {
              'sizeID': doc.id,
              'name': _sizeNameCache[doc.id] ?? 'Unknown',
              'quantity': data['quantity'] ?? 0,
              'price': _normalizePrice(data['price']),
            };
          }).toList();
        });
  }

  // ==================== LOAD SIZES (ONE TIME) ====================

  Future<List<Map<String, dynamic>>> loadSizesByVariant({
    required String productID,
    required String variantID,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('shop_products')
              .doc(productID)
              .collection('shop_product_variants')
              .doc(variantID)
              .collection('product_sizes')
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'sizeID': doc.id,
          'name': _sizeNameCache[doc.id] ?? 'Unknown',
          'quantity': data['quantity'] ?? 0,
          'price': _normalizePrice(data['price']),
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ==================== UTILS ====================

  /// Convert any price type to double
  double _normalizePrice(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price.toDouble();
    if (price is double) return price;
    if (price is num) return price.toDouble();
    return 0;
  }

  /// Lấy tên màu
  String getColorName(String colorID) {
    if (_colorNameCache.containsKey(colorID)) {
      return _colorNameCache[colorID]!;
    }

    final colorName = "Màu ${colorID.split('_').last}";
    _colorNameCache[colorID] = colorName;
    return colorName;
  }

  /// Lấy tên size
  String getSizeName(String sizeID, List<Map<String, dynamic>> sizes) {
    if (_sizeNameCache.containsKey(sizeID)) {
      return _sizeNameCache[sizeID]!;
    }

    final size = sizes.firstWhere(
      (s) => s['sizeID'] == sizeID,
      orElse: () => {'name': sizeID},
    );

    final name = size['name'] as String? ?? sizeID;
    _sizeNameCache[sizeID] = name;
    return name;
  }

  /// Lấy số lượng size
  int getSizeQuantity(String sizeID, List<Map<String, dynamic>> sizes) {
    try {
      return sizes.firstWhere((s) => s['sizeID'] == sizeID)['quantity']
              as int? ??
          0;
    } catch (_) {
      return 0;
    }
  }

  /// Lấy giá size
  double getSizePrice(String sizeID, List<Map<String, dynamic>> sizes) {
    try {
      final price = sizes.firstWhere((s) => s['sizeID'] == sizeID)['price'];
      return _normalizePrice(price);
    } catch (_) {
      return 0;
    }
  }

  /// Lấy giá thấp nhất
  double getMinPrice(List<Map<String, dynamic>> sizes) {
    final prices =
        sizes
            .map((s) => _normalizePrice(s['price']))
            .where((p) => p > 0)
            .toList();

    if (prices.isEmpty) return 0;

    prices.sort();
    return prices.first;
  }

  /// Lấy tất cả ảnh từ variants
  List<String> getProductImages(List<ShopProductVariantModel> variants) {
    return variants
        .map((v) => v.imageUrls)
        .where((url) => url.isNotEmpty)
        .toList();
  }
}
