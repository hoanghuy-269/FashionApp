import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/product_size_model.dart';

class ProductSizeSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<String> addOrUpdateSize({
    required String shopProductID,
    required String variantID,
    required ProductSizeModel size,
  }) async {
    if (shopProductID.isEmpty) throw ArgumentError('shopProductID is required');
    if (variantID.isEmpty) throw ArgumentError('variantID is required');
    if (size.sizeID == null || size.sizeID!.isEmpty) {
      throw ArgumentError('sizeID is required');
    }

    try {
      final sizeID = size.sizeID!;
      
      // 1. Kiểm tra size đã tồn tại chưa
      final exists = await sizeExists(shopProductID, variantID, sizeID);

      if (exists) {
        // 2a. Đã tồn tại → Cập nhật (increment quantity)
        
        final docRef = _firestore
            .collection('shop_products')
            .doc(shopProductID)
            .collection('shop_product_variants')
            .doc(variantID)
            .collection('product_sizes')
            .doc(sizeID);

        await docRef.update({
          'quantity': FieldValue.increment(size.quantity ?? 0),
          'costPrice': size.costPrice,
          'price': size.price,
        });

        print('✅ Đã cập nhật size: +${size.quantity} items');
        return sizeID;
      } else {        
        return await addProductSize(shopProductID, variantID, size);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 🆕 THÊM MỚI: Lấy tất cả sizes của một sizeID cụ thể (để tính tổng)
  Future<int> getTotalQuantityBySize({
    required String shopProductID,
    required String sizeID,
  }) async {
    try {
      int totalQty = 0;

      // Lấy tất cả variants
      final variantsSnapshot = await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .get();

      // Duyệt qua từng variant và cộng dồn quantity của size này
      for (var variantDoc in variantsSnapshot.docs) {
        final sizeDoc = await _firestore
            .collection('shop_products')
            .doc(shopProductID)
            .collection('shop_product_variants')
            .doc(variantDoc.id)
            .collection('product_sizes')
            .doc(sizeID)
            .get();

        if (sizeDoc.exists) {
          final data = sizeDoc.data();
          totalQty += (data?['quantity'] as int? ?? 0);
        }
      }

      return totalQty;
    } catch (e) {
      print('❌ Error getTotalQuantityBySize: $e');
      return 0;
    }
  }

  /// Lấy tất cả sizes (ít dùng, chỉ cho mục đích test)
  Future<List<ProductSizeModel>> getAllSizes() async {
    try {
      final query = await _firestore.collection('product_sizes').get();
      final List<ProductSizeModel> sizes = [];
      for (var doc in query.docs) {
        final data = doc.data();
        data['sizeID'] = doc.id;
        sizes.add(ProductSizeModel.fromMap(data));
      }
      return sizes;
    } catch (e) {
      print('❌ Error getAllSizes: $e');
      rethrow;
    }
  }
  

  /// ✅ Lấy sizes theo variant - CẤU TRÚC ĐÚNG
  /// Path: shop_products/{shopProductID}/shop_product_variants/{variantID}/product_sizes
  Future<List<ProductSizeModel>> getSizesByVariant(
    String shopProductID,
    String variantID,
  ) async {
    try {
      print('📍 Getting sizes: shop_products/$shopProductID/shop_product_variants/$variantID/product_sizes');
      
      final snapshot = await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .doc(variantID)
          .collection('product_sizes')
          .get();

      final sizes = snapshot.docs.map((doc) {
        final data = doc.data();
        data['sizeID'] = doc.id; // Đảm bảo sizeID = document ID
        return ProductSizeModel.fromMap(data);
      }).toList();

      print('✅ Found ${sizes.length} sizes');
      return sizes;
    } catch (e) {
      print('❌ Error getSizesByVariant: $e');
      rethrow;
    }
  }

  /// ✅ Thêm size mới
  Future<String> addProductSize(
    String shopProductID,
    String variantID,
    ProductSizeModel size,
  ) async {
    if (shopProductID.isEmpty) throw ArgumentError('shopProductID is required');
    if (variantID.isEmpty) throw ArgumentError('variantID is required');
    if (size.sizeID == null || size.sizeID!.isEmpty) {
      throw ArgumentError('sizeID is required');
    }

    try {
      print('➕ Adding size: ${size.sizeID}');
      
      final ref = _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .doc(variantID)
          .collection('product_sizes')
          .doc(size.sizeID);

      await ref.set(size.toMap());
      
      print('✅ Added size successfully');
      return size.sizeID!;
    } catch (e) {
      print('❌ Error addProductSize: $e');
      rethrow;
    }
  }

  /// ✅ Update size - SỬA: dùng .set() với merge thay vì .update()
  /// Lý do: .update() sẽ lỗi nếu document chưa tồn tại
  ///         .set(merge: true) sẽ tạo mới nếu chưa có, update nếu đã có
  Future<void> updateProductSize(
    String shopProductID,
    String variantID,
    String sizeID,
    ProductSizeModel size,
  ) async {
    if (shopProductID.isEmpty || variantID.isEmpty || sizeID.isEmpty) {
      throw ArgumentError('ID không được để trống');
    }

    try {
      print('📝 Updating size: $sizeID');
      print('   Quantity: ${size.quantity}, Price: ${size.price}, CostPrice: ${size.costPrice}');
      
      final docRef = _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .doc(variantID)
          .collection('product_sizes')
          .doc(sizeID);

      // Dùng .set() với merge: true để tạo mới hoặc update
      await docRef.set(size.toMap(), SetOptions(merge: true));
      
      print('✅ Updated size successfully');
    } catch (e) {
      print('❌ Error updateProductSize: $e');
      rethrow;
    }
  }

  /// ✅ Xóa size
  Future<void> deleteProductSize(
    String shopProductID,
    String variantID,
    String sizeID,
  ) async {
    if (shopProductID.isEmpty || variantID.isEmpty || sizeID.isEmpty) {
      throw ArgumentError('ID không được để trống');
    }

    try {
      print('🗑️ Deleting size: $sizeID');
      
      await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .doc(variantID)
          .collection('product_sizes')
          .doc(sizeID)
          .delete();
      
      print('✅ Deleted size successfully');
    } catch (e) {
      print('❌ Error deleteProductSize: $e');
      rethrow;
    }
  }

  /// 🆕 Lấy một size cụ thể
  Future<ProductSizeModel?> getSizeById(
    String shopProductID,
    String variantID,
    String sizeID,
  ) async {
    try {
      final doc = await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .doc(variantID)
          .collection('product_sizes')
          .doc(sizeID)
          .get();

      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['sizeID'] = doc.id;
      return ProductSizeModel.fromMap(data);
    } catch (e) {
      print('❌ Error getSizeById: $e');
      rethrow;
    }
  }

  Stream<List<ProductSizeModel>> watchSizesByVariant(
    String shopProductID,
    String variantID,
  ) {
    return _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .doc(variantID)
        .collection('product_sizes')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['sizeID'] = doc.id;
              return ProductSizeModel.fromMap(data);
            }).toList());
  }

  Future<bool> sizeExists(
    String shopProductID,
    String variantID,
    String sizeID,
  ) async {
    try {
      final doc = await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .doc(variantID)
          .collection('product_sizes')
          .doc(sizeID)
          .get();
      
      return doc.exists;
    } catch (e) {
      print('❌ Error checking size exists: $e');
      return false;
    }
  }
}