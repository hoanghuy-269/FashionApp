import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/voucher.dart';

class DiscountSource {
  final FirebaseFirestore _firestore;
  DiscountSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('discounts');

  Future<List<Voucher>> fetchAll() async {
    final snap = await _col.get();
    return snap.docs.map((d) => Voucher.fromMap(d.data(), d.id)).toList();
  }

  Future<void> add(Voucher voucher) async {
    // Tạo doc mới (auto id), lưu theo toMap() của model bạn
    await _col.doc().set(voucher.toMap());
  }

  Future<void> update(String id, Voucher voucher) async {
    await _col.doc(id).update(voucher.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  
}
