import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';

import 'categories_page.dart';
import 'ai_recommendation.dart';
import 'monthly_summary.dart';
import 'settings.dart';
import 'set_goal_app.dart';
import 'manual_expense.dart';
import 'services/home_chart_api.dart';
import 'models/home_chart_model.dart';

final logger = Logger();

Future<void> requestPermissions() async {
  if (await Permission.sms.isDenied) {
    await Permission.sms.request();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<HomeChartData>> _chartData;
  int _selectedIndex = 0;

  final List<HomeChartData> _defaultData = [
    HomeChartData(category: "Saving", total: 5, count: 0),
    HomeChartData(category: "Shopping", total: 10, count: 1),
    HomeChartData(category: "Food", total: 15, count: 2),
    HomeChartData(category: "Travel", total: 8, count: 3),
    HomeChartData(category: "Misc.", total: 12, count: 4),
    HomeChartData(category: "Essential", total: 18, count: 5),
    HomeChartData(category: "Lifestyle", total: 9, count: 6),
    HomeChartData(category: "Subscription", total: 7, count: 7),
  ];

  @override
  void initState() {
    super.initState();
    _chartData = _fetchChartData();
  }

  Future<List<HomeChartData>> _fetchChartData() async {
    try {
      final fetchedData = await HomeChartApi.getChartData();
      return fetchedData.isNotEmpty ? fetchedData : _defaultData;
    } catch (e) {
      logger.e("Error fetching chart data: $e");
      return _defaultData;
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    final pages = [
      null,
      CategoriesPage(),
      AiRecommendationPage(),
      MonthlySummaryPage(),
      SettingsPage()
    ];

    if (index != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pages[index]!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.white, automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, User!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Here’s your financial overview.", style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 24),

            FutureBuilder<List<HomeChartData>>(
              future: _chartData,
              builder: (context, snapshot) {
                final data = snapshot.data ?? _defaultData;

                return Container(
                  height: 200,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white70,
                  child: BarChart(
                    BarChartData(
                      maxY: data.map((e) => e.total).reduce(max) + 5,
                      barGroups: data.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: min(entry.value.total, 30),
                              color: Colors.green,
                              width: 12,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 25,
                            interval: 7,  // Reduces label clutter
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= _defaultData.length) return SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Transform.rotate(
                                  angle: -0.4,
                                  child: Text(
                                    _defaultData[value.toInt()].category,
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                  ),
                );
              },
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
            Text("Recommended Suggestions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildSuggestionCard("Spend ₹2,000 less on food & dining", "View Details"),
            _buildSuggestionCard("Plan your grocery budget under Essentials", "Explore Alternatives"),

            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManualExpensePage())),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Cash Payment", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SetGoalPage())),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.green)),
                    child: Text("Set Financial Goal", style: TextStyle(color: Colors.green)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: "AI Insights"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(radius: 30, backgroundColor: Colors.green, child: Icon(icon, color: Colors.white, size: 28)),
        SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildSuggestionCard(String title, String action) {
    return ListTile(
      tileColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(title),
      trailing: Text(action, style: TextStyle(color: Colors.green)),
    );
  }
}
