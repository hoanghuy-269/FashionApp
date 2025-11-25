import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/models/order_model.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class OrderDetailScreen extends StatelessWidget {
  final FashionOrder order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status
            _buildOrderStatus(),
            const SizedBox(height: 24),

            // Order info
            _buildOrderInfo(),
            const SizedBox(height: 24),
            // Shipping info
            _buildShippingInfo(),
            // Items list
            _buildItemsList(),
            const SizedBox(height: 24),

            // Price summary
            _buildPriceSummary(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(order.orderStatus),
                color: _getStatusColor(order.orderStatus),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusText(order.orderStatus),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.orderStatus),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã đơn: ${order.orderId}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin đơn hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Ngày đặt', _formatDate(order.createdAt)),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Phương thức',
              _getPaymentMethod(order.paymentMethodId),
            ),
            if (order.cancellationReason != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Lý do hủy', order.cancellationReason!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sản phẩm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => _buildOrderItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        collapsedIconColor: Colors.grey,
        iconColor: Colors.black,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Thay thế bằng FutureBuilder để lấy tên màu và size
                  _buildColorSizeInfo(item),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatPrice(item.price)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Product status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getProductStatusColor(
                        item.itemStatus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getProductStatusColor(
                          item.itemStatus,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getProductStatusText(item.itemStatus),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getProductStatusColor(item.itemStatus),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần đánh giá sản phẩm - chỉ hiển thị khi status là 004 (hoàn thành)
                if (item.itemStatus == 'status_004')
                  _buildProductReviewSection(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget phần đánh giá sản phẩm
  Widget _buildProductReviewSection(OrderItem item) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getShopProductData(item),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Vẫn hiển thị form đánh giá ngay cả khi có lỗi
          return _buildReviewForm(item, item.productId, null);
        }

        final shopProductData = snapshot.data;
        final hasReviewed = shopProductData?['hasReviewed'] ?? false;
        final shopProductId =
            shopProductData?['shopProductId'] ?? item.productId;
        final shopProduct = shopProductData?['shopProduct'];

        if (hasReviewed) {
          // Đã đánh giá - hiển thị đánh giá hiện tại
          final reviewData =
              shopProductData?['reviewData'] as Map<String, dynamic>?;
          return _buildExistingReview(reviewData ?? {});
        } else {
          // Chưa đánh giá - hiển thị form đánh giá
          return _buildReviewForm(item, shopProductId, shopProduct);
        }
      },
    );
  }

  // Widget form đánh giá
  Widget _buildReviewForm(
    OrderItem item,
    String? shopProductId,
    ShopProductModel? shopProduct,
  ) {
    double rating = 0;
    String reviewText = '';

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đánh giá sản phẩm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Rating stars - THÊM itemSize ĐỂ THU NHỎ
              Center(
                child: RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30, // THÊM DÒNG NÀY - điều chỉnh kích thước sao
                  itemPadding: const EdgeInsets.symmetric(
                    horizontal: 2.0,
                  ), // GIẢM PADDING
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (newRating) {
                    setState(() {
                      rating = newRating;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Review text
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Hãy chia sẻ cảm nhận của bạn về sản phẩm...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  reviewText = value;
                },
              ),
              const SizedBox(height: 16),

              // Submit button - LUÔN HIỂN THỊ ngay cả khi không có shopProductId
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      rating > 0
                          ? () => _submitReview(
                            context,
                            item,
                            rating,
                            reviewText,
                            shopProductId ?? item.productId, // fallback
                            shopProduct,
                          )
                          : null,
                  child: const Text(
                    'Gửi đánh giá',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget hiển thị đánh giá hiện tại
  Widget _buildExistingReview(Map<String, dynamic> reviewData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đánh giá: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              RatingBar.builder(
                initialRating: (reviewData['rating'] as num).toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 20,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder:
                    (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (_) {},
                ignoreGestures: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (reviewData['reviewText'] != null &&
              (reviewData['reviewText'] as String).isNotEmpty)
            Text(
              reviewData['reviewText'],
              style: const TextStyle(fontSize: 14),
            ),
          const SizedBox(height: 8),
          Text(
            'Đánh giá ngày: ${_formatDate((reviewData['createdAt'] as Timestamp).toDate())}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Hàm lấy thông tin shop product và kiểm tra đã đánh giá chưa
  Future<Map<String, dynamic>> _getShopProductData(OrderItem item) async {
    try {
      print('🛒 DEBUG - Bắt đầu tìm shopProductId cho OrderItem:');
      print('   - orderItemId: ${item.orderItemId}');
      print('   - productId: ${item.productId}');
      print(
        '   - shopProductId từ item: ${item.shopProductId}',
      ); // DEBUG SHOP PRODUCT ID

      // ƯU TIÊN 1: Nếu item đã có shopProductId thì dùng luôn
      if (item.shopProductId != null && item.shopProductId!.isNotEmpty) {
        print('✅ Sử dụng shopProductId từ item: ${item.shopProductId}');

        // Lấy thông tin shop product để verify
        final shopProductDoc =
            await FirebaseFirestore.instance
                .collection('shop_products')
                .doc(item.shopProductId!)
                .get();

        if (shopProductDoc.exists) {
          final shopProductData = shopProductDoc.data()!;
          final shopProduct = ShopProductModel.fromMap(
            shopProductData,
            item.shopProductId!,
          );

          print('📋 Shop product data:');
          print('   - productID: ${shopProductData['productID']}');
          print('   - shopId: ${shopProductData['shopId']}');

          // Kiểm tra đã đánh giá chưa
          final reviewDoc =
              await FirebaseFirestore.instance
                  .collection('shop_product_reviews')
                  .doc('${order.orderId}_${item.orderItemId}')
                  .get();

          final hasReviewed = reviewDoc.exists;
          final reviewData = hasReviewed ? reviewDoc.data() : null;

          return {
            'shopProductId': item.shopProductId!,
            'shopProduct': shopProduct,
            'hasReviewed': hasReviewed,
            'reviewData': reviewData,
          };
        } else {
          print('⚠️ ShopProductId từ item không tồn tại trong database');
        }
      }

      // ƯU TIÊN 2: Tìm shopProductId từ productId (fallback)
      print('🔍 Tìm shop_products với productID: ${item.productId}');
      final shopProductsSnapshot =
          await FirebaseFirestore.instance
              .collection('shop_products')
              .where('productID', isEqualTo: item.productId)
              .limit(1)
              .get();

      print('📊 Số lượng kết quả: ${shopProductsSnapshot.docs.length}');

      if (shopProductsSnapshot.docs.isNotEmpty) {
        final shopProductDoc = shopProductsSnapshot.docs.first;
        final shopProductId = shopProductDoc.id;
        final shopProductData = shopProductDoc.data();

        print('✅ Tìm thấy shopProductId: $shopProductId');
        print('📋 Shop product data:');
        print('   - productID: ${shopProductData['productID']}');
        print('   - shopId: ${shopProductData['shopId']}');

        final shopProduct = ShopProductModel.fromMap(
          shopProductData,
          shopProductId,
        );

        // Kiểm tra đã đánh giá chưa
        final reviewDoc =
            await FirebaseFirestore.instance
                .collection('shop_product_reviews')
                .doc('${order.orderId}_${item.orderItemId}')
                .get();

        final hasReviewed = reviewDoc.exists;
        final reviewData = hasReviewed ? reviewDoc.data() : null;

        return {
          'shopProductId': shopProductId,
          'shopProduct': shopProduct,
          'hasReviewed': hasReviewed,
          'reviewData': reviewData,
        };
      }

      // KHÔNG TÌM THẤY
      print('❌ KHÔNG tìm thấy shopProductId');
      return {
        'shopProductId': 'unknown',
        'shopProduct': null,
        'hasReviewed': false,
        'reviewData': null,
        'error': 'Không tìm thấy shop product',
      };
    } catch (e) {
      print('❌ Lỗi khi lấy shop product data: $e');
      return {
        'shopProductId': 'unknown',
        'shopProduct': null,
        'hasReviewed': false,
        'reviewData': null,
        'error': e.toString(),
      };
    }
  }

  // Hàm gửi đánh giá - THÊM DEBUG CHI TIẾT
  Future<void> _submitReview(
    BuildContext context,
    OrderItem item,
    double rating,
    String reviewText,
    String shopProductId,
    ShopProductModel? shopProduct,
  ) async {
    try {
      final reviewId = '${order.orderId}_${item.orderItemId}';

      // DEBUG CHI TIẾT
      print('=== DEBUG SUBMIT REVIEW ===');
      print('ShopProductId: $shopProductId');
      print('ReviewId: $reviewId');
      print('ProductId: ${item.productId}');
      print('Rating: $rating');
      print('ReviewText: $reviewText');

      // Kiểm tra shopProductId có hợp lệ không
      if (shopProductId.isEmpty || shopProductId == 'unknown') {
        throw Exception('ShopProductId không hợp lệ: $shopProductId');
      }

      // Kiểm tra shop product có tồn tại không
      final shopProductDoc =
          await FirebaseFirestore.instance
              .collection('shop_products')
              .doc(shopProductId)
              .get();

      if (!shopProductDoc.exists) {
        throw Exception('Shop product $shopProductId không tồn tại');
      }
      print('DEBUG - Shop product tồn tại: ${shopProductDoc.data()}');

      // Lưu vào collection shop_product_reviews
      await FirebaseFirestore.instance
          .collection('shop_product_reviews')
          .doc(reviewId)
          .set({
            'reviewId': reviewId,
            'orderId': order.orderId,
            'itemId': item.orderItemId,
            'shopProductId': shopProductId,
            'productId': item.productId,
            'userId': order.userId,
            'rating': rating,
            'reviewText': reviewText,
            'createdAt': Timestamp.now(),
            'productName': item.productName,
            'imageUrl': item.imageUrl,
          });

      print('DEBUG - Đã lưu review thành công');

      // Cập nhật rating trung bình trong shop_products
      await _updateProductRating(shopProductId);

      print('DEBUG - Đã cập nhật rating thành công');

      // Hiển thị thông báo thành công
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn đã đánh giá sản phẩm!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh UI
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      }
    } catch (e) {
      print('DEBUG - Lỗi khi gửi đánh giá: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi đánh giá: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Hàm cập nhật rating trung bình
  Future<void> _updateProductRating(String shopProductId) async {
    try {
      final reviewsSnapshot =
          await FirebaseFirestore.instance
              .collection('shop_product_reviews')
              .where('shopProductId', isEqualTo: shopProductId)
              .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (final doc in reviewsSnapshot.docs) {
          totalRating += (doc.data()['rating'] as num).toDouble();
        }

        final averageRating = totalRating / reviewsSnapshot.docs.length;
        final roundedRating = double.parse(averageRating.toStringAsFixed(1));

        print(
          'DEBUG - Tính toán rating: $roundedRating từ ${reviewsSnapshot.docs.length} reviews',
        );

        // Cập nhật rating trong shop_products
        await FirebaseFirestore.instance
            .collection('shop_products')
            .doc(shopProductId)
            .update({
              'rating': roundedRating, // ✅ ĐÂY LÀ RATING TRUNG BÌNH
              'totalReviews':
                  reviewsSnapshot.docs.length, // ✅ SỐ LƯỢNG ĐÁNH GIÁ
            });

        print('DEBUG - Đã cập nhật shop_products thành công');
      } else {
        print('DEBUG - Không có reviews nào để tính rating');
      }
    } catch (e) {
      print('DEBUG - Lỗi khi cập nhật rating: $e');
      // ... phần xử lý lỗi
    }
  }

  // Widget để hiển thị thông tin màu và size với tên
  Widget _buildColorSizeInfo(OrderItem item) {
    return FutureBuilder<Map<String, String>>(
      future: _getColorAndSizeNames(item.colorId, item.sizeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Phân loại: Đang tải...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Phân loại: ${item.colorId} - ${item.sizeId}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          );
        } else if (snapshot.hasData) {
          final names = snapshot.data!;
          return Text(
            'Phân loại: ${names['colorName']} - ${names['sizeName']}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          );
        } else {
          return Text(
            'Phân loại: ${item.colorId} - ${item.sizeId}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          );
        }
      },
    );
  }

  // Hàm lấy tên màu và size từ Firebase
  Future<Map<String, String>> _getColorAndSizeNames(
    String colorId,
    String sizeId,
  ) async {
    try {
      final colorFuture =
          FirebaseFirestore.instance.collection('colors').doc(colorId).get();

      final sizeFuture =
          FirebaseFirestore.instance.collection('sizes').doc(sizeId).get();

      final results = await Future.wait([colorFuture, sizeFuture]);

      final colorDoc = results[0];
      final sizeDoc = results[1];

      return {
        'colorName':
            colorDoc.exists ? (colorDoc.data()?['name'] ?? colorId) : colorId,
        'sizeName':
            sizeDoc.exists ? (sizeDoc.data()?['name'] ?? sizeId) : sizeId,
      };
    } catch (e) {
      // Trả về ID nếu có lỗi
      return {'colorName': colorId, 'sizeName': sizeId};
    }
  }

  Widget _buildPriceSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPriceRow('Tạm tính', order.itemsTotal),
            _buildPriceRow('Phí vận chuyển', order.shippingFee),
            if (order.discount > 0) _buildPriceRow('Giảm giá', -order.discount),
            const Divider(height: 24),
            _buildPriceRow('Tổng cộng', order.finalTotal, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin giao hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Địa chỉ', order.customerAddress),
            const SizedBox(height: 8),
            _buildInfoRow('Số điện thoại', order.customerPhone),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount >= 0 ? '' : '-'}${_formatPrice(amount.abs())}',
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.red : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Status methods for order
  String _getStatusText(String statusId) {
    switch (statusId) {
      case 'status_001':
        return 'Đang chờ';
      case 'status_002':
        return 'Đã xác nhận';
      case 'status_003':
        return 'Đang giao hàng';
      case 'status_004':
        return 'Hoàn thành';
      case 'status_005':
        return 'Đã hủy';
      default:
        return 'Đang chờ';
    }
  }

  Color _getStatusColor(String statusId) {
    switch (statusId) {
      case 'status_001':
        return Colors.orange;
      case 'status_002':
        return Colors.blue;
      case 'status_003':
        return Colors.purple;
      case 'status_004':
        return Colors.green;
      case 'status_005':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String statusId) {
    switch (statusId) {
      case 'status_001':
        return Icons.pending_actions;
      case 'status_002':
        return Icons.check_circle_outline;
      case 'status_003':
        return Icons.local_shipping;
      case 'status_004':
        return Icons.check_circle;
      case 'status_005':
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }

  // Status methods for individual products
  String _getProductStatusText(String statusId) {
    switch (statusId) {
      case 'status_001':
        return 'Chờ xác nhận';
      case 'status_002':
        return 'Đã xác nhận';
      case 'status_003':
        return 'Đang giao hàng';
      case 'status_004':
        return 'Hoàn thành';
      case 'status_005':
        return 'Đã hủy';
      default:
        return 'Chờ xác nhận';
    }
  }

  Color _getProductStatusColor(String statusId) {
    switch (statusId) {
      case 'status_001':
        return Colors.orange;
      case 'status_002':
        return Colors.blue;
      case 'status_003':
        return Colors.purple;
      case 'status_004':
        return Colors.green;
      case 'status_005':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentMethod(String methodId) {
    switch (methodId) {
      case 'cod':
        return 'Thanh toán khi nhận hàng';
      case 'banking':
        return 'Chuyển khoản ngân hàng';
      case 'momo':
        return 'Ví MoMo';
      default:
        return 'Thanh toán khi nhận hàng';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }
}
