import 'package:firebase_database/firebase_database.dart';
import '../models/gold_model.dart';

class GoldService {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref("harga_emas");

  Stream<DatabaseEvent> getPriceList() {
    return _dbRef.onValue;
  }

  // (optional - tetap simpan kalau mau)
  Future<List<GoldModel>> getGoldPrices() async {
    final snapshot = await _dbRef.get();

    List<GoldModel> goldList = [];

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        goldList.add(GoldModel.fromMap(value));
      });
    }

    return goldList;
  }
}