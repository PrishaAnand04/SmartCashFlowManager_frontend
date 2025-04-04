class GoalModel {
  final String goalName;
  final String targetAmount;
  final String timeframe;

  GoalModel({
    required this.goalName,
    required this.targetAmount,
    required this.timeframe,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      goalName: json['goalName'],
      targetAmount: json['targetAmount'],
      timeframe: json['timeframe'],
    );
  }

  Map<String, dynamic> toJson() => {
    'goalName': goalName,
    'targetAmount': targetAmount,
    'timeframe': timeframe,
  };
}