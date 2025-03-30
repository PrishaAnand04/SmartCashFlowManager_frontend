import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_page.dart';
import 'ai_recommendation.dart';
import 'monthly_summary.dart';
import 'settings.dart';

class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Expenses'),
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
            // Removed DropdownButton
            Text(
              "Total Spent: ₹10,500",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8), // Reduced spacing
            Text(
              "Most spending on essentials",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              "List of transactions in this category",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Total Expense: ₹15,000",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24), // Adjusted spacing
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
                          if(value%1==0){
                            return Text((labels[value.toInt()]));
                          }
                          return const SizedBox.shrink();
                        },
                        interval: 1,
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 4,
                  minY: 0,
                  maxY: 9,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 3),
                        FlSpot(1, 5),
                        FlSpot(2, 7),
                        FlSpot(3, 4),
                        FlSpot(4, 8),
                      ],
                      isCurved: true,
                      barWidth: 4,
                      color: Colors.green,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.3),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
          else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoriesPage()),
            );
          }
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AiRecommendationPage()),
            );
          }
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MonthlySummaryPage()),
            );
          }
          else if (index == 4) {
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
}