import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_category_data.dart';
import '../models/ai_recommendation.dart';

class AIRecommendationService {
  final String baseUrl;

  AIRecommendationService({required this.baseUrl});

  Future<List<AICategoryData>> getAICategoryData() async {
    final response = await http.get(Uri.parse('$baseUrl/api/ai-categories'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map<AICategoryData>((json) => AICategoryData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load AI category data');
    }
  }

  Future<List<AIRecommendation>> getTextRecommendations() async {
    final response = await http.get(Uri.parse('$baseUrl/api/ai-text-recommendations'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map<AIRecommendation>((json) => AIRecommendation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load text recommendations');
    }
  }
}