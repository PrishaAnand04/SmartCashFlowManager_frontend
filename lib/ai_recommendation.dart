import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'monthly_summary.dart';
import 'settings.dart';

class AiRecommendationPage extends StatelessWidget {
  // Sample data for the chart (current vs recommended)
  final Map<String, List<double>> categoryData = {
    'Food': [4500, 3500],
    'Lifestyle': [3000, 2200],
    'Shopping': [2500, 1800],
    'Misc.': [1500, 1000],
    'Subscription': [800, 500],
    'Travel': [2000, 1500],
  };

  final Color currentColor = Colors.blue[400]!;
  final Color recommendedColor = Colors.green[400]!;

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
      body: Padding(
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
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5000,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              categoryData.keys.elementAt(index),
                              style: TextStyle(fontSize: 12),textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1000,
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: categoryData.keys.map((category) {
                    final index = categoryData.keys.toList().indexOf(category);
                    return BarChartGroupData(
                      x: index,
                      groupVertically: false,
                      barsSpace: 0,
                      barRods: [
                        BarChartRodData(
                          toY: categoryData[category]![0],
                          color: currentColor,
                          width: 20,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                        BarChartRodData(
                          toY: categoryData[category]![1],
                          color: recommendedColor,
                          width: 20,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ],
                    );
                  }).toList(),
                  groupsSpace: 24
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildLegend(),
            SizedBox(height: 20),
            Text(
              "AI Recommendations for You",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildRecommendationCard(
              "Reduce Spending on Fast Food",
              "Consider home-cooked meals to save ₹1,500 per month.",
            ),
          ],
        ),
      ),
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