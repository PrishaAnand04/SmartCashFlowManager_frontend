import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the home page

void main() {
  runApp(ManualExpensePage());
}

class ManualExpensePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExpenseEntryPage(),
    );
  }
}

class ExpenseEntryPage extends StatefulWidget {
  @override
  _ExpenseEntryPageState createState() => _ExpenseEntryPageState();
}

class _ExpenseEntryPageState extends State<ExpenseEntryPage> {
  List<Map<String, String>> expenses = [];
  bool isAddingExpense = false;

  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController expenseMonthController = TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();

  void _addExpense() {
    setState(() {
      isAddingExpense = true;
    });
  }

  void _saveExpense() {
    if (expenseNameController.text.isNotEmpty &&
        expenseMonthController.text.isNotEmpty &&
        expenseAmountController.text.isNotEmpty) {
      setState(() {
        expenses.add({
          'expenseName': expenseNameController.text,
          'expenseMonth': expenseMonthController.text,
          'expenseAmount': expenseAmountController.text,
        });

        expenseNameController.clear();
        expenseMonthController.clear();
        expenseAmountController.clear();
        isAddingExpense = false;
      });
    }
  }

  void _cancelExpense() {
    setState(() {
      isAddingExpense = false;
      expenseNameController.clear();
      expenseMonthController.clear();
      expenseAmountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Manual Expense", style: TextStyle(color: Colors.white)),
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
              child: expenses.isEmpty && !isAddingExpense
                  ? Center(
                child: Text(
                  "No expenses added yet!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView(
                children: [
                  ...expenses.map((expense) => _buildExpenseCard(expense)).toList(),
                  if (isAddingExpense) _buildExpenseForm(),
                ],
              ),
            ),
            _buildAddNewExpenseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Expense Name", expenseNameController),
            _buildTextField("Expense Month", expenseMonthController),
            _buildTextField("Expense Amount", expenseAmountController,
                keyboardType: TextInputType.number),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveExpense,
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Done", style: TextStyle(color: Colors.white)),
                ),
                OutlinedButton(
                  onPressed: _cancelExpense,
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

  Widget _buildExpenseCard(Map<String, String> expense) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(expense['expenseName']!,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
        Text("Month: ${expense['expenseMonth']} • Amount: ₹${expense['expenseAmount']}"),
      ),
    );
  }

  Widget _buildAddNewExpenseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _addExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text("Add Cash Payment", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
