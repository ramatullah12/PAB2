import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/firestore_service.dart';
import '../utils/image_helper.dart';

class AddRecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? existingRecipe;
  final String? docId;

  const AddRecipeScreen({super.key, this.existingRecipe, this.docId});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _imageBase64;
  bool _isSaving = false;

  bool get _isEditing => widget.existingRecipe != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.existingRecipe!['title'] ?? '';
      _ingredientsController.text = widget.existingRecipe!['ingredients'] ?? '';
      _stepsController.text = widget.existingRecipe!['steps'] ?? '';
      _categoryController.text = widget.existingRecipe!['category'] ?? '';
      _imageBase64 = widget.existingRecipe!['image_base64'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImageHelper.pickImage();
    if (image != null) {
      final base64 = await ImageHelper.toBase64(image);
      setState(() {
        _imageBase64 = base64;
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final service = FirestoreService();

      if (_isEditing && widget.docId != null) {
        await service.updateRecipe(
          docId: widget.docId!,
          title: _titleController.text.trim(),
          ingredients: _ingredientsController.text.trim(),
          steps: _stepsController.text.trim(),
          category: _categoryController.text.trim(),
          imageBase64: _imageBase64 ?? '',
        );
      } else {
        await service.addRecipe(
          title: _titleController.text.trim(),
          ingredients: _ingredientsController.text.trim(),
          steps: _stepsController.text.trim(),
          category: _categoryController.text.trim(),
          imageBase64: _imageBase64 ?? '',
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Resep" : "Tambah Resep"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imageBase64 != null && _imageBase64!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            base64Decode(_imageBase64!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              "Tap untuk pilih gambar",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Nama Resep",
                  prefixIcon: const Icon(Icons.restaurant_menu),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Nama resep wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Category
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Kategori wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Ingredients
              TextFormField(
                controller: _ingredientsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Bahan-bahan",
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.list_alt),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "Pisahkan tiap bahan dengan baris baru",
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Bahan wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Steps
              TextFormField(
                controller: _stepsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Langkah-langkah",
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.format_list_numbered),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "Tulis langkah-langkah memasak",
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Langkah wajib diisi" : null,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveRecipe,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving
                        ? "Menyimpan..."
                        : (_isEditing ? "Update Resep" : "Simpan Resep"),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
