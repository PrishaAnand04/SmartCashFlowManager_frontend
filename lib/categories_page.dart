import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'ai_recommendation.dart';
import 'monthly_summary.dart';
import 'settings.dart';
import 'package:provider/provider.dart';
import 'models/monthly_chart_data.dart';
import 'services/chart_data_service.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late ChartDataService _chartDataService;
  List<MonthlyChartData> _chartData = [];
  double _totalSpent = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _chartDataService = ChartDataService(baseUrl: 'http://192.168.150.107:3000');
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
      final chartData = await _chartDataService.getMonthlyChartData();
      final total = chartData.fold(0.0, (sum, item) => sum + item.value);

      setState(() {
        _chartData = chartData;
        _totalSpent = total;
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
    if (_chartData.isEmpty) return 10000;
    final maxValue = _chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.5).ceilToDouble();
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateMaxY() / 3,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '₹${value.toInt()}',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
              reservedSize: 45,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < _chartData.length) {
                  try {
                    final date = DateFormat('MMMM y').parse(_chartData[value.toInt()].month);
                    return Transform.rotate(
                      angle: -0.785, // -45 degrees in radians
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } catch (e) {
                    return const SizedBox.shrink();
                  }
                }
                return const SizedBox.shrink();
              },
              interval: 1,
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: _chartData.isNotEmpty ? (_chartData.length - 1).toDouble() : 0,
        minY: 0,
        maxY: _calculateMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: _chartData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.value,
              );
            }).toList(),
            isCurved: true,
            barWidth: 4,
            color: Colors.green,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.3),
            ),
            dotData: FlDotData(show: true),
          ),
        ],
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
            "Total Spent: ₹${NumberFormat.currency(locale: 'en_IN', symbol: '').format(_totalSpent)}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Most spending in ${_getMostSpendingCategory()}",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Text(
            "List of transactions in this category",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            "Total Expense: ₹${NumberFormat.currency(locale: 'en_IN', symbol: '').format(_totalSpent)}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  String _getMostSpendingCategory() {
    if (_chartData.isEmpty) return 'essentials';
    final maxEntry = _chartData.reduce((a, b) => a.value > b.value ? a : b);
    try {
      final date = DateFormat('MMMM y').parse(maxEntry.month);
      return DateFormat('MMM').format(date);
    } catch (e) {
      return maxEntry.month;
    }
  }

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
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (int index) {
          if (index == 1) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              switch (index) {
                case 0: return HomePage();
                case 2: return AiRecommendationPage();
                case 3: return MonthlySummaryPage();
                case 4: return SettingsPage();
                default: return HomePage();
              }
            }),
          );
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