import 'package:flutter/material.dart';
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
  YoutubePlayerController? _controller;
  int _selectedStatusIndex = 0;

  bool _isFavorite = false;
  late SharedPreferences _prefs;

  bool _showTrailer = false;

  @override
  void initState() {
    super.initState();
    if (widget.anime.trailerId != null && widget.anime.trailerId!.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.anime.trailerId!,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    _prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = _prefs.getStringList('favorite_ids') ?? [];
    setState(() {
      _isFavorite = favoriteIds.contains(widget.anime.malId.toString());
    });
  }

  Future<void> _toggleFavorite() async {
    final List<String> favoriteIds = _prefs.getStringList('favorite_ids') ?? [];
    final String animeId = widget.anime.malId.toString();

    if (_isFavorite) {
      favoriteIds.remove(animeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Removed from favorites'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } else {
      favoriteIds.add(animeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Added to favorites!'),
          backgroundColor: Colors.green,
        ));
      }
    }

    await _prefs.setStringList('favorite_ids', favoriteIds);
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String? youtubeId) async {
    if (youtubeId == null || youtubeId.isEmpty) return;
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$youtubeId');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not launch YouTube URL'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildHeaderSection(),
              _buildWatchStatus(),
              _buildGenreTags(),
              _buildTrailerSection(),
              _buildSynopsisSection(),
              _buildInfoSection(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      backgroundColor: OtsuColor.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? OtsuColor.accent : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          widget.anime.imageUrl,
          fit: BoxFit.cover,
          color: Colors.black.withAlpha(77),
          colorBlendMode: BlendMode.darken,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error, color: OtsuColor.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              widget.anime.imageUrl,
              width: 110,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 110,
                height: 160,
                color: OtsuColor.grey.withAlpha(51),
                child: const Icon(Icons.error, color: OtsuColor.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.anime.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: OtsuColor.primary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: OtsuColor.accent, size: 28),
                    const SizedBox(width: 4),
                    Text(
                      widget.anime.score.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: OtsuColor.primary,
                      ),
                    ),
                    Text(
                      " (${widget.anime.scoredBy ?? 'N/A'} votes)",
                      style:
                          const TextStyle(fontSize: 14, color: OtsuColor.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatChip("Rank", "#${widget.anime.rank ?? 'N/A'}"),
                    const SizedBox(width: 8),
                    _buildStatChip(
                        "Popularity", "#${widget.anime.popularity ?? 'N/A'}"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: OtsuColor.secondary.withAlpha(77),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: OtsuColor.primary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: OtsuColor.primary)),
        ],
      ),
    );
  }

  Widget _buildWatchStatus() {
    final List<String> statuses = ["Want to Watch", "Watching", "Completed"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: List.generate(statuses.length, (int index) {
          return ChoiceChip(
            label: Text(statuses[index]),
            selected: _selectedStatusIndex == index + 1,
            selectedColor: OtsuColor.primary.withAlpha(204),
            labelStyle: TextStyle(
              color: _selectedStatusIndex == index + 1
                  ? Colors.white
                  : OtsuColor.primary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: OtsuColor.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: _selectedStatusIndex == index + 1
                    ? Colors.transparent
                    : OtsuColor.grey.withAlpha(128),
              ),
            ),
            onSelected: (bool selected) {
              setState(() => _selectedStatusIndex = selected ? index + 1 : 0);
            },
          );
        }),
      ),
    );
  }

  Widget _buildGenreTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: widget.anime.genres.map((genre) {
          return Chip(
            label: Text(genre),
            backgroundColor: OtsuColor.grey.withAlpha(38),
            labelStyle: const TextStyle(color: OtsuColor.primary, fontSize: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrailerSection() {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    if (!_showTrailer) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text("Putar Trailer"),
          style: ElevatedButton.styleFrom(
            backgroundColor: OtsuColor.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            setState(() {
              _showTrailer = true;
            });
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: OtsuColor.accent,
              progressColors: const ProgressBarColors(
                playedColor: OtsuColor.accent,
                handleColor: OtsuColor.accent,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.close_rounded),
                label: const Text("Tutup"),
                style: TextButton.styleFrom(foregroundColor: OtsuColor.grey),
                onPressed: () {
                  setState(() {
                    _showTrailer = false;
                    _controller?.pause();
                  });
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text("Buka di YouTube"),
                style: TextButton.styleFrom(foregroundColor: OtsuColor.primary),
                onPressed: () => _launchURL(widget.anime.trailerId),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: OtsuColor.grey,
                tooltip: "Reload",
                onPressed: () {
                  _controller?.load(widget.anime.trailerId!);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSynopsisSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Synopsis",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: OtsuColor.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: OtsuColor.surface,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Text(
              widget.anime.synopsis.isEmpty
                  ? "No synopsis available."
                  : widget.anime.synopsis,
              style: const TextStyle(
                  fontSize: 14, color: OtsuColor.text, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    const double verticalSpacing = 16.0;
    const double horizontalSpacing = 16.0;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Text(
            "Information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: OtsuColor.primary,
            ),
          ),
          const SizedBox(height: verticalSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoTile("Type", widget.anime.type)),
              const SizedBox(width: horizontalSpacing),
              Expanded(child: _buildInfoTile("Episodes", widget.anime.episodes?.toString() ?? 'N/A')),
            ],
          ),
          const SizedBox(height: verticalSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoTile("Status", widget.anime.status)),
              const SizedBox(width: horizontalSpacing),
              Expanded(child: _buildInfoTile("Aired", widget.anime.aired ?? 'N/A')),
            ],
          ),
          const SizedBox(height: verticalSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoTile("Duration", widget.anime.duration)),
              const SizedBox(width: horizontalSpacing),
              Expanded(child: _buildInfoTile("Rating", widget.anime.rating)),
            ],
          ),
          const SizedBox(height: verticalSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoTile("Source", widget.anime.source)),
              const SizedBox(width: horizontalSpacing),
              Expanded(
                child: _buildInfoTile(
                  "Season",
                  "${widget.anime.season?.capitalize() ?? 'N/A'} ${widget.anime.year ?? ''}"
                )
              ),
            ],
          ),
          const SizedBox(height: verticalSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoTile("Members", widget.anime.members?.toString() ?? 'N/A')),
              const SizedBox(width: horizontalSpacing),
              Expanded(child: _buildInfoTile("Favorites", widget.anime.favorites?.toString() ?? 'N/A')),
            ],
          ),
          const SizedBox(height: verticalSpacing),
          _buildInfoTile("Studios",
              widget.anime.studios.join(', ').isEmpty ? 'N/A' : widget.anime.studios.join(', ')),
          const SizedBox(height: verticalSpacing),
          _buildInfoTile("Producers",
              widget.anime.producers.join(', ').isEmpty ? 'N/A' : widget.anime.producers.join(', ')),
        ]
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(
          title, 
          style: const TextStyle(fontSize: 13, color: OtsuColor.grey)
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: OtsuColor.primary,
          ),
        ),
    ]);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}