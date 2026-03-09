import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/services/api_service.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {

  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchMovies(String query) async {

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final List<Map<String, dynamic>> results =
        await _apiService.searchMovies(query);

    setState(() {
      _searchResults = results.map((e) => Movie.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Search Movie",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(

                hintText: "Search movie title...",
                hintStyle: const TextStyle(color: Colors.white54),

                prefixIcon:
                    const Icon(Icons.search, color: Colors.white70),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    _searchMovies('');
                  },
                ),

                filled: true,
                fillColor: const Color(0xff1c1c1c),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: (value) => _searchMovies(value),
            ),
          ),

          /// CONTENT
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  )

                : _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.white30,
                            ),

                            SizedBox(height: 20),

                            Text(
                              "Search your favorite movies",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )

                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {

                          final Movie movie = _searchResults[index];

                          return Card(

                            color: const Color(0xff1c1c1c),
                            margin: const EdgeInsets.symmetric(vertical: 8),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),

                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailScreen(movie: movie),
                                ),
                              ),

                              child: Padding(
                                padding: const EdgeInsets.all(10),

                                child: Row(
                                  children: [

                                    /// POSTER
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(10),

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
                                              child: const Icon(
                                                Icons.movie,
                                                color: Colors.white,
                                              ),
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
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 8),

                                          Row(
                                            children: [

                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),

                                              const SizedBox(width: 5),

                                              Text(
                                                movie.voteAverage
                                                    .toStringAsFixed(1),
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),

                                              const SizedBox(width: 15),

                                              const Icon(
                                                Icons.calendar_month,
                                                color: Colors.white54,
                                                size: 16,
                                              ),

                                              const SizedBox(width: 5),

                                              Text(
                                                movie.releaseDate,
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            movie.overview,
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}