class Note {
  String? id;
  String title;
  String ingredients;
  String steps;
  String category;
  String imageBase64;

  Note({
    this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.imageBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'image_base64': imageBase64,
    };
  }

  factory Note.fromMap(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      title: data['title'] ?? '',
      ingredients: data['ingredients'] ?? '',
      steps: data['steps'] ?? '',
      category: data['category'] ?? '',
      imageBase64: data['image_base64'] ?? '',
    );
  }
}