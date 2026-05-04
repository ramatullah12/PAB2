import 'package:flutter/material.dart';
import 'dart:convert';
import 'add_recipe_screen.dart';
import '../services/firestore_service.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const RecipeDetailScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        data['image_base64'] != null && data['image_base64'].toString().isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: hasImage ? 250 : 120,
            pinned: true,
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                data['title'] ?? 'Resep',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: hasImage
                  ? Image.memory(
                      base64Decode(data['image_base64']),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.deepOrange.shade200,
                        child: const Icon(Icons.restaurant,
                            size: 80, color: Colors.white54),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepOrange.shade700,
                            Colors.orange.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddRecipeScreen(
                        existingRecipe: data,
                        docId: docId,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Hapus Resep"),
                      content: const Text(
                          "Apakah kamu yakin ingin menghapus resep ini?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () {
                            FirestoreService().deleteRecipe(docId);
                            Navigator.pop(context); // close dialog
                            Navigator.pop(context); // go back to home
                          },
                          child: const Text("Hapus",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  if (data['category'] != null &&
                      data['category'].toString().isNotEmpty)
                    Chip(
                      label: Text(
                        data['category'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.deepOrange,
                    ),
                  const SizedBox(height: 20),

                  // Ingredients Section
                  _buildSectionTitle(Icons.list_alt, "Bahan-bahan"),
                  const SizedBox(height: 8),
                  _buildContentCard(data['ingredients'] ?? '-'),
                  const SizedBox(height: 20),

                  // Steps Section
                  _buildSectionTitle(Icons.format_list_numbered, "Langkah-langkah"),
                  const SizedBox(height: 8),
                  _buildContentCard(data['steps'] ?? '-'),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepOrange, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 15, height: 1.6),
      ),
    );
  }
}
