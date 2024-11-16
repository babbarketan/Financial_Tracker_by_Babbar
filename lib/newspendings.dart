import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class AddSpendingPage extends StatefulWidget {
  final Function(double) onAddSpending;

  AddSpendingPage({required this.onAddSpending});

  @override
  _AddSpendingPageState createState() => _AddSpendingPageState();
}

class _AddSpendingPageState extends State<AddSpendingPage> {
  final _amountController = TextEditingController();
  final _payeeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;

  // Category items with icons
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Clothes', 'icon': Icons.shopping_bag},
    {'name': 'Cabs/Travel', 'icon': Icons.directions_car},
    {'name': 'Friends/Lend', 'icon': Icons.group},
    {'name': 'Subscription', 'icon': Icons.subscriptions},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  // Submit form and add spending to history and update category totals
  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.tryParse(_amountController.text);
      final payee = _payeeController.text;
      final reason = _reasonController.text;
      final category = _selectedCategory;

      if (amount != null) {
        // Call the callback to update the total amount in DashboardScreen
        widget.onAddSpending(amount);

        // Save the entry to spending history in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? historyData = prefs.getString('spendingHistory');
        List<Map<String, dynamic>> spendingHistory = historyData != null
            ? List<Map<String, dynamic>>.from(jsonDecode(historyData))
            : [];

        // Add new spending entry with date and category
        spendingHistory.add({
          'amount': amount,
          'payee': payee,
          'reason': reason,
          'category': category,
          'date': DateTime.now().toString().split(' ')[0],
          'time': DateFormat('h:mm a').format(DateTime.now()).toLowerCase(),
        });

        await prefs.setString('spendingHistory', jsonEncode(spendingHistory));

        // Update category total in SharedPreferences
        double currentTotal = prefs.getDouble('$category-total') ?? 0.0;
        await prefs.setDouble('$category-total', currentTotal + amount);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Spending Added: ₹$amount to $payee for $reason')),
        );

        // Clear form fields
        _amountController.clear();
        _payeeController.clear();
        _reasonController.clear();
        setState(() {
          _selectedCategory = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Spending'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 121, 219, 183),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter the amount spent',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _payeeController,
                decoration: InputDecoration(
                  labelText: 'Whom to Pay',
                  hintText: 'Enter the name of the payee',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter whom to pay';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason for Payment',
                  hintText: 'Enter the reason for the payment',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_snippet),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the reason';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category of Payment',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Row(
                      children: [
                        Icon(category['icon'], color: Colors.blueGrey),
                        SizedBox(width: 10),
                        Text(category['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Add Spending'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 121, 219, 183),
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
