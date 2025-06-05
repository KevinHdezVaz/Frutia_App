import 'package:flutter/material.dart';
import 'package:Frutia/onscreen/OnboardingScreenOne.dart';
import 'package:Frutia/onscreen/OnboardingScreenThree.dart';
import 'package:Frutia/onscreen/OnboardingScreenTwo.dart';
import 'package:Frutia/onscreen/screen_cuatro.dart';

class OnboardingWrapper extends StatelessWidget {
  final PageController _pageController = PageController();

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
