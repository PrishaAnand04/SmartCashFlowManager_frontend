class AIRecommendation {
  final String title;
  final String description;

  AIRecommendation({
    required this.title,
    required this.description,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      title: json['title'],
      description: json['description'],
    );
  }
}