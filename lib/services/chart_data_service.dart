import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/monthly_chart_data.dart';

class ChartDataService {
  final String baseUrl;

  ChartDataService({required this.baseUrl});

  Future<List<MonthlyChartData>> getMonthlyChartData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/monthly-expenses'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MonthlyChartData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chart data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching chart data: $e');
    }
  }
}