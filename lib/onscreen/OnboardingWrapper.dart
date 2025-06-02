import 'package:flutter/material.dart';
import 'package:user_auth_crudd10/onscreen/HowItWorksScreen.dart';
import 'package:user_auth_crudd10/onscreen/ReminderScreen.dart';

class OnboardingWrapper extends StatelessWidget {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          HowItWorksScreen(),
          ReminderScreen(),
        ],
      ),
    );
  }
}
