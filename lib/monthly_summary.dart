import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'ai_recommendation.dart';
import 'settings.dart';

class MonthlySummaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predicted Monthly Summary'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        automaticallyImplyLeading: false, // Removed back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              items: ['Saving and Transfer', 'Shopping', 'Food and Dining', 'Travel and Transportation', 'Miscellaneous', 'Essential', 'Entertainment', 'Subscription and Services']
                  .map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {},
              hint: Text('Select'),
              isExpanded: true,
              underline: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Largest Expense: ₹5,000 on Essentials",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "You've saved ₹10,000 more this month than last.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 12, // Corresponds to "Shopping"
                      title: 'Shopping',
                      color: Colors.green,
                      radius: 170,
                    ),
                    PieChartSectionData(
                      value: 200, // Corresponds to "Travel"
                      title: 'Travel',
                      color: Colors.purple,
                      radius: 170,
                    ),
                    PieChartSectionData(
                      value: 19, // Corresponds to "Food"
                      title: 'Food',
                      color: Colors.orange,
                      radius: 170,
                    ),
                    PieChartSectionData(
                      value: 263, // Extra Data Point from LineChart
                      title: 'Entertainment',
                      color: Colors.red,
                      radius: 170,
                    ),
                    PieChartSectionData(
                      value: 10, // Extra Data Point from LineChart
                      title: 'Subscriptions',
                      color: Colors.brown,
                      radius: 170,
                    ),
                    PieChartSectionData(
                      value: 430, // Extra Data Point from LineChart
                      title: 'Savings',
                      color: Colors.blue,
                      radius: 170,
                    ),
                    PieChartSectionData(
                      value: 20, // Extra Data Point from LineChart
                      title: 'Essentials',
                      color: Colors.grey,
                      radius: 170,
                    ),
                    PieChartSectionData(
                      value: 57, // Extra Data Point from LineChart
                      title: 'Miscellaneous',
                      color: Colors.yellow,
                      radius: 170,
                    ),
                  ],
                  sectionsSpace: 2, // Space between pie sections
                  centerSpaceRadius: 0, // Center empty space
                ), // PieChartData ends here
              ), // PieChart ends here
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // Highlight Reports tab
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CategoriesPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AiRecommendationPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MonthlySummaryPage()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
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
