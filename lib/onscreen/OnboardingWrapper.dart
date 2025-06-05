import 'package:flutter/material.dart';
import 'package:Frutia/onscreen/OnboardingScreenOne.dart';
import 'package:Frutia/onscreen/OnboardingScreenThree.dart';
import 'package:Frutia/onscreen/OnboardingScreenTwo.dart';
import 'package:Frutia/onscreen/screen_cuatro.dart';
import 'package:vibration/vibration.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({Key? key}) : super(key: key);

  @override
  _OnboardingWrapperState createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Add listener for page changes
    _pageController.addListener(() {
      // Trigger vibration on page change
      if (_pageController.page != null && _pageController.page! % 1 == 0) {
        // Ensure it's a full page transition
        Vibration.hasVibrator().then((hasVibrator) {
          if (hasVibrator ?? false) {
            Vibration.vibrate(duration: 50); // Short vibration
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          OnboardingScreenOne(pageController: _pageController),
          OnboardingScreenTwo(pageController: _pageController),
          OnboardingScreenThree(pageController: _pageController),
          OnBoardingCuatro(pageController: _pageController),
        ],
      ),
    );
  }
}
