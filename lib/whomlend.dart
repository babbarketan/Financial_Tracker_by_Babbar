import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoanTrackerPage extends StatefulWidget {
  @override
  _LoanTrackerPageState createState() => _LoanTrackerPageState();
}

class _LoanTrackerPageState extends State<LoanTrackerPage> {
  List<Map<String, dynamic>> _loanHistory = [];

  @override
  void initState() {
    super.initState();
    _loadLoanHistory();
  }

  // Load the loan history from SharedPreferences
  _loadLoanHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyData = prefs.getString('spendingHistory');
    List<Map<String, dynamic>> spendingHistory = historyData != null
        ? List<Map<String, dynamic>>.from(jsonDecode(historyData))
        : [];

    // Filter only the "Friends/Lend" category (loans)
    List<Map<String, dynamic>> loans = spendingHistory
        .where((entry) => entry['category'] == 'Friends/Lend')
        .toList();

    setState(() {
      _loanHistory = loans;
    });
  }

  // Update the loan status (paid back or not) in SharedPreferences
  _updateLoanStatus(int index, bool isPaidBack) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyData = prefs.getString('spendingHistory');
    List<Map<String, dynamic>> spendingHistory = historyData != null
        ? List<Map<String, dynamic>>.from(jsonDecode(historyData))
        : [];

    // Update the specific loan entry with the new paid back status
    spendingHistory[index]['isPaidBack'] = isPaidBack;

    await prefs.setString('spendingHistory', jsonEncode(spendingHistory));

    setState(() {
      _loanHistory[index]['isPaidBack'] = isPaidBack;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment status updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Tracker'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 121, 219, 183),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loanHistory.isEmpty
            ? Center(
                child: Text(
                  'No loans to display!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: _loanHistory.length,
                itemBuilder: (context, index) {
                  final loan = _loanHistory[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.blueGrey),
                      title: Text(loan['payee']),
                      subtitle: Text('₹${loan['amount']} - ${loan['reason']}'),
                      trailing: Checkbox(
                        value: loan['isPaidBack'] ?? false,
                        onChanged: (bool? value) {
                          _updateLoanStatus(index, value ?? false);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
