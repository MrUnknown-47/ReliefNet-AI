import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crisis_model.dart';

class ApiService {
  static const String baseUrl = 'https://reliefnet-ai-sokn.onrender.com/api';

  Future<List<CrisisModel>> getCrises() async {
    final response = await http.get(Uri.parse('$baseUrl/crisis'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CrisisModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load crises');
    }
  }

  Future<void> createCrisis(Map<String, dynamic> crisisData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/crisis/report'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(crisisData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create crisis: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> predictRisk(
      Map<String, dynamic> regionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict/'), // ← trailing slash
      headers: {'Content-Type': 'application/json'},
      body: json.encode(regionData),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to predict risk: ${response.body}');
    }
  }
}
