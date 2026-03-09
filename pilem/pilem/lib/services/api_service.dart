import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://api.themoviedb.org/3";
  static const String apiKey = "e62c3d76d6094342f5dfadc2d207e65c";

  Future<List<Map<String, dynamic>>> _fetchMovies(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception("Failed to load movies: ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> getAllMovies() async {
    return _fetchMovies(
      "$baseUrl/movie/now_playing?api_key=$apiKey",
    );
  }

  Future<List<Map<String, dynamic>>> getTrendingMovies() async {
    return _fetchMovies(
      "$baseUrl/trending/movie/day?api_key=$apiKey",
    );
  }

  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    return _fetchMovies(
      "$baseUrl/movie/popular?api_key=$apiKey",
    );
  }
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl/search/movie?api_key=$apiKey&query=$query"),
    );
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }
}