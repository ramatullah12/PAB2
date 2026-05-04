import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/firestore_service.dart';
import '../utils/image_helper.dart';

class RecipeDialog extends StatefulWidget {
  const RecipeDialog({super.key});

  @override
  State<RecipeDialog> createState() => _RecipeDialogState();
}

class _RecipeDialogState extends State<RecipeDialog> {
  final title = TextEditingController();
  final ingredients = TextEditingController();
  final steps = TextEditingController();
  final category = TextEditingController();

  String? imageBase64;

  Future<void> pickImage() async {
    var image = await ImageHelper.pickImage();
    if (image != null) {
      imageBase64 = await ImageHelper.toBase64(image);
      setState(() {});
    }
  }

  Future<void> save() async {
    if (title.text.isEmpty ||
        ingredients.text.isEmpty ||
        steps.text.isEmpty ||
        category.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi")),
      );
      return;
    }

    await FirestoreService().addRecipe(
      title: title.text,
      ingredients: ingredients.text,
      steps: steps.text,
      category: category.text,
      imageBase64: imageBase64 ?? '',
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Resep"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: ingredients,
              decoration: const InputDecoration(labelText: "Ingredients"),
            ),
            TextField(
              controller: steps,
              decoration: const InputDecoration(labelText: "Steps"),
            ),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: imageBase64 == null
                    ? const Center(child: Text("Tap untuk tambah gambar"))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          base64Decode(imageBase64!),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: save,
          child: const Text("Tambah"),
        ),
      ],
    );
  }
}