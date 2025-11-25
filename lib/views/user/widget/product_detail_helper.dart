import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';

class ProductDetailHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, String> _sizeNameCache = {};
  final Map<String, String> _colorNameCache = {};
  Map<String, String> get sizeNameCache => _sizeNameCache;
  bool get isSizeCacheLoaded => _sizeNameCache.isNotEmpty;

  // ==================== HÀM LOAD DỮ LIỆU ====================

  /// Load brand name và shop address
  Future<Map<String, dynamic>> loadAdditionalInfo({
    required String? brandID,
    required String? shopId,
  }) async {
    try {
      String? brandName;
      String? shopAddress;

      // Load brand name
      if (brandID != null) {
        final brandDoc =
            await _firestore.collection('brands').doc(brandID).get();
        if (brandDoc.exists) {
          brandName = brandDoc.data()?['name'] as String?;
        }
      }

      // Load shop address
      if (shopId != null) {
        final shopDoc = await _firestore.collection('shops').doc(shopId).get();
        if (shopDoc.exists) {
          shopAddress = shopDoc.data()?['address'] as String?;
        }
      }

      return {
        'brandName': brandName,
        'shopAddress': shopAddress,
        'isLoading': false,
      };
    } catch (e) {
      print("❌ Lỗi load additional info: $e");
      return {'brandName': null, 'shopAddress': null, 'isLoading': false};
    }
  }

  // Trong ProductDetailHelper class
  Future<QuerySnapshot> getProductReviewsFuture(String shopProductId) async {
    try {
      print('🔄 Đang lấy reviews cho shopProductId: $shopProductId');

      final result =
          await FirebaseFirestore.instance
              .collection('shop_product_reviews')
              .where('shopProductId', isEqualTo: shopProductId)
              .orderBy('createdAt', descending: true)
              .get();

      print('✅ Lấy được ${result.docs.length} reviews');

      // Debug: in ra từng review
      for (final doc in result.docs) {
        final data = doc.data();
        print('📝 Review: ${data['rating']} sao - "${data['reviewText']}"');
      }

      return result;
    } catch (e) {
      print('❌ Lỗi khi lấy reviews: $e');
      rethrow;
    }
  }

  // Giữ lại stream method nếu cần real-time updates
  Stream<QuerySnapshot> getProductReviewsStream(String shopProductId) {
    return FirebaseFirestore.instance
        .collection('shop_product_reviews')
        .where('shopProductId', isEqualTo: shopProductId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Load tất cả sizes từ collection sizes
  Future<void> loadAllSizes() async {
    final snapshot = await _firestore.collection('sizes').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final name = data['name'] as String? ?? 'Unknown';
      _sizeNameCache[doc.id] = name;
    }
  }

  // ==================== HÀM LẮNG NGHE REAL-TIME ====================

  /// Lắng nghe sizes theo variant (real-time)
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
              'price': (data['price'] as num?)?.toDouble() ?? 0,
            };
          }).toList();
        });
  }

  List<String> getProductImages(List<ShopProductVariantModel> variants) {
    return variants
        .map((variant) => variant.imageUrls)
        .where((imageUrl) => imageUrl.isNotEmpty)
        .toList();
  }

  /// Lấy tên màu
  // Trong ProductDetailHelper class
  // Trong ProductDetailHelper class
  Future<String> getColorName(String colorID) async {
    try {
      // Lấy dữ liệu màu từ Firebase
      final doc =
          await FirebaseFirestore.instance
              .collection('colors')
              .doc(colorID)
              .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? 'Màu không xác định';
      } else {
        return 'Màu không xác định';
      }
    } catch (e) {
      print('❌ Lỗi lấy tên màu: $e');
      return 'Màu không xác định';
    }
  }

  /// Lấy tên size
  String getSizeName(String sizeID, List<Map<String, dynamic>> sizes) {
    // Ưu tiên lấy từ cache
    if (_sizeNameCache.containsKey(sizeID)) {
      return _sizeNameCache[sizeID]!;
    }

    // Nếu không có trong cache, tìm trong sizes list
    try {
      final size = sizes.firstWhere((size) => size['sizeID'] == sizeID);
      final sizeName = size['name'] as String? ?? 'Unknown';
      _sizeNameCache[sizeID] = sizeName; // Cache lại
      return sizeName;
    } catch (e) {
      // Fallback: trả về sizeID nếu không tìm thấy
      return sizeID;
    }
  }

  /// Lấy số lượng size
  int getSizeQuantity(String sizeID, List<Map<String, dynamic>> sizes) {
    if (sizeID.isEmpty) return 0;

    try {
      final size = sizes.firstWhere((size) => size['sizeID'] == sizeID);
      return size['quantity'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Lấy giá size
  double getSizePrice(String sizeID, List<Map<String, dynamic>> sizes) {
    if (sizeID.isEmpty) return 0;

    try {
      final size = sizes.firstWhere((s) => s['sizeID'] == sizeID);
      final price = size['price'];
      if (price == null) return 0;
      return (price as num).toDouble();
    } catch (e) {
      return 0;
    }
  }

  /// Lấy giá thấp nhất
  double getMinPrice(List<Map<String, dynamic>> sizes) {
    if (sizes.isEmpty) return 0;

    try {
      final prices =
          sizes
              .map((s) {
                final price = s['price'];
                if (price == null) return 0.0;
                return (price as num).toDouble();
              })
              .where((price) => price > 0)
              .toList();

      if (prices.isEmpty) return 0;
      prices.sort();
      return prices.first;
    } catch (e) {
      return 0;
    }
  }
  // ==================== HÀM FORMAT TIỀN ====================

  /// Format số tiền với định dạng VND (cứ 3 số 0 là 1 chấm)
  String formatPrice(double price, {bool showSuffix = true}) {
    if (price == 0) return showSuffix ? '0đ' : '0';

    // Chuyển thành số nguyên để loại bỏ phần thập phân
    int intPrice = price.toInt();

    // Format cứ 3 chữ số thêm 1 dấu chấm
    String priceStr = intPrice.toString();
    String result = '';
    int count = 0;

    // Duyệt từ cuối chuỗi lên đầu
    for (int i = priceStr.length - 1; i >= 0; i--) {
      result = priceStr[i] + result;
      count++;
      // Thêm dấu chấm sau mỗi 3 chữ số (trừ chữ số đầu tiên)
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }

    return showSuffix ? '${result}đ' : result;
  }

  /// Format từ số nguyên (Firestore thường lưu dạng num)
  String formatPriceFromNum(num price, {bool showSuffix = true}) {
    return formatPrice(price.toDouble(), showSuffix: showSuffix);
  }

  // ==================== CÁC HÀM HIỆN TẠI (SỬA LẠI) ====================

  /// Lấy giá size đã format
  String getFormattedSizePrice(
    String sizeID,
    List<Map<String, dynamic>> sizes,
  ) {
    final price = getSizePrice(sizeID, sizes);
    return formatPrice(price);
  }

  /// Lấy giá thấp nhất đã format
  String getFormattedMinPrice(List<Map<String, dynamic>> sizes) {
    final minPrice = getMinPrice(sizes);
    return formatPrice(minPrice);
  }

  /// Lấy khoảng giá (min - max)
  String getPriceRange(List<Map<String, dynamic>> sizes) {
    if (sizes.isEmpty) return formatPrice(0);

    try {
      final prices =
          sizes
              .map((s) {
                final price = s['price'];
                if (price == null) return 0.0;
                return (price as num).toDouble();
              })
              .where((price) => price > 0)
              .toList();

      if (prices.isEmpty) return formatPrice(0);

      prices.sort();
      final minPrice = prices.first;
      final maxPrice = prices.last;

      if (minPrice == maxPrice) {
        return formatPrice(minPrice);
      } else {
        return '${formatPrice(minPrice)} - ${formatPrice(maxPrice)}';
      }
    } catch (e) {
      return formatPrice(0);
    }
  }

  // ==================== HÀM GIỎ HÀNG & HIỆU ỨNG ====================

  /// Stream số lượng item trong giỏ hàng
  Stream<int> getCartItemCountStream(String? userId) {
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('cart_items')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
  Future<bool> isItemInCart(String userId, String cartItemId) async {
    try {
      final doc =
          await _firestore
              .collection('carts')
              .doc(userId)
              .collection('cart_items')
              .doc(cartItemId)
              .get();

      return doc.exists;
    } catch (e) {
      print("❌ Lỗi kiểm tra item trong giỏ hàng: $e");
      return false;
    }
  }

  /// Lấy số lượng item hiện tại trong giỏ hàng
  Future<int> getCurrentCartCount(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('carts')
              .doc(userId)
              .collection('cart_items')
              .get();

      return snapshot.size;
    } catch (e) {
      print("❌ Lỗi lấy số lượng giỏ hàng: $e");
      return 0;
    }
  }

  /// Tạo cart item ID duy nhất
  String generateCartItemId({
    required String productId,
    required String colorId,
    required String sizeId,
  }) {
    return '${productId}_${colorId}_$sizeId';
  }

  /// Kiểm tra và trả về trạng thái hiệu ứng
  /// Return true nếu là sản phẩm mới (cần hiệu ứng), false nếu đã có
  Future<Map<String, dynamic>> checkCartAnimationStatus({
    required String userId,
    required String productId,
    required String colorId,
    required String sizeId,
  }) async {
    try {
      final cartItemId = generateCartItemId(
        productId: productId,
        colorId: colorId,
        sizeId: sizeId,
      );

      final currentCount = await getCurrentCartCount(userId);
      final isExistingItem = await isItemInCart(userId, cartItemId);

      return {
        'shouldAnimate': !isExistingItem, // Hiệu ứng chỉ cho sản phẩm mới
        'isExistingItem': isExistingItem,
        'currentCartCount': currentCount,
        'cartItemId': cartItemId,
      };
    } catch (e) {
      print("❌ Lỗi kiểm tra trạng thái hiệu ứng: $e");
      return {
        'shouldAnimate': true, // Mặc định có hiệu ứng nếu có lỗi
        'isExistingItem': false,
        'currentCartCount': 0,
        'cartItemId': '',
      };
    }
  }

  /// Phương thức tiện ích để thêm item vào giỏ hàng với kiểm tra hiệu ứng
  Future<Map<String, dynamic>> addToCartWithAnimationCheck({
    required String userId,
    required String productId,
    required String productName,
    required String variantId,
    required String shopId,
    required String colorId,
    required String sizeId,
    required int quantity,
    required double price,
    required String imageUrl,
  }) async {
    try {
      // Kiểm tra trạng thái hiệu ứng trước khi thêm
      final animationStatus = await checkCartAnimationStatus(
        userId: userId,
        productId: productId,
        colorId: colorId,
        sizeId: sizeId,
      );

      final cartItemId = animationStatus['cartItemId'] as String;

      // Thêm hoặc cập nhật item trong giỏ hàng
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('cart_items')
          .doc(cartItemId)
          .set({
            'productId': productId,
            'productName': productName,
            'variantId': variantId,
            'shopId': shopId,
            'colorId': colorId,
            'sizeId': sizeId,
            'quantity': quantity,
            'price': price,
            'imageUrl': imageUrl,
            'addedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Lấy số lượng mới sau khi thêm
      final newCount = await getCurrentCartCount(userId);

      return {
        'success': true,
        'shouldAnimate': animationStatus['shouldAnimate'] as bool,
        'isExistingItem': animationStatus['isExistingItem'] as bool,
        'previousCartCount': animationStatus['currentCartCount'] as int,
        'newCartCount': newCount,
        'cartItemId': cartItemId,
      };
    } catch (e) {
      print("Lỗi thêm vào giỏ hàng: $e");
      return {
        'success': false,
        'shouldAnimate': false,
        'isExistingItem': false,
        'previousCartCount': 0,
        'newCartCount': 0,
        'cartItemId': '',
        'error': e.toString(),
      };
    }
  }

  /// Stream theo dõi thay đổi cụ thể của một item trong giỏ hàng
  Stream<Map<String, dynamic>>? watchCartItem(
    String userId,
    String cartItemId,
  ) {
    if (userId.isEmpty || cartItemId.isEmpty) return null;

    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('cart_items')
        .doc(cartItemId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return {'exists': false};
          }

          final data = doc.data()!;
          return {
            'exists': true,
            'quantity': data['quantity'] ?? 0,
            'price': (data['price'] as num?)?.toDouble() ?? 0,
            'updatedAt': data['updatedAt'],
          };
        });
  }
}
