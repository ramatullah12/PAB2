import 'package:flutter/material.dart';
import '../models/gold_model.dart';
import '../services/gold_service.dart';
import 'package:intl/intl.dart'; // Opsional jika ingin format angka lebih rapi

class GoldListPage extends StatefulWidget {
  const GoldListPage({Key? key}) : super(key: key);

  @override
  State<GoldListPage> createState() => _GoldListPageState();
}

class _GoldListPageState extends State<GoldListPage> {
  final GoldService _goldService = GoldService();
  late Future<List<GoldModel>> _goldFuture;

  @override
  void initState() {
    super.initState();
    _goldFuture = _goldService.getGoldPrices();
  }

  // Fungsi format rupiah agar ada titik pemisah ribuan (persis seperti foto)
  String formatRupiah(int harga) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Mengubah warna AppBar menjadi Biru sesuai foto
      appBar: AppBar(
        title: const Text(
          "Harga Emas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.blue, 
        elevation: 0,
      ),
      body: FutureBuilder<List<GoldModel>>(
        future: _goldFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data harga emas tidak ditemukan"));
          }

          final goldList = snapshot.data!;

          // 2. Menggunakan ListView.separated untuk garis antar item
          return ListView.separated(
            itemCount: goldList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final gold = goldList[index];

              // 3. Menghapus Card dan Icon agar tampilan bersih/flat sesuai foto
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  formatRupiah(gold.harga),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Tanggal: ${gold.tanggal}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}