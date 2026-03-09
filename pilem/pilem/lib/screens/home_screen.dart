import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/services/api_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  List<Movie> _allMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final allData = await _apiService.getAllMovies();
      final trendingData = await _apiService.getTrendingMovies();
      final popularData = await _apiService.getPopularMovies();

      setState(() {
        _allMovies = allData.map((e) => Movie.fromJson(e)).toList();
        _trendingMovies = trendingData.map((e) => Movie.fromJson(e)).toList();
        _popularMovies = popularData.map((e) => Movie.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (_trendingMovies.isNotEmpty)
                        _buildHeroBanner(_trendingMovies.first),

                      _buildMoviesList(' Trending ', _trendingMovies),
                      _buildMoviesList(' Popular ', _popularMovies),
                      _buildMoviesList(' All Movies ', _allMovies),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// Premium AppBar
  Widget _buildAppBar() {
    return const SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "🎬 Pilem",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 15),
          child: Icon(Icons.search),
        )
      ],
    );
  }

  /// Hero Banner
  Widget _buildHeroBanner(Movie movie) {
    return Container(
      height: 460,
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
            fit: BoxFit.cover,
          ),

          /// gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 5),
                    Text(
                      movie.voteAverage?.toStringAsFixed(1) ?? "0",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

              ],
            ),
          )
        ],
      ),
    );
  }

  /// Movie List
  Widget _buildMoviesList(String title, List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(movie: movie),
                  ),
                ),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            movie.posterPath != null
                                ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                                : 'https://via.placeholder.com/150x220',
                            height: 200,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}