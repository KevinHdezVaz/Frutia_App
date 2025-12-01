import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  String get profile;
  String get helloAgain;
  String get user;
  String get progress;
  String get termsAndConditions;
  String get privacyPolicy;
  String get helpAndSupport;
  String get myAccount;
  String streakDays(int count);
  String get streak;
  String get trialRemaining;
  String get yourWeek;
  String get completeYourDay;
  String youAreOn(int count);
  String get startYourStreak;
  String get lostStreak;
  String hadDays(int count);
  String get streakInDanger;
  String get lastDayToSave;
  String get dontForgetStreak;
  String get waitingForYou;
  String get yourRecipesToday;
  String get createYourPlan;
  String get noActivePlan;
  String get createPersonalizedPlan;
  String get createPlanNow;
  String get upcomingMeal;
  String get breakfast;
  String get lunch;
  String get dinner;
  String get timeToSleep;
  String get breakfastStarting;
  String get lunchSoon;
  String get lunchTime;
  String get dinnerApproaching;
  String get dinnerTime;
  String get nextMealBreakfast;
  String nextMeal(String meal);
  String get premiumMembership;
  String get enjoyingBenefits;
  String get inTrialPeriod;
  String trialDaysLeft(String days);
  String get upgradeMembership;
  String get unlockPremium;
  String get logout;
  String get logoutConfirm;
  String get aboutToLogout;
  String get cancel;
  String get exit;
  String get affiliateCodeUsed;
  String get somethingWentWrong;
  String get couldNotLoadProfile;
  String get retry;
  String get dayCompleted;
  String errorCompletingDay(String error);
  String get termsAndConditionsTitle;
  String get termsTitle;
  String get termsIntro;
  String get termsSection1;
  String get termsSection2;
  String get termsSection3;
  String get termsSection4;
  String get termsSection5;
  String get termsSection6;
  String get goBack;
  String get privacyPolicyTitle;
  String get privacyTitle;
  String get privacyIntro;
  String get privacySection1;
  String get privacySection2;
  String get privacySection3;
  String get privacySection4;
  String get privacySection5;
  String get privacySection6;
  String get helpAndSupportTitle;
  String get helpTitle;
  String get helpIntro;
  String get helpSection1;
  String get viewFAQs;
  String get helpSection2;
  String get contactEmail;
  String get helpSection3;
  String get helpSection4;
  String get welcomeToFrutia;
  String get enterCredentials;
  String get email;
  String get password;
  String get rememberMe;
  String get forgotPassword;
  String get signIn;
  String get signInWithGoogle;
  String get createAccount;
  String get notificationsDisabled;
  String get unexpectedError;
  String get completeAllFields;
  String get invalidEmail;
  String get passwordMinLength;
  String get googleSignInError;

  String get registration;
  String get welcomeCompleteRegistration;
  String get fullName;
  String get emailAddress;
  String get phoneNumber;
  String get confirmPassword;
  String get affiliateCodeOptional;
  String get passwordsDoNotMatch;
  String get completeAllRequiredFields;
  String get nameOnlyLetters;
  String get pleaseEnterNumber;
  String get invalidPhoneNumber;
  String get skip;
  String get remember;
  String get genericPlansDontWork;
  String get noMagicSolutions;
  String get budgetMatters;
  String get foodShouldPlease;
  String get weAreHereForYou;
  String get firstStepToChange;
  String get youWontBeAlone;
  String get frutiaAccompaniesYou;
  String get whatPlanWeOffer;
  String get frutiaPlan;
  String get personalizedVirtualNutritionist;
  String get trackingFoodHabitsWeight;
  String get recipesAccordingBudget;
  String get savedConversationHistory;
  String get personalizedNutrition;
  String get aboutUs;
  String get ourStory;
  String get ourStoryParagraph1;
  String get ourStoryParagraph2;
  String get ourStoryParagraph3;
  String get ourStoryParagraph4;

  String get plansAdaptedToYou;
  String get aiCoachPersonalTracking;
  String get adaptableToYourStyle;
  String get fastAndMadeForYou;
  String get myPlan;
  String get recipes;
  String get shopping;
  String get modifications;
  String get myPlanDescription;
  String get recipesDescription;
  String get shoppingDescription;
  String get modificationsDescription;
  String get importantSection;

  String get yourChatsWithFrutia;
  String get reload;
  String get newConversation;
  String get searchConversations;
  String get conversationDeleted;
  String get errorLoadingConversations;
  String get deleteConversation;
  String get sureDeleteConversation;
  String get delete;
  String get normalChat;
  String get voiceChat;
  String get noConversationsYet;
  String get startNewConversation;
  String get myPlanForToday;
  String get yourDaySummary;
  String get viewHistory;
  String get downloadPDF;
  String get protein;
  String get carbs;
  String get fats;
  String get accompanySaladFree;
  String selectAtLeastOneOption(String meal);
  String canAddMoreOptions(int selected, int total);
  String completeMealConfirm(String meal);
  String recipeIdeasFor(String meal);
  String get useIngredientsAbove;
  String mealCompleted(String meal);
  String get comeBackTomorrow;
  String registeringMeal(String meal);
  String confirmMeal(String meal, int calories);
  String confirmPartialMeal(String meal, int calories);
  String mealRegisteredSuccess(String meal);
  String errorRegistering(String error);
  String errorLoadingData(String error);
  String get noMealPlan;
  String get streakReminderDescription;
  String get weekCalendarDescription;

  String get notDefined;
  String todayAt(String time);
  String yesterdayAt(String time);

  String welcomeMessage(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
