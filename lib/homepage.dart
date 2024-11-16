import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history.dart';
import 'newspendings.dart';
import 'whomlend.dart';
import 'setfirstday.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalAmount = 0.0;
  double foodTotal = 0.0;
  double cabsTotal = 0.0;
  double clothesTotal = 0.0;
  double otherTotal = 0.0;
  double subscription = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotalAmount();
    _loadCategoryTotals();
  }

  Future<double> getCategoryTotal(String category) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$category-total') ?? 0.0;
  }

  Future<void> _loadCategoryTotals() async {
    foodTotal = await getCategoryTotal('Food');
    cabsTotal = await getCategoryTotal('Cabs/Travel');
    clothesTotal = await getCategoryTotal('Clothes');
    otherTotal = await getCategoryTotal('Other');
    subscription = await getCategoryTotal('Subscription');

    setState(() {});
  }

  Future<void> _loadTotalAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalAmount = prefs.getDouble('totalAmount') ?? 0.0;
    });
  }

  Future<void> _updateTotalAmount(double amount) async {
    setState(() {
      totalAmount += amount;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalAmount', totalAmount);
  }

  // Function to check where the user spent the most
  void _checkWhereYouSpentMost() {
    // Create a map to hold categories and their corresponding totals
    Map<String, double> categorySpending = {
      'Food': foodTotal,
      'Cabs/Travel': cabsTotal,
      'Clothes': clothesTotal,
      'Other': otherTotal,
      'Subscription': subscription,
    };

    // Find the category with the maximum spending
    String maxCategory = '';
    double maxAmount = 0.0;

    categorySpending.forEach((category, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        maxCategory = category;
      }
    });

    // Show the result in a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("You Spent Most On"),
          content: Text(
            "$maxCategory\n₹$maxAmount",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> dataMap = {
      "Food = ₹${foodTotal}": foodTotal,
      "Clothes = ₹${clothesTotal}": clothesTotal,
      "Cabs/Travel = ₹${cabsTotal}": cabsTotal,
      "Subscription = ₹${subscription}": subscription,
      "Other = ₹${otherTotal}": otherTotal,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Spendings This Month",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 5, 19, 77),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 18,
      ),
      backgroundColor: const Color.fromARGB(255, 230, 240, 250),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 178, 206, 224),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Pie chart displaying category-wise spending
                  PieChart(
                    dataMap: dataMap,
                    chartRadius: MediaQuery.of(context).size.width / 2.5,
                    legendOptions: LegendOptions(
                      showLegends: true,
                      legendPosition: LegendPosition.left,
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValuesInPercentage: true,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Total spending amount display
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 3, 30, 53),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'TOTAL = ₹$totalAmount',
                      style: TextStyle(
                        fontSize: 30,
                        color: Color.fromARGB(255, 255, 215, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8), // Added more space between sections

            // Button Row 1: Add new spending and View history
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  context,
                  "Add New Spending",
                  Colors.blueAccent,
                  Icons.add,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddSpendingPage(onAddSpending: _updateTotalAmount),
                    ),
                  ),
                ),
                _buildButton(
                  context,
                  "View Spending History",
                  Colors.pinkAccent,
                  Icons.history,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryPage()),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20), // More space between button rows

            // Button Row 2: Check where you spent most this month
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  context,
                  "Check where you spent most",
                  Color.fromARGB(255, 122, 212, 43),
                  Icons.pie_chart,
                  _checkWhereYouSpentMost, // OnPress will trigger _checkWhereYouSpentMost
                ),
                _buildButton(
                  context,
                  "Reset the Spendings",
                  Color.fromARGB(255, 251, 92, 0),
                  Icons.delete,
                  () {
                    // Reset functionality
                    setState(() {
                      totalAmount = 0.0;
                      foodTotal = 0.0;
                      cabsTotal = 0.0;
                      clothesTotal = 0.0;
                      otherTotal = 0.0;
                      subscription = 0.0;
                    });
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setDouble('totalAmount', 0.0);
                      prefs.setDouble('Food-total', 0.0);
                      prefs.setDouble('Cabs/Travel-total', 0.0);
                      prefs.setDouble('Clothes-total', 0.0);
                      prefs.setDouble('Other-total', 0.0);
                      prefs.setDouble('Subscription-total', 0.0);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  context,
                  "See whome you have lend",
                  Colors.blueAccent,
                  Icons.add,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoanTrackerPage()),
                  ),
                ),
                _buildButton(
                  context,
                  "Set the first day of the month",
                  Colors.pinkAccent,
                  Icons.history,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SetFirstDayPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Button widget for creating each action button with spacing and styling
  Widget _buildButton(BuildContext context, String label, Color color,
      IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: color,
            minimumSize: Size(140, 100), // Adjusted size for buttons
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
