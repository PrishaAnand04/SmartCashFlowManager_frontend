import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the home page

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
  List<Map<String, String>> goals = [];
  bool isAddingGoal = false;

  final TextEditingController goalNameController = TextEditingController();
  final TextEditingController targetAmountController = TextEditingController();
  final TextEditingController timeframeController = TextEditingController();

  void _addGoal() {
    setState(() {
      isAddingGoal = true;
    });
  }

  void _saveGoal() {
    if (goalNameController.text.isNotEmpty &&
        targetAmountController.text.isNotEmpty &&
        timeframeController.text.isNotEmpty) {
      setState(() {
        goals.add({
          'goalName': goalNameController.text,
          'targetAmount': targetAmountController.text,
          'timeframe': timeframeController.text,
        });

        goalNameController.clear();
        targetAmountController.clear();
        timeframeController.clear();
        isAddingGoal = false;
      });
    }
  }

  void _cancelGoal() {
    setState(() {
      isAddingGoal = false;
      goalNameController.clear();
      targetAmountController.clear();
      timeframeController.clear();
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: goals.isEmpty && !isAddingGoal
                  ? Center(
                child: Text(
                  "No goals set yet!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView(
                children: [
                  ...goals.map((goal) => _buildGoalCard(goal)).toList(),
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
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

  Widget _buildGoalCard(Map<String, String> goal) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(goal['goalName']!,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
        Text("Target: ₹${goal['targetAmount']} • Timeframe: ${goal['timeframe']}"),
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
