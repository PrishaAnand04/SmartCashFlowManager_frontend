import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/goal_model.dart';

class GoalApi {
  static const String _baseUrl = 'http://192.168.100.107:3000/api'; // Update with your endpoint

  static Future<void> addGoal(Map<String, String> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/addgoal'),  // Full endpoint: /api/addgoal
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add goal');
    }
  }

  static Future<List<GoalModel>> getGoals() async {
    final response = await http.get(Uri.parse('$_baseUrl/getgoals'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['goals'];
      return data.map((goal) => GoalModel.fromJson(goal)).toList();
    } else {
      throw Exception('Failed to load goals');
    }
  }
}