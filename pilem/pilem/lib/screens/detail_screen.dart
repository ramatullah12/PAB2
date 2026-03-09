import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {

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
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [

          /// APPBAR + POSTER
          SliverAppBar(
            expandedHeight: 350,
            backgroundColor: Colors.black,
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
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

          /// DETAIL MOVIE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),
                  

                  

                  /// RATING + RELEASE + FAVORITE
                  Row(
                    children: [

                      /// RATING
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.black),
                            const SizedBox(width: 5),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 15),

                      /// DATE
                      const Icon(Icons.calendar_month,
                          color: Colors.white70, size: 18),

                      const SizedBox(width: 5),

                      Text(
                        movie.releaseDate,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(width: 15),

                      /// FAVORITE BUTTON
                      IconButton(
                        icon: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              _isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// OVERVIEW TITLE
                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// OVERVIEW TEXT
                  Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : "No description available.",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
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