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
  // lấy ten mau theo id
  Future<String> getColorName(String colorID) async {
    try {
      final doc = await _firestore.collection('colors').doc(colorID).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? colorID;
      }
      return colorID;
    } catch (e) {
      return colorID;
    }
  }
  // lay ma hex theo id
  Future<String> getColorHexCode(String colorID) async {
    try {
      final doc = await _firestore.collection('colors').doc(colorID).get();
      if (doc.exists) {
        return doc.data()?['hexCode'] ?? '#808080';
      }
      return '#808080';
    } catch (e) {
      print('Error getting color hex: $e');
      return '#808080';
    }
  }
  Future<Map<String, Map<String, dynamic>>> getAllColors() async {
    try {
      final snapshot = await _firestore.collection('colors').get();
      Map<String, Map<String, dynamic>> colorsMap = {};
      
      for (var doc in snapshot.docs) {
        colorsMap[doc.id] = {
          'name': doc.data()['name'],
          'hexCode': doc.data()['hexCode'],
        };
      }
      return colorsMap;
    } catch (e) {
      print('Error getting all colors: $e');
      return {};
    }
  }
  
}