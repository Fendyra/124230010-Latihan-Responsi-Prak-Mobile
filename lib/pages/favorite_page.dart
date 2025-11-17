import 'package:flutter/material.dart';
import 'package:latres_prak_mobile/models/anime_model.dart';
import 'package:latres_prak_mobile/pages/detail_page.dart';
import 'package:latres_prak_mobile/services/api_service.dart';
import 'package:latres_prak_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Anime>> _animeListFuture;
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _animeListFuture = ApiService().fetchTopAnime();
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _favoriteIds = prefs.getStringList('favorite_ids') ?? [];
      });
    }
  }

  void _refreshFavorites() {
    _loadFavoriteIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Anime>>(
          future: _animeListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              final List<Anime> allAnime = snapshot.data!;
              final List<Anime> favoriteAnimeList = allAnime
                  .where(
                      (anime) => _favoriteIds.contains(anime.malId.toString()))
                  .toList();

              if (favoriteAnimeList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 80, color: OtsuColor.grey.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No favorites yet',
                        style: TextStyle(fontSize: 18, color: OtsuColor.grey),
                      ),
                      const Text(
                        'Add anime to your favorites from the detail page.',
                        style: TextStyle(color: OtsuColor.grey),
                      ),
                    ],
                  ),
                );
              }

              return _buildFavoritesList(favoriteAnimeList);
            } else {
              return const Center(child: Text("No anime found."));
            }
          },
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<Anime> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final anime = favorites[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(anime: anime),
              ),
            );
            _refreshFavorites();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: OtsuColor.surface,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                  ),
                  child: Image.network(
                    anime.imageUrl,
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anime.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: OtsuColor.primary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: OtsuColor.accent, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              anime.score.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: OtsuColor.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Rank: #${anime.rank ?? 'N/A'}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: OtsuColor.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      color: OtsuColor.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
