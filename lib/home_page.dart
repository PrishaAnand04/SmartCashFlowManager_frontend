import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'categories_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai_recommendation.dart';
import 'monthly_summary.dart';
import 'settings.dart';
import 'set_goal_app.dart';
import 'manual_expense.dart';
import 'package:logger/logger.dart';
import 'models/category_chart_data.dart';
import 'services/category_data_service.dart';
import 'models/ai_recommendation.dart';
import 'services/ai_recommendation_service.dart';

final logger = Logger();

Future<void> requestPermissions() async {
  final status = await Permission.sms.status;
  if (status.isDenied) {
    await Permission.sms.request();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late CategoryDataService _categoryDataService;
  late AIRecommendationService _aiRecommendationService;
  List<CategoryChartData> _categoryData = [];
  List<AIRecommendation> _recommendations = [];
  bool _isLoading = true;
  bool _isRecommendationsLoading = true;
  String _errorMessage = '';
  String _recommendationsError = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _categoryDataService = CategoryDataService(baseUrl: 'http://192.168.150.107:3000');
    _aiRecommendationService = AIRecommendationService(baseUrl: 'http://192.168.150.107:3000');
    _loadCategoryData();
    _loadRecommendations();
    _setupPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCategoryData() async {
    try {
      final data = await _categoryDataService.getCategoryData();
      setState(() {
        _categoryData = data;
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

  Future<void> _loadRecommendations() async {
    try {
      final data = await _aiRecommendationService.getTextRecommendations();
      setState(() {
        _recommendations = data.where((rec) => rec.title == "Recommendations").toList();
        _isRecommendationsLoading = false;
        _recommendationsError = '';
      });
    } catch (e) {
      setState(() {
        _isRecommendationsLoading = false;
        _recommendationsError = 'Failed to load recommendations: ${e.toString()}';
      });
    }
  }

  void _setupPolling() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!mounted) return;
      _loadCategoryData();
      _loadRecommendations();
    });
  }

  double _calculateInterval(double maxY) {
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    return maxY / 5;
  }

  double _calculateMaxY() {
    if (_categoryData.isEmpty) return 33;
    final maxValue = _categoryData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return maxValue + 3;
  }

  List<BarChartGroupData> _buildBarGroups() {
    const categories = ['Saving', 'Shopping', 'Food', 'Travel', 'Misc.', 'Essential', 'Lifestyle', 'Subscription'];
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.yellow, Colors.grey, Colors.red, Colors.brown
    ];

    return List.generate(8, (index) {
      final categoryValue = _categoryData.firstWhere(
            (item) => item.category == categories[index],
        orElse: () => CategoryChartData(category: categories[index], value: 0),
      ).value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: categoryValue,
            color: colors[index],
            width: 12,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(4),
              bottom: Radius.zero,
            ),
          ),
        ],
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
        MaterialPageRoute(builder: (context) => AiRecommendationPage()),
      );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, User!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Here’s your financial overview.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Container(
                height: 200,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : BarChart(
                  BarChartData(
                    maxY: _calculateMaxY(),
                    barGroups: _buildBarGroups(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: _calculateInterval(_calculateMaxY()),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '₹${value.toInt()}',
                              style: TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const categories = ['Saving', 'Shopping', 'Food', 'Travel', 'Misc.', 'Essential', 'Lifestyle', 'Subscription'];
                            return Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  categories[value.toInt()],
                                  style: TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      ),
                      verticalInterval: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(Icons.bookmark, "Largest Expense"),
                  _buildIconButton(Icons.favorite, "Frequent Spending"),
                  _buildIconButton(Icons.calendar_today, "Upcoming Bills"),
                ],
              ),
              SizedBox(height: 24),
              Text(
                "Recommendations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (_recommendationsError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _recommendationsError,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              else if (_isRecommendationsLoading)
                Center(child: CircularProgressIndicator())
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = _recommendations[index];
                    return _buildRecommendationCard(
                      recommendation.title,
                      recommendation.description,
                    );
                  },
                ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ManualExpensePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text("Cash Payment", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SetGoalPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                      ),
                      child: Text(
                        "Set Financial Goal",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
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

  Widget _buildIconButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.green,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}