import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/colors_model.dart';

class ColorSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // add color
Future<ColorsModel> addColor(ColorsModel color) async {
    final collection = _firestore.collection('colors');

    // Lấy tổng số document 
    final snapshot = await collection.get();
    final count = snapshot.docs.length + 1;

    final formattedId = 'color_${count.toString().padLeft(3, '0')}';

    // Gán ID đó vào model
    final colorWithId = color.copyWith(colorID: formattedId);

    await collection.doc(formattedId).set(colorWithId.toMap());

    return colorWithId; 
  }
  // get all colors
  Future<List<ColorsModel>> getAllColors() async {
    final query = await _firestore.collection('colors').get();
    return query.docs
        .map((doc) => ColorsModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}