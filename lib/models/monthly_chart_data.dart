class MonthlyChartData {
  final String month;
  final int monthNumber;
  final double value;

  MonthlyChartData({
    required this.month,
    required this.monthNumber,
    required this.value,
  });

  factory MonthlyChartData.fromJson(Map<String, dynamic> json) {
    return MonthlyChartData(
      month: json['month'],
      monthNumber: json['monthNumber'],
      value: json['value'].toDouble(),
    );
  }
}