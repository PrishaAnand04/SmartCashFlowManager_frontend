// services/summary_data_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/monthly_summary_data.dart';

class SummaryDataService {
  final String baseUrl;

  SummaryDataService({required this.baseUrl});

  Future<List<MonthlySummaryData>> getMonthlySummary() async {
    final response = await http.get(Uri.parse('$baseUrl/monthly-summary'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => MonthlySummaryData.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load summary data');
    }
  }
}
