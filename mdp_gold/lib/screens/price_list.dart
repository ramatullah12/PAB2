import "package:flutter/material.dart";
import "package:firebase_database/firebase_database.dart";
import "package:intl/intl.dart";

import "package:latihan/services/gold_service.dart";
import "package:latihan/services/auth_service.dart";
import "package:latihan/screens/login_screen.dart";

class PriceList extends StatefulWidget {
  const PriceList({super.key});

  @override
  State<PriceList> createState() => _PriceListState();
}

class _PriceListState extends State<PriceList> {
  final GoldService _goldService = GoldService();
  final AuthService _authService = AuthService();

  String formatRupiah(dynamic harga) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(harga ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Harga Emas"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: () async {
              await _authService.signOut();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _goldService.getPriceList(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data?.snapshot.value;

          // Data kosong
          if (data == null) {
            return const Center(child: Text("Belum ada data."));
          }

          final Map<dynamic, dynamic> itemsMap =
              data as Map<dynamic, dynamic>;

          final items = itemsMap.entries.toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = Map<String, dynamic>.from(
                items[index].value as Map,
              );

              final harga = formatRupiah(item['harga']);
              final tanggal = item['tanggal'] ?? '-';

              return ListTile(
                title: Text(harga),
                subtitle: Text("Tanggal: $tanggal"),
              );
            },
          );
        },
      ),
    );
  }
}