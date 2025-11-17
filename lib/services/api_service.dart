import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latres_prak_mobile/models/anime_model.dart';

class ApiService {
  final String _baseUrl = "https://api.jikan.moe/v4";

  Future<List<Anime>> fetchTopAnime() async {
    final response = await http.get(Uri.parse('$_baseUrl/top/anime'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      
      return data.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top anime');
    }
  }
}