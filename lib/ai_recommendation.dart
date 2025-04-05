import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'categories_page.dart';
import 'monthly_summary.dart';
import 'settings.dart';
import 'package:provider/provider.dart';
import 'models/ai_category_data.dart';
import 'models/ai_recommendation.dart';
import 'services/ai_recommendation_service.dart';

class AiRecommendationPage extends StatefulWidget {
  @override
  _AiRecommendationPageState createState() => _AiRecommendationPageState();
}

class _AiRecommendationPageState extends State<AiRecommendationPage> {
  late AIRecommendationService _aiService;
  List<AICategoryData> _categoryData = [];
  List<AIRecommendation> _textRecommendations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _timer;
  final Color currentColor = Colors.blue[400]!;
  final Color recommendedColor = Colors.green[400]!;

  @override
  void initState() {
    super.initState();
    _aiService = AIRecommendationService(baseUrl: 'http://192.168.100.107:3000');
    _loadData();
    _setupPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _aiService.getAICategoryData(),
        _aiService.getTextRecommendations(),
      ]);

      final categories = results[0] as List<AICategoryData>;
      final recommendations = results[1] as List<AIRecommendation>;

      setState(() {
        _categoryData = categories;
        _textRecommendations = recommendations;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _setupPolling() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!mounted) return;
      _loadData();
    });
  }

  double _calculateMaxY() {
    if (_categoryData.isEmpty) return 5000;
    final maxCurrent = _categoryData.map((e) => e.current).reduce((a, b) => a > b ? a : b);
    final maxRecommended = _categoryData.map((e) => e.recommended).reduce((a, b) => a > b ? a : b);
    return (maxCurrent > maxRecommended ? maxCurrent : maxRecommended) * 1.2;
  }

  Widget _buildChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < _categoryData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _categoryData[index].category,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return SizedBox.shrink();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateMaxY() / 5,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _categoryData.map((category) {
          final index = _categoryData.indexOf(category);
          return BarChartGroupData(
            x: index,
            groupVertically: false,
            barsSpace: 0,
            barRods: [
              BarChartRodData(
                toY: category.current,
                color: currentColor,
                width: 20,
                borderRadius: BorderRadius.circular(1.5),
              ),
              BarChartRodData(
                toY: category.recommended,
                color: recommendedColor,
                width: 20,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ],
          );
        }).toList(),
        groupsSpace: 24,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Spending Analysis",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Container(
            height: 300,
            child: _buildChart(),
          ),
          SizedBox(height: 20),
          _buildLegend(),
          SizedBox(height: 20),
          Text(
            "AI Recommendations for You",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ..._textRecommendations.map((recommendation) =>
              _buildRecommendationCard(recommendation.title, recommendation.description)
          ).toList(),
        ],
      ),
    );
  }

  // Keep the existing _buildLegend, _buildLegendItem, and _buildRecommendationCard methods
  // ... (same as original code)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Insights"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoriesPage()),
            );
          } else if (index == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AiRecommendationPage()));
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MonthlySummaryPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "AI Insights",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem("Current Spending", currentColor),
        SizedBox(width: 20),
        _buildLegendItem("Recommended Target", recommendedColor),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildRecommendationCard(String title, String description) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

}