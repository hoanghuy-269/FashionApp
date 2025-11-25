import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/models/order_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class OrderItemSource {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;


  Stream<List<OrderItem>> getItemsWithParentOrderStream(String shopId) {
    return _firestore
        .collectionGroup('order_items')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Future<OrderItem>> futures =
              snapshot.docs.map((doc) async {
                OrderItem item = OrderItem.fromFirestore(doc);

                DocumentReference? orderRef = doc.reference.parent.parent;
                if (orderRef != null) {
                  DocumentSnapshot orderDoc = await orderRef.get();
                  if (orderDoc.exists) {
                    item.parentOrder = FashionOrder.fromFirestore(orderDoc);
                  }
                }
                return item;
              }).toList();

          return await Future.wait(futures);
        });
  }
  // lấy tổng số lượng đơn hàng theo idShop
  Stream<int> getTotalOrderItemsByShopStream(String shopId) {
    return _firestore
        .collectionGroup('order_items')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<String> getUserNameById(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists ? doc.get('name') : 'Unknown';
  }

  Future<void> updateOrderItemStatus(
    String orderItemId,
    String newStatus,
  ) async {
    final query =
        await _firestore
            .collectionGroup('order_items')
            .where('orderItemId', isEqualTo: orderItemId)
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      throw Exception("Order item not found");
    }

    final docRef = query.docs.first.reference;

    await docRef.update({'itemStatus': newStatus});
  }

  Future<void> updateOrderShipper(
    String orderId, {
    String? shipperId,
    String? cancellationReason,
    String? deliveryProofUrl,
  }) async {
    await _firestore.collection('orders').doc(orderId).update({
      if (shipperId != null) "shipperID": shipperId,
      if (cancellationReason != null) "cancellationReason": cancellationReason,
      if (deliveryProofUrl != null) "deliveryProofUrl": deliveryProofUrl,
    });
  }

  Future<String> uploadDeliveryProof(File imageFile, String orderId) async {
    try {
      final fileName = 'delivery_proof_${orderId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('delivery_proofs/$fileName');
      
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      
      return url;
    } catch (e) {
      throw Exception('Lỗi khi upload ảnh: $e');
    }
  }
  
}
