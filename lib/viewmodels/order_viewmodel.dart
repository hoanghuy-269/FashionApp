import 'package:fashion_app/data/repositories/order_repository.dart';
import 'package:fashion_app/data/sources/order_source.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/order_model.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository;

  OrderViewModel({OrderRepository? repository})
    : _repository = repository ?? OrderRepository(OrderSource());

  List<FashionOrder> _orders = [];
  List<FashionOrder> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Stream<List<FashionOrder>>? _ordersStream;

  void loadOrders(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _ordersStream = _repository.getUserOrders(userId);
    _ordersStream!.listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Tạo đơn hàng
  Future<bool> createOrder(FashionOrder order) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.createOrder(order);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật trạng thái đơn hàng
  Future<bool> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? cancellationReason,
  }) async {
    try {
      await _repository.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
        cancellationReason: cancellationReason,
      );

      // Cập nhật local state
      final index = _orders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(orderStatus: newStatus);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Gán shipper
  Future<bool> assignShipper({
    required String orderId,
    required String shipperId,
  }) async {
    try {
      await _repository.assignShipper(orderId: orderId, shipperId: shipperId);

      // Cập nhật local state
      final index = _orders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(shipperId: shipperId);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Hủy đơn hàng
  Future<bool> cancelOrder(String orderId, String reason) async {
    return await updateOrderStatus(
      orderId: orderId,
      newStatus: 'cancelled',
      cancellationReason: reason,
    );
  }

  /// Lấy chi tiết đơn hàng
  Future<FashionOrder?> getOrderDetail(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final order = await _repository.getOrderDetail(orderId);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Lấy thống kê đơn hàng
  Future<Map<String, dynamic>> getOrderStats(String userId) async {
    try {
      return await _repository.getOrderStats(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Dispose
  @override
  void dispose() {
    _ordersStream = null;
    super.dispose();
  }
}
