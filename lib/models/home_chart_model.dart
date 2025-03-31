// home_chart_model.dart
class HomeChartData {
  final String category;
  final double total;
  final int count;

  HomeChartData({
    required this.category,
    required this.total,
    required this.count,
  });

  factory HomeChartData.fromJson(Map<String, dynamic> json) {
    return HomeChartData(
      category: json['_id'], // Ensure your API returns "_id" as category name
      total: (json['total'] as num).toDouble(), // Safer conversion
      count: json['count'] as int,
    );
  }
}