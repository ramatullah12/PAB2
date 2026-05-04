import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    // Kita tambahkan kompresi gambar (kualitas & ukuran maksimal) 
    // agar string base64 tidak melebihi batas maksimal dokumen Firestore (1 MB).
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 30, // Kompres kualitas gambar menjadi 30%
      maxWidth: 600,    // Batasi lebar maksimal 600px
      maxHeight: 600,   // Batasi tinggi maksimal 600px
    );
    return picked;
  }

  static Future<String> toBase64(XFile file) async {
    // XFile memiliki metode readAsBytes() bawaan yang aman untuk semua platform (termasuk Web)
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }
}