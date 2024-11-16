import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import 'homepage.dart';

void main() {
  runApp(FinancialApp());
}

class FinancialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isSliderCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images4.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          // Replace the existing padding line with the following
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 80),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  primary: Color.fromARGB(255, 44, 37, 37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0), // Left and right padding
                      child: SwipeableButtonView(
                        buttonText: "SLIDE TO START",
                        buttonWidget: Container(
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 116, 183, 246),
                        isFinished: isSliderCompleted,
                        onWaitingProcess: () {
                          Future.delayed(Duration(seconds: 1), () {
                            setState(() {
                              isSliderCompleted = true;
                            });
                          });
                        },
                        onFinish: () async {
                          await Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: DashboardScreen(),
                            ),
                          );

                          setState(() {
                            isSliderCompleted = false; // Reset after navigation
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
