import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'models/goal_model.dart';
import 'services/goal_api.dart';

void main() {
  runApp(SetGoalPage());
}

class SetGoalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoalSettingPage(),
    );
  }
}

class GoalSettingPage extends StatefulWidget {
  @override
  _GoalSettingPageState createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  List<GoalModel> goals = [];
  bool isAddingGoal = false;
  bool isLoading = true;

  final TextEditingController goalNameController = TextEditingController();
  final TextEditingController targetAmountController = TextEditingController();
  final TextEditingController timeframeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final fetchedGoals = await GoalApi.getGoals();
      setState(() {
        goals = fetchedGoals;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load goals: ${e.toString()}')),
      );
    }
  }

  void _addGoal() {
    setState(() => isAddingGoal = true);
  }

  Future<void> _saveGoal() async {
    if (goalNameController.text.isNotEmpty &&
        targetAmountController.text.isNotEmpty &&
        timeframeController.text.isNotEmpty) {
      try {
        final data = {
          'goalName': goalNameController.text,
          'targetAmount': targetAmountController.text,
          'timeframe': timeframeController.text,
        };

        await GoalApi.addGoal(data);
        await _loadGoals(); // Refresh list from server

        _clearControllers();
        setState(() => isAddingGoal = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Goal saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save goal: ${e.toString()}')),
        );
      }
    }
  }

  void _clearControllers() {
    goalNameController.clear();
    targetAmountController.clear();
    timeframeController.clear();
  }

  void _cancelGoal() {
    setState(() {
      isAddingGoal = false;
      _clearControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set Goals", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : goals.isEmpty && !isAddingGoal
                  ? Center(
                child: Text(
                  "No goals set yet!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView(
                children: [
                  ...goals.map((goal) => _buildGoalCard(goal)),
                  if (isAddingGoal) _buildGoalForm(),
                ],
              ),
            ),
            _buildAddNewGoalButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Goal Name", goalNameController),
            _buildTextField("Target Amount", targetAmountController,
                keyboardType: TextInputType.number),
            _buildTextField("Timeframe (e.g., 6 months)", timeframeController),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Done", style: TextStyle(color: Colors.white)),
                ),
                OutlinedButton(
                  onPressed: _cancelGoal,
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green)),
                  child: Text("Cancel", style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(goal.goalName,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            "Target: ₹${goal.targetAmount} • Timeframe: ${goal.timeframe}"),
      ),
    );
  }

  Widget _buildAddNewGoalButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _addGoal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text("Add New Goal", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
