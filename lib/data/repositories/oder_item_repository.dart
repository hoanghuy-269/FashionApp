import 'dart:io';

import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/sources/oder_item_source.dart';

class OderItemRepository {
  final OrderItemSource _source = OrderItemSource();

  Stream<List<OrderItem>> getShopItems(String shopId) {
    return _source.getItemsWithParentOrderStream(shopId);
  }

  Future<String> getUserName(String userId) {
    return _source.getUserNameById(userId);
  }

  Future<void> updateOrderItemStatus(String orderItemId, String newStatus) {
    return _source.updateOrderItemStatus(orderItemId, newStatus);
  }

  Future<void> updateOrderShipper(
    String orderId, {
    String? shipperId,
    String? cancellationReason,
    String? deliveryProofUrl,
  }) {
    return _source.updateOrderShipper(
      orderId,
      shipperId: shipperId,
      cancellationReason: cancellationReason,
      deliveryProofUrl: deliveryProofUrl,
    );
  }
  Future<String> uploadDeliveryProof(File imageFile, String orderId) {
    return _source.uploadDeliveryProof(imageFile, orderId);
  }

}
