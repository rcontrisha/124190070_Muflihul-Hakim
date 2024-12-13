import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://www.amiiboapi.com/api/amiibo';

  /// Fetch all Amiibo data
  static Future<List<dynamic>> fetchAllAmiibos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['amiibo'];
    } else {
      throw Exception('Failed to load all Amiibos');
    }
  }

  /// Fetch Amiibo data by head
  static Future<List<dynamic>> fetchAmiiboByHead(String head) async {
    final response = await http.get(Uri.parse('$baseUrl/?head=$head'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['amiibo'] ?? []; // Return empty list if no results
    } else {
      throw Exception('Failed to load Amiibo by head: $head');
    }
  }
}
