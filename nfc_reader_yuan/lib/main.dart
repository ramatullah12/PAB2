import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NFCReaderScreen(),
    );
  }
}

class NFCReaderScreen extends StatefulWidget {
  const NFCReaderScreen({super.key});

  @override
  State<NFCReaderScreen> createState() => _NFCReaderScreenState();
}

class _NFCReaderScreenState extends State<NFCReaderScreen> {
  final List<String> _nfcIds = [];

  bool _isScanning = false;
  double? _progressValue;
  Color _statusColor = Colors.blue;
  String _statusText = "Tekan tombol untuk memulai pemindaian";

  @override
  void initState() {
    super.initState();
    _checkNFCAvailability();
  }

  /// ===============================
  /// CEK NFC DEVICE
  /// ===============================
  Future<void> _checkNFCAvailability() async {
    if (!Platform.isAndroid) {
      setState(() {
        _statusText = "NFC hanya berjalan di Android";
        _statusColor = Colors.grey;
      });
      return;
    }

    bool available = await NfcManager.instance.isAvailable();

    setState(() {
      _statusText =
          available ? "NFC tersedia ✅" : "Perangkat tidak mendukung NFC ❌";
      _statusColor = available ? Colors.green : Colors.red;
    });
  }

  /// ===============================
  /// START SCAN NFC
  /// ===============================
  Future<void> _startNFCScan() async {
    if (!Platform.isAndroid || _isScanning) return;

    bool available = await NfcManager.instance.isAvailable();
    if (!available) {
      setState(() {
        _statusText = "Aktifkan NFC di pengaturan HP";
        _statusColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isScanning = true;
      _progressValue = null;
      _statusColor = Colors.orange;
      _statusText = "Dekatkan kartu NFC...";
    });

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          var data = tag.data;

          List<int>? identifier =
              data['nfca']?['identifier'];

          String nfcId = identifier != null
              ? identifier.map((e) => e.toRadixString(16)).join(":")
              : "Tidak terbaca";

          String time =
              DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(DateTime.now());

          setState(() {
            _nfcIds.insert(0, "$time | ID: $nfcId");
            _statusText = "Kartu berhasil dibaca ✅";
            _statusColor = Colors.green;
            _progressValue = 1;
          });
        } catch (e) {
          setState(() {
            _statusText = "Gagal membaca NFC";
            _statusColor = Colors.red;
            _progressValue = 0;
          });
        }

        await NfcManager.instance.stopSession();

        setState(() {
          _isScanning = false;
        });
      },
    );
  }

  /// ===============================
  /// STOP SCAN
  /// ===============================
  Future<void> _stopNFCScan() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}

    setState(() {
      _isScanning = false;
      _progressValue = 0;
      _statusColor = Colors.blue;
      _statusText = "Scan dihentikan";
    });
  }

  /// ===============================
  /// UI
  /// ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC Reader"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// STATUS BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 25),

            /// ANIMASI NFC
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _isScanning ? Colors.orangeAccent : Colors.grey,
              ),
              child: const Icon(
                Icons.nfc,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            /// PROGRESS
            LinearProgressIndicator(
              value: _isScanning ? null : _progressValue,
              minHeight: 8,
            ),

            const SizedBox(height: 20),

            /// LIST HISTORY
            Expanded(
              child: ListView.builder(
                itemCount: _nfcIds.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(_nfcIds[index]),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            /// BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      _isScanning ? null : _startNFCScan,
                  child: const Text("Mulai Scan"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed:
                      _isScanning ? _stopNFCScan : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Stop"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}