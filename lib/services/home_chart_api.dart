// home_chart_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_chart_model.dart';

class HomeChartApi {
  static const String _baseUrl = 'http://192.168.150.107:3000';

  static Future<List<HomeChartData>> getChartData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/home-chart-data'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => HomeChartData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chart data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}