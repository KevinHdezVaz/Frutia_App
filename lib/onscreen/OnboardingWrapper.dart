import 'package:flutter/material.dart';
import 'package:user_auth_crudd10/onscreen/OnboardingScreenOne.dart';
import 'package:user_auth_crudd10/onscreen/OnboardingScreenThree.dart';
import 'package:user_auth_crudd10/onscreen/OnboardingScreenTwo.dart';
import 'package:user_auth_crudd10/onscreen/screen_cuatro.dart';

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
