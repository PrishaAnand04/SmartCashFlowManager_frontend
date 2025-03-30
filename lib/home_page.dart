import 'dart:math';
import 'package:http/http.dart' as http;
//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'categories_page.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts
import 'ai_recommendation.dart';
import 'monthly_summary.dart';
import 'settings.dart';
import 'set_goal_app.dart';
import 'manual_expense.dart';

import 'package:logger/logger.dart';

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

  int _selectedIndex = 0; // Track the selected tab
/*
  @override
  void initState() {
    super.initState();
    requestPermissions();
    startSmsListener();
  }
  Future<void> requestPermissions() async {
    final status = await Permission.sms.status;
    if (!status.isGranted) {
      final newStatus = await Permission.sms.request();
      if (newStatus.isGranted) {
        logger.d("SMS permission granted.");
      } else {
        logger.d("SMS permission denied.");
      }
    } else {
      logger.d("SMS permission already granted.");
    }
  }

  Telephony telephony = Telephony.instance;

  void startSmsListener() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        // Handle the incoming SMS message here.
        logger.d('Received SMS: ${message.body}');
        logger.d('Received SMS: ${message.body}');
        logger.d('Sender: ${message.address}');
        // Implement your logic here, e.g., verify an OTP, store the message, or display it in your app's UI.
      },
    );
  }
*/




  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation when tab is selected
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
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AiRecommendationPage()),
      );}
    else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MonthlySummaryPage()),
      );}
    else if (index == 4) {
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
                color: Colors.white70, // Temporary color to debug
                child: BarChart(
                  BarChartData(
                    maxY: 30,
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [BarChartRodData(toY: 27, color: Colors.blue, width: 12,borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(0),)
                        )],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [BarChartRodData(toY: 9, color: Colors.green, width: 12,borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(0),))],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [BarChartRodData(toY: 5, color: Colors.orange, width: 12,borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(0),))],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [BarChartRodData(toY: 15, color: Colors.purple, width: 12,borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(0),))],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [BarChartRodData(toY: 7, color: Colors.yellow, width: 12,borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(0),)
                        )],
                      ),
                      BarChartGroupData(
                        x: 5,
                        barRods: [BarChartRodData(toY: 4, color: Colors.grey, width: 12,borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(0),)
                        )],
                      ),
                      BarChartGroupData(
                        x: 6,
                        barRods: [BarChartRodData(toY: 17, color: Colors.red, width: 12,borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(0),)
                        )],
                      ),
                      BarChartGroupData(
                        x: 7,
                        barRods: [BarChartRodData(toY: 3, color: Colors.brown, width: 12,borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(0),)
                        )],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true,reservedSize: 30)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const categories = ['Saving', 'Shopping', 'Food', 'Travel', 'Misc.', 'Essential', 'Lifestyle', 'Subscription'];
                            return Padding(
                              padding: const EdgeInsets.only(top:8.0),
                              child: Transform.rotate(angle: -0.5,
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
                    gridData: FlGridData(show: false),
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
                "Recommended Suggestions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildSuggestionCard(
                "Spend ₹2,000 less on food & dining",
                "View Details",
              ),
              _buildSuggestionCard(
                "Plan your grocery budget under Essentials",
                "Explore Alternatives",
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
        currentIndex: _selectedIndex, // Highlight the selected tab
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Handle taps
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

  Widget _buildSuggestionCard(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        tileColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(title),
        trailing: Text(
          action,
          style: TextStyle(color: Colors.green),
        ),
      ),
    );
  }
}

