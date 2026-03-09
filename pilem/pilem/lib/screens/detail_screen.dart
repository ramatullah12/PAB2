import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList('favorites') ?? [];

    final isFav = favorites.any((jsonStr) {
      final Map<String, dynamic> movieMap = json.decode(jsonStr);
      return movieMap['id'] == widget.movie.id;
    });

    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList('favorites') ?? [];

    if (_isFavorite) {
      favorites.removeWhere((jsonStr) {
        final Map<String, dynamic> movieMap = json.decode(jsonStr);
        return movieMap['id'] == widget.movie.id;
      });
    } else {
      favorites.add(json.encode(widget.movie.toJson()));
    }

    await prefs.setStringList('favorites', favorites);

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      body: CustomScrollView(
        slivers: [

          /// 🔥 HERO BANNER
          SliverAppBar(
            expandedHeight: 380,
            backgroundColor: Colors.transparent,
            pinned: true,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [

                  Image.network(
                    movie.backdropPath.isNotEmpty
                        ? 'https://image.tmdb.org/t/p/w500${movie.backdropPath}'
                        : 'https://via.placeholder.com/500x300',
                    fit: BoxFit.cover,
                  ),

                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black87,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🔥 CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// POSTER + TITLE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// POSTER
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            movie.posterPath != null
                                ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                                : 'https://via.placeholder.com/150x220',
                            height: 200,
                            width: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      /// TITLE + INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              movie.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [

                                const Icon(Icons.star,
                                    color: Colors.amber),

                                const SizedBox(width: 5),

                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                const Icon(Icons.calendar_today,
                                    size: 16,
                                    color: Colors.white70),

                                const SizedBox(width: 5),

                                Text(
                                  movie.releaseDate,
                                  style: const TextStyle(
                                      color: Colors.white70),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            /// FAVORITE BUTTON
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFavorite
                                    ? Colors.red
                                    : Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                              ),
                              icon: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: Text(
                                _isFavorite
                                    ? "Remove Favorite"
                                    : "Add Favorite",
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// PLAY BUTTON
                  

                  const SizedBox(height: 30),

                  /// OVERVIEW
                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : "No description available.",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}