import 'dart:async';
import 'dart:io';

import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/repositories/oder_item_repository.dart';
import 'package:flutter/material.dart';

class OrderItemViewModel extends ChangeNotifier {
  final OderItemRepository _repository = OderItemRepository();
  final Map<String, String> _userCache = {};

  List<OrderItem> _items = [];
  List<OrderItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription? _subscription;

  void listenOrderItems(String shopId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository
        .getShopItems(shopId)
        .listen(
          (data) {
            _items = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Stream<int?> getTotalOrderItemsByShopStream(String shopId) {
    try {
      return _repository.getTotalOrderItemsByShopStream(shopId);
    } catch (e) {
      return Stream.value(0);
    }
  }

  Future<String> getUserNameCached(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId]!;

    final name = await _repository.getUserName(userId);
    _userCache[userId] = name;
    return name;
  }

  Future<void> updateOrderItemStatus(String orderItemId, String newStatus) {
    return _repository.updateOrderItemStatus(orderItemId, newStatus);
  }

  Future<void> updateOrderShipper(
    String orderId, { // Thêm dấu { ở đây
    String? shipperId,
    String? cancellationReason,
    String? deliveryProofUrl,
  }) {
    return _repository.updateOrderShipper(
      orderId,
      shipperId: shipperId,
      cancellationReason: cancellationReason,
      deliveryProofUrl: deliveryProofUrl,
    );
  }

  Future<String> uploadDeliveryProof(File imageFile, String orderId) {
    return _repository.uploadDeliveryProof(imageFile, orderId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
