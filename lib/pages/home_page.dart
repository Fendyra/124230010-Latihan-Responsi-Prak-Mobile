import 'package:flutter/material.dart';
import 'package:latres_prak_mobile/models/anime_model.dart';
import 'package:latres_prak_mobile/pages/detail_page.dart';
import 'package:latres_prak_mobile/pages/login_page.dart';
import 'package:latres_prak_mobile/services/api_service.dart';
import 'package:latres_prak_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Anime> _animeList = [];
  List<Anime> _spotlightAnime = [];
  bool _isLoading = true;
  String? _errorMessage;

  late PageController _pageController;
  String? _selectedType = 'All';
  final List<String> _animeTypes = ['All', 'TV', 'Movie', 'OVA', 'Special'];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _fetchTopAnime();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTopAnime() async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
      _errorMessage = null;
    });

    try {
      final animeList = await apiService.fetchTopAnime(
        type: _selectedType == 'All' ? null : _selectedType?.toLowerCase(),
      );
      setState(() {
        _animeList = animeList;

        if (_selectedType == 'All') {
          _spotlightAnime = animeList.take(5).toList();
        } else {
          _spotlightAnime = [];
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _searchAnime(String query) async {
    if (query.isEmpty) {
      _fetchTopAnime();
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final animeList = await apiService.searchAnime(query);
      setState(() {
        _animeList = animeList;
        _spotlightAnime = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otsu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            if (!_isSearching) _buildCategoryFilters(),
            if (_spotlightAnime.isNotEmpty && !_isSearching) ...[
              _buildSectionTitle("Anime Spotlight"),
              _buildAnimeCarousel(_spotlightAnime),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                _isSearching
                    ? 'Search Results'
                    : 'Top Anime${_selectedType != 'All' ? ' - $_selectedType' : ''}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: OtsuColor.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : _animeList.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No anime found.'),
                              ),
                            )
                          : _buildAnimeGrid(_animeList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Discover",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: OtsuColor.primary,
                ),
              ),
              Text(
                "Find your next favorite show",
                style: TextStyle(
                  fontSize: 16,
                  color: OtsuColor.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: OtsuColor.primary,
        ),
      ),
    );
  }

  Widget _buildAnimeCarousel(List<Anime> animeList) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(anime: anime),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                image: DecorationImage(
                  image: NetworkImage(anime.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    anime.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search anime...",
          prefixIcon: const Icon(Icons.search, color: OtsuColor.grey),
          suffixIcon: _isSearching || _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchAnime('');
                  },
                )
              : null,
          fillColor: OtsuColor.surface,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: OtsuColor.primary, width: 2.0),
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _searchAnime(value);
          }
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _animeTypes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = _animeTypes[index];
          final isSelected = _selectedType == type;
          return ChoiceChip(
            label: Text(type),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : OtsuColor.primary,
              fontWeight: FontWeight.w600,
            ),
            selected: isSelected,
            selectedColor: OtsuColor.primary,
            backgroundColor: OtsuColor.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color:
                    isSelected ? OtsuColor.primary : OtsuColor.grey.withOpacity(0.5),
              ),
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedType = type;
                });
                _fetchTopAnime();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimeGrid(List<Anime> animeList) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20.0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: animeList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final anime = animeList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(anime: anime),
              ),
            );
          },
          child: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    child: Image.network(
                      anime.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    anime.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: OtsuColor.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
