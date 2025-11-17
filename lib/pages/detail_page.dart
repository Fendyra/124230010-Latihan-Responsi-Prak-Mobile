import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:latres_prak_mobile/models/anime_model.dart';
import 'package:latres_prak_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailPage extends StatefulWidget {
  final Anime anime;
  const DetailPage({super.key, required this.anime});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late YoutubePlayerController _youtubeController;
  late Future<bool> _isFavoriteFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.anime.trailerId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.anime.trailerId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
    _isFavoriteFuture = _checkIfFavorite();
  }

  Future<bool> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favoriteAnime') ?? [];
    bool isFav = favorites.contains(widget.anime.malId.toString());
    setState(() {
      _isFavorite = isFav;
    });
    return isFav;
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favoriteAnime') ?? [];
    
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      favorites.add(widget.anime.malId.toString());
    } else {
      favorites.remove(widget.anime.malId.toString());
    }
    
    await prefs.setStringList('favoriteAnime', favorites);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch YouTube')),
      );
    }
  }

  @override
  void dispose() {
    if (widget.anime.trailerId != null) {
      _youtubeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildSliverContent(),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      backgroundColor: OtsuColor.background,
      elevation: 0,
      pinned: true,
      iconTheme: const IconThemeData(color: OtsuColor.primary),
      actionsIconTheme: const IconThemeData(color: OtsuColor.primary),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.anime.imageUrl,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, OtsuColor.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FutureBuilder<bool>(
          future: _isFavoriteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? IconlyBold.heart : IconlyLight.heart,
                  color: _isFavorite ? Colors.red : OtsuColor.primary,
                  size: 28,
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
        ),
      ],
    );
  }

  SliverList _buildSliverContent() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.anime.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: OtsuColor.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildScoreAndGenres(),
                const SizedBox(height: 24),
                _buildSectionTitle("Synopsis"),
                Text(
                  widget.anime.synopsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: OtsuColor.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.anime.trailerId != null) ...[
                  _buildSectionTitle("Trailer"),
                  _buildYoutubePlayer(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OtsuColor.primary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => _launchURL("https://www.youtube.com/watch?v=${widget.anime.trailerId}"),
                    icon: const Icon(IconlyBold.play, size: 20),
                    label: const Text("Watch on YouTube"),
                  ),
                  const SizedBox(height: 24),
                ],
                _buildSectionTitle("Details"),
                _buildDetailGrid(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreAndGenres() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: OtsuColor.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(IconlyBold.star, color: OtsuColor.primary, size: 20),
              const SizedBox(width: 6),
              Text(
                widget.anime.score.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: OtsuColor.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 35,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: widget.anime.genres.map((genre) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: Text(genre),
                  backgroundColor: OtsuColor.surface,
                  labelStyle: const TextStyle(color: OtsuColor.primary, fontWeight: FontWeight.bold),
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYoutubePlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: YoutubePlayer(
        controller: _youtubeController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: OtsuColor.primary,
        progressColors: const ProgressBarColors(
          playedColor: OtsuColor.primary,
          handleColor: OtsuColor.primary,
        ),
      ),
    );
  }

  Widget _buildDetailGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      children: [
        _buildDetailCard("Episodes", widget.anime.episodes?.toString() ?? 'N/A'),
        _buildDetailCard("Status", widget.anime.status),
        _buildDetailCard("Duration", widget.anime.duration),
        _buildDetailCard("Rating", widget.anime.rating),
        _buildDetailCard("Season", "${widget.anime.season ?? ''} ${widget.anime.year ?? ''}"),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OtsuColor.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: OtsuColor.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: OtsuColor.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
}