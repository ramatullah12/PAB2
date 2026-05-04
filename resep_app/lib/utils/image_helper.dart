import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<File?> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  static Future<String> toBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }
}