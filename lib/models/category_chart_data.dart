class CategoryChartData {
  final String category;
  final double value;

  CategoryChartData({
    required this.category,
    required this.value,
  });

  factory CategoryChartData.fromJson(Map<String, dynamic> json) {
    return CategoryChartData(
      category: json['category'],
      value: json['value'].toDouble(),
    );
  }
}