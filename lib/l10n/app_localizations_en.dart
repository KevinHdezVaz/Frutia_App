import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get profile => 'Profile';

  @override
  String get helloAgain => 'Hello again,';

  @override
  String get user => 'User';

  @override
  String get progress => 'Progress';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get helpAndSupport => 'Help and Support';

  @override
  String get myAccount => 'My account';

  @override
  String streakDays(int count) => '$count days';

  @override
  String get streak => 'Streak';

  @override
  String get trialRemaining => 'Trial remaining';

  @override
  String get yourWeek => 'Your week';

  @override
  String get completeYourDay => 'Complete your day';

  @override
  String youAreOn(int count) => 'You\'re on $count days. Let\'s go!';

  @override
  String get startYourStreak => 'It\'s time to start your streak!';

  @override
  String get lostStreak => 'Oh no! You lost your streak';

  @override
  String hadDays(int count) => 'You had $count days. Start a new one today!';

  @override
  String get streakInDanger => 'Your streak is in danger!';

  @override
  String get lastDayToSave => 'Today is the last day to save it.';

  @override
  String get dontForgetStreak => 'Don\'t forget your streak!';

  @override
  String get waitingForYou =>
      'It\'s waiting for you. You haven\'t completed in 2 days';

  @override
  String get yourRecipesToday => 'Your recipes today';

  @override
  String get createYourPlan => 'Create your plan';

  @override
  String get noActivePlan => 'You don\'t have an active plan!';

  @override
  String get createPersonalizedPlan =>
      'Create a personalized plan to achieve your goals effectively.';

  @override
  String get yourChatsWithFrutia => 'Your chats with Frutia';
  @override
  String get reload => 'Reload';
  @override
  String get newConversation => 'New Conversation';
  @override
  String get searchConversations => 'Search conversations...';
  @override
  String get conversationDeleted => 'Conversation deleted';
  @override
  String get errorLoadingConversations => 'Error loading conversations';
  @override
  String get deleteConversation => 'Delete Conversation';
  @override
  String get sureDeleteConversation =>
      'Are you sure you want to delete this conversation?';
  @override
  String get delete => 'Delete';
  @override
  String get normalChat => 'Normal Chat';
  @override
  String get voiceChat => 'Voice Chat';
  @override
  String get noConversationsYet => 'No conversations yet!';
  @override
  String get startNewConversation =>
      'Start a new conversation with Frutia, either by text or voice.';
  @override
  String todayAt(String time) => 'Today at $time';
  @override
  String yesterdayAt(String time) => 'Yesterday at $time';

  @override
  String get createPlanNow => 'Create your plan now';

  @override
  String get upcomingMeal => 'Upcoming meal';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get timeToSleep => 'Time to sleep';

  @override
  String get breakfastStarting => 'Your breakfast is about to start';

  @override
  String get lunchSoon => 'Soon it will be time for lunch';

  @override
  String get lunchTime => 'It\'s time for lunch!';

  @override
  String get dinnerApproaching => 'Your dinner is approaching';

  @override
  String get dinnerTime => 'It\'s time for dinner!';

  @override
  String get nextMealBreakfast => 'Your next meal will be breakfast';

  @override
  String nextMeal(String meal) => 'Next meal: $meal';

  @override
  String get premiumMembership => 'Premium Membership';

  @override
  String get enjoyingBenefits => 'You\'re enjoying all the benefits';

  @override
  String get inTrialPeriod => 'In Trial Period';

  @override
  String trialDaysLeft(String days) => 'You have $days of free trial left';

  @override
  String get upgradeMembership => 'Upgrade your membership';

  @override
  String get unlockPremium => 'Unlock all premium features';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirm => 'Log out?';

  @override
  String get aboutToLogout => 'You\'re about to leave your account.';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get affiliateCodeUsed => 'Affiliate code used:';

  @override
  String get somethingWentWrong => 'Something went wrong!';

  @override
  String get couldNotLoadProfile =>
      'We couldn\'t load your profile. Please try again or contact support if the problem persists.';

  @override
  String get retry => 'Retry';

  @override
  String get streakReminderDescription =>
      'Tap here to mark your day as complete and maintain or start your streak. Do it daily!';

  @override
  String get myPlanForToday => 'My Plan for Today';

  @override
  String get yourDaySummary => 'Your Day Summary';

  @override
  String get viewHistory => 'View History';

  @override
  String get downloadPDF => 'Download PDF';

  @override
  String get carbs => 'Carbs';

  @override
  String get fats => 'Fats';

  @override
  String get accompanySaladFree => 'Accompany with FREE Salad';

  @override
  String selectAtLeastOneOption(String meal) =>
      'Select AT LEAST one option to register your $meal';

  @override
  String canAddMoreOptions(int selected, int total) =>
      'You can add more options or confirm now ($selected/$total)';

  @override
  String completeMealConfirm(String meal) =>
      'Complete meal! You can confirm your $meal';

  @override
  String recipeIdeasFor(String meal) => 'Recipe Ideas for $meal';

  @override
  String get useIngredientsAbove =>
      'Use the ingredients above to create these delicious recipes';

  @override
  String mealCompleted(String meal) => '$meal Completed ✨';

  @override
  String get comeBackTomorrow => 'Come back tomorrow for a new day';

  @override
  String registeringMeal(String meal) => 'Registering $meal...';

  @override
  String confirmMeal(String meal, int calories) =>
      'Confirm $meal! ($calories kcal)';

  @override
  String confirmPartialMeal(String meal, int calories) =>
      'Confirm Partial $meal! ($calories kcal)';

  @override
  String mealRegisteredSuccess(String meal) => '$meal successfully registered.';

  @override
  String errorRegistering(String error) => 'Error registering: $error';

  @override
  String errorLoadingData(String error) => 'Error loading your data: $error';

  @override
  String get noMealPlan => 'No meal plan found.';

  @override
  String get weekCalendarDescription =>
      'Here you can see the days you have completed your plan and the status of your daily streak.';

  @override
  String get notDefined => 'Not defined';

  @override
  String get dayCompleted => 'Day completed! Your streak continues.';

  @override
  String get termsAndConditionsTitle => 'Terms and Conditions';

  @override
  String get termsTitle => 'Terms and Conditions of Use';

  @override
  String get termsIntro =>
      'Welcome to Frutia. By using our application, you agree to comply with the following terms and conditions. Please read them carefully before continuing to use our services.';

  @override
  String get termsSection1 =>
      '1. Acceptance of Terms\nBy downloading, installing, or using the Frutia application, you accept these terms and conditions in their entirety. If you do not agree with any part, we ask that you do not use the application.';

  @override
  String get protein => 'Protein';

  @override
  String get termsSection2 =>
      '2. Use of the Application\nFrutia is designed to provide personalized nutrition plans based on your preferences, goals, and lifestyle. We do not guarantee specific results, as results may vary by user. You must use the application at your own risk and consult a health professional before making significant changes to your diet.';

  @override
  String get termsSection3 =>
      '3. Privacy\nYour privacy is important to us. The information you share with Frutia will be treated in accordance with our Privacy Policy, which you can consult in the application or on our website.';

  @override
  String get termsSection4 =>
      '4. Intellectual Property\nAll content in the application, including text, graphics, logos, and software, is the property of Frutia or its licensors and is protected by intellectual property laws. You may not copy, modify, distribute, or reproduce any content without our express consent.';

  @override
  String get termsSection5 =>
      '5. Modifications\nWe reserve the right to modify these terms and conditions at any time. We will notify you of significant changes through the application or other means. Continued use of the application implies acceptance of the updated terms.';

  @override
  String get termsSection6 =>
      '6. Contact\nIf you have questions about these terms, you can contact us at soporte@frutia.com.';

  @override
  String get goBack => 'Go Back';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyIntro =>
      'At Frutia, your privacy is a priority. This Privacy Policy explains how we collect, use, protect, and share your information when you use our application. By using Frutia, you accept the practices described below.';

  @override
  String get privacySection1 =>
      '1. Information We Collect\nWe collect information that you provide directly to us, such as your name, email, dietary preferences, health goals, and routine data. We may also collect data generated by your use of the application, such as system interactions and configuration preferences.';

  @override
  String get privacySection2 =>
      '2. Use of Information\nWe use your information to personalize your nutrition plans, improve the functionality of the application, and offer you an experience tailored to your needs. We may also use anonymized data for analysis and service improvements.';

  @override
  String get privacySection3 =>
      '3. Sharing Information\nWe do not sell or share your personal information with third parties, except in cases required by law or to protect the rights of Frutia. We may share anonymized data with partners for research or service improvement purposes.';

  @override
  String get privacySection4 =>
      '4. Data Security\nWe implement technical and organizational security measures to protect your information. However, no system is completely foolproof, so we recommend taking additional precautions, such as using strong passwords.';

  @override
  String get privacySection5 =>
      '5. Your Rights\nYou can access, correct, or delete your personal information at any time from the application settings. If you have questions or need assistance, contact us at soporte@frutia.com.';

  @override
  String get privacySection6 =>
      '6. Changes to this Policy\nWe reserve the right to update this policy. We will notify you of significant changes through the application or by email. Continued use of Frutia implies acceptance of the updated policy.';

  @override
  String get helpAndSupportTitle => 'Help and Support';

  @override
  String get helpTitle => 'Help and Support';

  @override
  String get helpIntro =>
      'At Frutia, we are here to help you. If you have any questions, problems, or simply want to know more about how to get the most out of the application, we are at your disposal!';

  @override
  String get helpSection1 =>
      '1. Frequently Asked Questions (FAQs)\nCheck out the most common questions about using Frutia. Here you will find information on how to customize your plan, adjust your preferences, or manage your account.';

  @override
  String get viewFAQs => 'View FAQs';

  @override
  String get helpSection2 =>
      '2. Contact Us\nIf you need personalized help, our support team is ready to assist you. Write to us and we will respond as soon as possible.';

  @override
  String get contactEmail => 'Email: soporte@frutia.com';

  @override
  String get helpSection3 =>
      '3. Frutia Community\nJoin our community on social media to share experiences, recipes, and tips with other users. Follow us on our official platforms.';

  @override
  String get helpSection4 =>
      '4. Updates and Feedback\nDo you have any suggestions to improve Frutia? We would love to hear from you. Send your comments through the form in the application or by email.';

  @override
  String get welcomeToFrutia => 'Welcome to Frutia';

  @override
  String get enterCredentials => 'Enter your credentials to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot my password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get createAccount => 'Create your account';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get unexpectedError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get completeAllFields => 'Please complete all fields';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get googleSignInError => 'Error signing in with Google';

  @override
  String get registration => 'Registration';

  @override
  String get welcomeCompleteRegistration =>
      'Welcome, Complete your registration.';

  @override
  String get fullName => 'Full name';

  @override
  String get emailAddress => 'Email address';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get affiliateCodeOptional => 'Affiliate code (Optional)';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get completeAllRequiredFields => 'Please complete all required fields';

  @override
  String get nameOnlyLetters => 'Name should only contain letters';

  @override
  String get pleaseEnterNumber => 'Please enter a number';

  @override
  String get invalidPhoneNumber =>
      'The phone number is not valid for the selected country.';

  @override
  String get skip => 'SKIP';

  @override
  String welcomeMessage(String name) =>
      'Welcome, $name! Registration successful.';

  @override
  String get whatPlanWeOffer => 'WHAT PLAN DO WE OFFER?';

  @override
  String get frutiaPlan => 'Frutia Plan:';

  @override
  String get personalizedVirtualNutritionist =>
      'Personalized virtual nutritionist';

  @override
  String get remember => 'Remember';

  @override
  String get genericPlansDontWork =>
      '❌ Generic plans don\'t work. Every body is different.';

  @override
  String get noMagicSolutions =>
      '🚫 There are no magic solutions or "miracle teas".';

  @override
  String get budgetMatters =>
      '💸 Your budget matters, and it should be part of the plan.';

  @override
  String get firstStepToChange =>
      'This is the first step towards the change you deserve';

  @override
  String get aboutUs => 'About Us';

  @override
  String get ourStory => 'Our Story';

  @override
  String get ourStoryParagraph1 =>
      'We created this app with a clear idea: nutrition shouldn\'t feel like a burden, nor depend on generic plans that don\'t adapt to your life. That\'s why we combine science, technology, and artificial intelligence to offer you real support, without magic formulas, empty promises, or complicating your day-to-day life.';

  @override
  String get myPlan => 'My Plan';

  @override
  String get recipes => 'Recipes';

  @override
  String get shopping => 'Shopping';

  @override
  String get modifications => 'Modifications';

  @override
  String get myPlanDescription =>
      'Here you can view and manage your personalized meal plan.';

  @override
  String get recipesDescription =>
      'Explore delicious recipes tailored to your needs and preferences.';

  @override
  String get shoppingDescription =>
      'Organize your shopping lists for a stress-free experience.';

  @override
  String get modificationsDescription =>
      'Request changes or adjustments to your plan or recipes directly here.';

  @override
  String get importantSection =>
      'This is an important section of the application.';

  @override
  String get ourStoryParagraph2 =>
      'Every body is different, and we believe your nutrition should respect that. That\'s why our system adapts to your goals, tastes, routine, and even your budget. Whether you train at the gym, play soccer on Sundays, or simply want to eat better without overspending: your plan is yours and evolves with you.';

  @override
  String get ourStoryParagraph3 =>
      'We are driven by the idea that technology can be humanized. That\'s why our AI, Frutia, is not just a robot that throws data at you. You can decide how you want it to treat you: motivating, relaxed, or direct. As if you had a virtual nutritionist who truly understands you.';

  @override
  String get ourStoryParagraph4 =>
      'We are a team of nutritionists, developers, designers, and dreamers, committed to accessible, realistic, and personalized nutrition. And most importantly: built to last.';

  @override
  String get youWontBeAlone => '🌟 And you won\'t be alone on the journey';

  @override
  String get frutiaAccompaniesYou =>
      '🍓 Frutia accompanies you every step of the way';

  @override
  String get foodShouldPlease =>
      '🍽️ Your food should please you, not stress you.';

  @override
  String get weAreHereForYou =>
      '🤝 We are here to give you a real, smart plan made just for you.';

  @override
  String get trackingFoodHabitsWeight => 'Food, habits, and weight tracking';

  @override
  String get recipesAccordingBudget => 'Recipes according to your budget';

  @override
  String get savedConversationHistory => 'Saved conversation history';
  @override
  String get personalizedNutrition => '100% Personalized Nutrition';

  @override
  String get plansAdaptedToYou => 'Plans adapted to your goals and tastes';

  @override
  String get aiCoachPersonalTracking => 'AI Coach with personal tracking';

  @override
  String get adaptableToYourStyle => 'Adaptable to your style and budget';

  @override
  String get fastAndMadeForYou => 'Fast and made just for you';

  @override
  String errorCompletingDay(String error) => 'Error completing day: $error';
}
