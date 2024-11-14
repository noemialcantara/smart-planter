import 'dart:convert';

import 'package:http/http.dart' as http;

class PlantCareProfileApi {
  static const String _baseUrl = 'https://perenual.com';

  Future<Map<String, dynamic>> fetchDescription(int speciesId) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/api/species-care-guide-list?key=sk-DCaL64755ec977dbc1092&species_id=${speciesId}'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> fetchGenusId(String genusName) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/api/species-list?key=sk-DCaL64755ec977dbc1092&q=${genusName}'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
