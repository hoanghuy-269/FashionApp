import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/app_notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Gửi thông báo mới
  Future<bool> sendNotification(AppNotification notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
      return true;
    } catch (e) {
      print('❌ Lỗi gửi thông báo: $e');
      return false;
    }
  }

  // Lấy thông báo theo user ID
  Stream<List<AppNotification>> getNotificationsByUserId(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AppNotification.fromFirestore(doc))
                  .toList(),
        );
  }

  // Đánh dấu đã đọc
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      return true;
    } catch (e) {
      print('❌ Lỗi đánh dấu đã đọc: $e');
      return false;
    }
  }

  // Đánh dấu tất cả là đã đọc
  Future<bool> markAllAsRead(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('❌ Lỗi đánh dấu tất cả đã đọc: $e');
      return false;
    }
  }

  // Đếm số thông báo chưa đọc
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Xóa thông báo
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      return true;
    } catch (e) {
      print('❌ Lỗi xóa thông báo: $e');
      return false;
    }
  }

  // XÓA TẤT CẢ THÔNG BÁO CỦA USER
  Future<bool> clearAllNotifications(String userId) async {
    try {
      // Lấy tất cả thông báo của user
      final querySnapshot =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .get();

      // Nếu không có thông báo nào, trả về true
      if (querySnapshot.docs.isEmpty) {
        return true;
      }

      // Dùng batch để xóa hàng loạt
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('❌ Lỗi xóa tất cả thông báo: $e');
      return false;
    }
  }

  // XÓA THÔNG BÁO THEO ĐIỀU KIỆN
  Future<bool> deleteNotificationsByCondition(
    String userId, {
    String? type,
    bool? isRead,
    DateTime? olderThan,
  }) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId);

      // Thêm điều kiện lọc nếu có
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      if (isRead != null) {
        query = query.where('isRead', isEqualTo: isRead);
      }
      if (olderThan != null) {
        query = query.where('createdAt', isLessThan: olderThan);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        return true;
      }

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('❌ Lỗi xóa thông báo theo điều kiện: $e');
      return false;
    }
  }

  // Lấy thông báo theo type
  Stream<List<AppNotification>> getNotificationsByType(
    String userId,
    String type,
  ) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AppNotification.fromFirestore(doc))
                  .toList(),
        );
  }
}
