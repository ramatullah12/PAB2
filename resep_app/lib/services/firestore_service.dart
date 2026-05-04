import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addRecipe({
    required String title,
    required String ingredients,
    required String steps,
    required String category,
    required String imageBase64,
  }) async {
    await _db.collection('recipes').add({
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'image_base64': imageBase64,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getRecipes() {
    return _db
        .collection('recipes')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<void> deleteRecipe(String docId) async {
    await _db.collection('recipes').doc(docId).delete();
  }

  Future<void> updateRecipe({
    required String docId,
    required String title,
    required String ingredients,
    required String steps,
    required String category,
    required String imageBase64,
  }) async {
    await _db.collection('recipes').doc(docId).update({
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'image_base64': imageBase64,
    });
  }
}