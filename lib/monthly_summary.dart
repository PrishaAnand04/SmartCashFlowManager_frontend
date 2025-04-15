import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'ai_recommendation.dart';
import 'settings.dart';
import 'models/monthly_summary_data.dart';
import 'services/summary_data_service.dart';
import 'dart:convert';

class MonthlySummaryPage extends StatefulWidget {
  @override
  _MonthlySummaryPageState createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
  String? selectedCategory;
  List<MonthlySummaryData> _summaryData = [];
  Timer? _timer;
  bool _isLoading = true;
  String _errorMessage = '';
  int touchedIndex = -1;

  final String baseUrl = 'http://192.168.150.107:3000/api';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _setupPolling();
  }

  void _setupPolling() {
    _timer = Timer.periodic(Duration(seconds: 30), (_) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/monthly-summary'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<MonthlySummaryData> data = responseData
            .map((item) => MonthlySummaryData.fromJson(item))
            .toList();

        setState(() {
          _summaryData = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data from server');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<PieChartSectionData> getSections(double total) {
    return _summaryData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = Color(int.parse(data.colorHex.replaceFirst('#', '0xff')));
      final isSelected = selectedCategory == null || selectedCategory == data.category;
      final isTouched = index == touchedIndex;

      return PieChartSectionData(
        value: data.value,
        title: isTouched ? '${(data.value / total * 100).toStringAsFixed(1)}%' : '',
        color: isSelected ? color : color.withOpacity(0.2),
        radius: isTouched ? 125 : (isSelected ? 150 : 125),
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = _summaryData.fold(0.0, (sum, data) => sum + data.value);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expected Monthly Expenses'),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Select'),
                    ),
                    ..._summaryData.map((data) => DropdownMenuItem(
                      value: data.category,
                      child: Text('${data.category} (${data.range})'),
                    )),
                  ],
                  onChanged: (value) => setState(() => selectedCategory = value),
                  value: selectedCategory,
                  hint: Text('Select Category'),
                  isExpanded: true,
                  underline: Container(height: 1, color: Colors.grey.shade300),
                ),
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
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: _summaryData.map((data) {
                          final color = Color(int.parse(data.colorHex.replaceFirst('#', '0xff')));
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('${data.category} (${data.range})',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 300,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                                  setState(() {
                                    if (event.isInterestedForInteractions &&
                                        response != null &&
                                        response.touchedSection != null) {
                                      touchedIndex = response.touchedSection!.touchedSectionIndex;
                                    } else {
                                      touchedIndex = -1;
                                    }
                                  });
                                },
                              ),
                              sections: getSections(total),
                              sectionsSpace: 0,
                              centerSpaceRadius: 0,
                              startDegreeOffset: -90,
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (touchedIndex != -1 && touchedIndex < _summaryData.length)
                                  Text(
                                    '${(_summaryData[touchedIndex].value / total * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                if (touchedIndex != -1 && touchedIndex < _summaryData.length)
                                  Text(
                                    _summaryData[touchedIndex].category,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                if (touchedIndex == -1)
                                  Text(
                                    'Tap to view',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
