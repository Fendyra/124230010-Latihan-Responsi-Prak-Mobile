class Anime {
  final int malId;
  final String title;
  final String imageUrl;
  final String synopsis;
  final double score;
  final String? trailerId;
  final int? episodes;
  final String status;
  final String duration;
  final String rating;
  final String? season;
  final int? year;
  final List<String> genres;
  final int? rank;
  final int? popularity;
  final int? members;
  final int? favorites;
  final String type;
  final String source;
  final List<String> studios;
  final List<String> producers;
  final String? aired;
  final int? scoredBy;

  Anime({
    required this.malId,
    required this.title,
    required this.imageUrl,
    required this.synopsis,
    required this.score,
    this.trailerId,
    this.episodes,
    required this.status,
    required this.duration,
    required this.rating,
    this.season,
    this.year,
    required this.genres,
    this.rank,
    this.popularity,
    this.members,
    this.favorites,
    required this.type,
    required this.source,
    required this.studios,
    required this.producers,
    this.aired,
    this.scoredBy,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'],
      title: json['title'],
      imageUrl: json['images']['jpg']['large_image_url'],
      synopsis: json['synopsis'] ?? 'No synopsis available.',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      trailerId: json['trailer']?['youtube_id'],
      episodes: json['episodes'],
      status: json['status'] ?? 'Unknown',
      duration: json['duration'] ?? 'Unknown',
      rating: json['rating'] ?? 'Unknown',
      season: json['season'],
      year: json['year'],
      genres: (json['genres'] as List<dynamic>)
          .map((genre) => genre['name'] as String)
          .toList(),
      rank: json['rank'],
      popularity: json['popularity'],
      members: json['members'],
      favorites: json['favorites'],
      type: json['type'] ?? 'Unknown',
      source: json['source'] ?? 'Unknown',
      studios: (json['studios'] as List<dynamic>?)
          ?.map((studio) => studio['name'] as String)
          .toList() ?? [],
      producers: (json['producers'] as List<dynamic>?)
          ?.map((producer) => producer['name'] as String)
          .toList() ?? [],
      aired: json['aired']?['string'],
      scoredBy: json['scored_by'],
    );
  }
}