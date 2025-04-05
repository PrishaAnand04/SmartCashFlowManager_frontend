import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_chart_data.dart';

class CategoryDataService {
  final String baseUrl;

  CategoryDataService({required this.baseUrl});

  Future<List<CategoryChartData>> getCategoryData() async {
    final response = await http.get(Uri.parse('$baseUrl/api/category-data'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CategoryChartData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load category data');
    }
  }
}