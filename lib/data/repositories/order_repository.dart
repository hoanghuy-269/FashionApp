import 'package:fashion_app/data/models/order_model.dart';
import 'package:fashion_app/data/sources/order_source.dart';

class OrderRepository {
  final OrderSource _source;

  OrderRepository(this._source);

  Future<String> createOrder(FashionOrder order) => _source.createOrder(order);

  Stream<List<FashionOrder>> getUserOrders(String userId) =>
      _source.getOrdersByUser(userId);

  Stream<List<FashionOrder>> getShopOrders(String shopId) =>
      _source.getOrdersByShop(shopId);

  Future<FashionOrder?> getOrderDetail(String orderId) =>
      _source.getOrderDetail(orderId);

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? cancellationReason,
  }) => _source.updateOrderStatus(
    orderId: orderId,
    newStatus: newStatus,
    cancellationReason: cancellationReason,
  );

  Future<void> updateOrderItemStatus({
    required String orderItemId,
    required String newStatus,
  }) => _source.updateOrderItemStatus(
    orderItemId: orderItemId,
    newStatus: newStatus,
  );

  Future<void> assignShipper({
    required String orderId,
    required String shipperId,
  }) => _source.assignShipper(orderId: orderId, shipperId: shipperId);

  Future<Map<String, dynamic>> getOrderStats(String userId) =>
      _source.getOrderStats(userId);
}
