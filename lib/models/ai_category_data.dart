class AICategoryData {
  final String category;
  final double current;
  final double recommended;

  AICategoryData({
    required this.category,
    required this.current,
    required this.recommended,
  });

  factory AICategoryData.fromJson(Map<String, dynamic> json) {
    return AICategoryData(
      category: json['category'],
      current: json['current'].toDouble(),
      recommended: json['recommended'].toDouble(),
    );
  }
}