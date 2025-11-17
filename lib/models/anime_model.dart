class Anime {
  final int malId;
  final String title;
  final String imageUrl;
  final double score;

  Anime({
    required this.malId,
    required this.title,
    required this.imageUrl,
    required this.score,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'],
      title: json['title'],
      imageUrl: json['images']['jpg']['image_url'],
      score: (json['score'] as num? ?? 0.0).toDouble(),
    );
  }
}