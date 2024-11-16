import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetFirstDayPage extends StatefulWidget {
  @override
  _SetFirstDayPageState createState() => _SetFirstDayPageState();
}

class _SetFirstDayPageState extends State<SetFirstDayPage> {
  DateTime? _firstDay;
  double _lastMonthTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFirstDay();
    _loadLastMonthTotal();
  }

  // Load the first day of the month from SharedPreferences
  _loadFirstDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstDayString = prefs.getString('firstDay');
    if (firstDayString != null) {
      setState(() {
        _firstDay = DateTime.parse(firstDayString);
      });
    }
  }

  // Load the last month's total amount from SharedPreferences
  _loadLastMonthTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastMonthTotal = prefs.getDouble('lastMonthTotal') ?? 0.0;
    });
  }

  // Save the first day of the month in SharedPreferences
  _setFirstDay(DateTime firstDay) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstDay', firstDay.toIso8601String());
    setState(() {
      _firstDay = firstDay;
    });
  }

  // Check if a month has passed and reset data if needed
  _checkAndResetData() async {
    if (_firstDay == null) return;

    DateTime now = DateTime.now();
    if (now.month != _firstDay!.month) {
      // A month has passed, reset the spending data
      await _resetData();

      // Update the first day to the new month
      await _setFirstDay(DateTime(now.year, now.month, 1));
    }
  }

  // Reset the spending data and store the total of last month
  _resetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store last month's total spending
    double currentTotal = prefs.getDouble('totalAmount') ?? 0.0;
    await prefs.setDouble('lastMonthTotal', currentTotal);

    // Reset the totals for this month
    await prefs.setDouble('totalAmount', 0.0);
    await prefs.setDouble('Food-total', 0.0);
    await prefs.setDouble('Cabs/Travel-total', 0.0);
    await prefs.setDouble('Clothes-total', 0.0);
    await prefs.setDouble('Other-total', 0.0);
    await prefs.setDouble('Subscription-total', 0.0);

    // Refresh the UI after resetting
    setState(() {
      _lastMonthTotal = currentTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set First Day of the Month",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 5, 19, 77), // Custom dark blue
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white), // Custom back arrow icon
          onPressed: () {
            Navigator.pop(context); // Perform the back navigation
          },
        ),
      ),
      body: Container(
        color: Colors.white, // Solid white background for simplicity
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the current first day
            _firstDay == null
                ? Text(
                    "No first day set yet.",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )
                : Text(
                    "First day of the month: ${_firstDay!.toLocal()}",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
            SizedBox(height: 40),

            // Button to set the first day of the month
            ElevatedButton.icon(
              onPressed: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _firstDay ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  _setFirstDay(
                      DateTime(selectedDate.year, selectedDate.month, 1));
                }
              },
              icon: Icon(Icons.date_range, color: Colors.white),
              label: Text(
                "Set First Day of the Month",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF6A82FB),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
            ),
            SizedBox(height: 30),

            // Display last month's total spending
            _lastMonthTotal == 0.0
                ? Text(
                    "No data for the last month.",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  )
                : Text(
                    "Last month's total spending: ₹${_lastMonthTotal.toStringAsFixed(2)}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
            SizedBox(height: 40),

            // Button to check and reset data
            ElevatedButton.icon(
              onPressed: () {
                _checkAndResetData(); // Check if a month has passed and reset
              },
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text(
                "Check and Reset Spendings",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFFFA726),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
