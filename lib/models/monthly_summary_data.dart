// models/monthly_summary_data.dart
class MonthlySummaryData {
  final String category;
  final double value;
  final String colorHex;
  final String range;

  MonthlySummaryData({
    required this.category,
    required this.value,
    required this.colorHex,
    required this.range,
  });

  factory MonthlySummaryData.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryData(
      category: json['category'],
      value: (json['value'] as num).toDouble(),
      colorHex: json['colorHex'],
      range: json['range'],
    );
  }
}
