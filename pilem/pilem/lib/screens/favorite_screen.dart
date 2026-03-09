import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  FavoriteScreenState createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {

  List<Movie> _favoriteMovies = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = prefs.getStringList('favorites') ?? [];

    setState(() {
      _favoriteMovies = favoritesJson
          .map((jsonStr) => Movie.fromJson(json.decode(jsonStr)))
          .toList();
    });
  }

  Future<void> _removeFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = prefs.getStringList('favorites') ?? [];

    favoritesJson.removeWhere((jsonStr) {
      final Map<String, dynamic> movieMap = json.decode(jsonStr);
      return movieMap['id'] == movieId;
    });

    await prefs.setStringList('favorites', favoritesJson);

    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Favorite Movies",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: _favoriteMovies.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 90, color: Colors.white30),
                  SizedBox(height: 20),
                  Text(
                    "Belum ada film favorit",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            )

          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _favoriteMovies.length,
              itemBuilder: (context, index) {

                final movie = _favoriteMovies[index];

                return Card(
                  color: const Color(0xff1c1c1c),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(movie: movie),
                        ),
                      ).then((_) => _loadFavorites());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [

                          /// POSTER
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: movie.posterPath.isNotEmpty
                                ? Image.network(
                                    'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                    width: 90,
                                    height: 130,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 90,
                                    height: 130,
                                    color: Colors.grey,
                                    child: const Icon(Icons.movie,
                                        color: Colors.white),
                                  ),
                          ),

                          const SizedBox(width: 15),

                          /// MOVIE INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [

                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 18),

                                    const SizedBox(width: 5),

                                    Text(
                                      movie.voteAverage
                                          .toStringAsFixed(1),
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),

                                    const SizedBox(width: 15),

                                    const Icon(Icons.calendar_month,
                                        color: Colors.white54,
                                        size: 16),

                                    const SizedBox(width: 5),

                                    Text(
                                      movie.releaseDate,
                                      style: const TextStyle(
                                          color: Colors.white54),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  movie.overview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// DELETE BUTTON
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            onPressed: () =>
                                _removeFavorite(movie.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}