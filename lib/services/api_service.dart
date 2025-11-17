import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latres_prak_mobile/models/anime_model.dart';

class ApiService {
  final String baseUrl = 'https://api.jikan.moe/v4';

  Future<List<Anime>> fetchTopAnime({String? type}) async {
    String url = '$baseUrl/top/anime';
    
    if (type != null && type.isNotEmpty) {
      url += '?type=$type';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top anime');
    }
  }

  Future<List<Anime>> searchAnime(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final response =
        await http.get(Uri.parse('$baseUrl/anime?q=${Uri.encodeComponent(query)}&limit=20'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search anime');
    }
  }
}