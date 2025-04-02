import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'ai_recommendation.dart';
import 'settings.dart';

class MonthlySummaryPage extends StatefulWidget {
  @override
  _MonthlySummaryPageState createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
  String? selectedCategory;
  final Map<String, Color> categoryColors = {
    'Shopping': Colors.green,
    'Travel': Colors.purple,
    'Food': Colors.orange,
    'Entertainment': Colors.red,
    'Subscriptions': Colors.brown,
    'Savings': Colors.blue,
    'Essentials': Colors.grey,
    'Miscellaneous': Colors.yellow,
  };

  List<PieChartSectionData> getSections() {
    return categoryColors.keys.map((category) {
      final isSelected = selectedCategory == null || selectedCategory == category;
      return PieChartSectionData(
        value: _getValueForCategory(category),
        title: '',
        color: isSelected ? categoryColors[category] : categoryColors[category]!.withOpacity(0.2),
        radius: isSelected ? 115 : 110,
      );
    }).toList();
  }

  double _getValueForCategory(String category) {
    switch (category) {
      case 'Shopping': return 12;
      case 'Travel': return 200;
      case 'Food': return 19;
      case 'Entertainment': return 263;
      case 'Subscriptions': return 10;
      case 'Savings': return 430;
      case 'Essentials': return 20;
      case 'Miscellaneous': return 57;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expected Monthly Expenses by Category'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('Select'),
                ),
                ...categoryColors.keys.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
              ],
              onChanged: (value) => setState(() => selectedCategory = value),
              value: selectedCategory,
              hint: Text('Select Category'),
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey.shade300),
            ),
            // ... Rest of the body remains unchanged
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Largest Expense: ₹5,000 on Essentials",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  "You've saved ₹10,000 more this month than last.",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: categoryColors.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(entry.key, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                )).toList(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: PieChart(
                  PieChartData(
                    sections: getSections(),
                    sectionsSpace: 0,
                    centerSpaceRadius: 0,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // ... Bottom navigation bar remains unchanged
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
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