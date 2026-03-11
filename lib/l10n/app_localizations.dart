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

  String get selectTime;

  // ⭐ GETTERS EXISTENTES (no cambiar)
  String get profile;
  String get helloAgain;
  String get user;
  String get progress;
  String get termsAndConditions;
  String get privacyPolicy;
  String get helpAndSupport;
  String get myAccount;
  String streakDays(int count);
  String get consumptionToday;
  String caloriesRemaining(int calories);

  String get wholeEgg => throw UnimplementedError();
  String get eggWhitesWholeEgg => throw UnimplementedError();
  String get cannedTuna => throw UnimplementedError();
  String get chickenThigh => throw UnimplementedError();
  String get groundBeef => throw UnimplementedError();
  String get greekYogurt => throw UnimplementedError();

  // Carbohidratos / Alimentos
  String get broccoli => throw UnimplementedError();
  String get cauliflower => throw UnimplementedError();
  String get spinach => throw UnimplementedError();
  String get lettuce => throw UnimplementedError();
  String get zucchini => throw UnimplementedError();
  String get whiteRice => throw UnimplementedError();
  String get potato => throw UnimplementedError();
  String get traditionalOats => throw UnimplementedError();
  String get cornTortillas => throw UnimplementedError();
  String get basicNoodlesPasta => throw UnimplementedError();
  String get beans => throw UnimplementedError();
  String get sweetPotato => throw UnimplementedError();
  String get riceCrackers => throw UnimplementedError();
  String get creamOfRice => throw UnimplementedError();
  String get quinoa => throw UnimplementedError();
  String get organicOats => throw UnimplementedError();
  String get artisanWholeWheatBread => throw UnimplementedError();

  // Frutas
  String get strawberries => throw UnimplementedError();
  String get blueberries => throw UnimplementedError();
  String get blackberries => throw UnimplementedError();
  String get banana => throw UnimplementedError();
  String get apple => throw UnimplementedError();
  String get mango => throw UnimplementedError();
  String get watermelon => throw UnimplementedError();
  String get pear => throw UnimplementedError();

  // Proteínas (comunes)
  String get tofu => throw UnimplementedError();
  String get tempeh => throw UnimplementedError();
  String get seitan => throw UnimplementedError();
  String get lentils => throw UnimplementedError();
  String get chickpeas => throw UnimplementedError();
  String get plantProteinPowder => throw UnimplementedError();
  String get freshCheese => throw UnimplementedError();
  String get cottageCheese => throw UnimplementedError();
  String get panelaCheese => throw UnimplementedError();
  String get ricotta => throw UnimplementedError();
  String get chickenThighWithSkin => throw UnimplementedError();
  String get groundBeef8020 => throw UnimplementedError();
  String get salmon => throw UnimplementedError();
  String get ribeye => throw UnimplementedError();
  String get duckBreast => throw UnimplementedError();
  String get agedCheese => throw UnimplementedError();
  String get chickenBreastOrThigh => throw UnimplementedError();
  String get leanBeef => throw UnimplementedError();
  String get whiteFish => throw UnimplementedError();
  String get chickenBreast => throw UnimplementedError();
  String get freshSalmon => throw UnimplementedError();
  String get turkeyBreast => throw UnimplementedError();
  String get naturalYogurt => throw UnimplementedError();
  String get wheyProtein => throw UnimplementedError();
  String get casein => throw UnimplementedError();

  // Grasas
  String get oliveOil => throw UnimplementedError();
  String get peanutsPeanutButter => throw UnimplementedError();
  String get smallAvocado => throw UnimplementedError();
  String get sesameSeeds => throw UnimplementedError();
  String get extraVirginOliveOil => throw UnimplementedError();
  String get avocadoOil => throw UnimplementedError();
  String get almonds => throw UnimplementedError();
  String get walnuts => throw UnimplementedError();
  String get hassAvocado => throw UnimplementedError();
  String get organicChiaFlax => throw UnimplementedError();
  String get premiumNuts => throw UnimplementedError();
  String get lard => throw UnimplementedError();
  String get butter => throw UnimplementedError();
  String get avocado => throw UnimplementedError();
  String get mctOil => throw UnimplementedError();
  String get gheeButter => throw UnimplementedError();
  String get olives => throw UnimplementedError();
  String get avocadoHassAvocado => throw UnimplementedError();
  String get honey => throw UnimplementedError();
  String get darkChocolate70 => throw UnimplementedError();

  // Personal Data Page
  String get personalData;
  String get tellUsAboutYou;
  String get dataEssentialForPlan;
  String get height;
  String get weight;
  String get age;
  String get country;
  String get selectCountry;
  String get iIdentifyAs;
  String get male;
  String get female;
  String get saveAndContinue;
  String get dataSavedSuccess;
  String get errorSavingProfile;
  String get completeAllRequiredFields;
  String get heightRequired;
  String get heightBetween;
  String get weightRequired;
  String get weightBetween;
  String get ageRequired;
  String get ageBetween;
  String get selectCountryRequired;
  String get selectOptionRequired;
  String ageYears(int age);
  String get meters;
  String get pounds;
  String get years;
// Progress Screen
  String get yourProgress;
  String get currentStreak;
  String get days;
  String get yourGoal;
  String get balance;
  String get completeMyDay;
  String get alreadyCompletedToday;
  String congratsStreakNow(int streak); // ⭐ MÉTODO, NO GETTER
  String get errorLoadingProgress;
  String get day;
  String get milestone;
  String get notDefined;
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
  String get personalMessage;
  String get yourDaySummary;
  String get viewHistory;
  String get downloadPDF;
  String get protein;
  String get carbs;

  // ⭐ QUESTIONNAIRE TRANSLATIONS
  String get aboutYou;
  String get doYouHaveMedicalCondition;
  String get specifySuchAs;
  String get mainGoal;
  String get loseBodyFat;
  String get gainMuscle;
  String get eatHealthier;
  String get improvePerformance;

  // Routine
  String get yourRoutine;
  String get whatSportsDoYouPractice;
  String get selectMultiple;
  String get whichMostLikeYourWeek;
  String get noMoveNoTrain;
  String get officeTrainOneTwoTimes;
  String get officeTrainThreeFourTimes;
  String get officeTrainFiveSixTimes;
  String get activeWorkTrainOneTwoTimes;
  String get activeWorkTrainThreeFourTimes;
  String get veryPhysicalWorkTrainFiveSixTimes;
// ⭐ SPORT SELECTION TRANSLATIONS
  String get gym;
  String get soccer;
  String get running;
  String get tennis;
  String get none;
  String get specifyYourSport;
  // Meal Structure
  String get yourMealStructure;
  String get whenPreferSnack;
  String get planIncludesOneSnack;
  String get midMorningSnackAM;
  String get betweenBreakfastLunch;
  String get midAfternoonSnackPM;
  String get betweenLunchDinner;
  String get whatTimeDoYouUsuallyEat;
  String get optional;
  String get howOftenEatOut;
  String get almostEveryDay;
  String get sometimesTwoToFourTimesWeek;
  String get rarelyOnceWeekOrLess;
  String get never;

  // Food Preferences & Allergies
  String get tasteAllergiesDietaryStyle;
  String get whatFoodsDontYouLike;
  String get exampleBroccoliLiver;
  String get doYouHaveFoodAllergies;
  String get yesIHaveAllergies;
  String get noNone;
  String get specifyHere;
  String get doYouFollowDietaryStyle;
  String get omnivore;
  String get vegetarian;
  String get vegan;
  String get keto;
  String get other;
  String get specifyYourStyle;
  String get whatBudgetForWeeklyFood;
  String get lowOnlyBasics;
  String get highNoRestrictions;

  // Favorite Foods
  String get foodsYouLikemost;
  String get selectFavoritesToAppearMore;
  String get proteins;
  String get chooseAtLeastThree;
  String get carbohydrates;
  String get fats;
  String get chooseAtLeastTwo;
  String get fruitsForSnacks;
  String get selectAll;

  // Personalization
  String get emotionalPersonalization;
  String get whatHardestMaintainInPlan;
  String get stayConsistent;
  String get knowWhatToEatWhenDontHavePlan;
  String get eatHealthyOutsideHome;
  String get controlCravings;
  String get prepareMeals;
  String get specify;
  String get whatMotivatesYouMostToFollowPlan;
  String get seeQuickResults;
  String get feelBetterPhysically;
  String get proveToMyselfICanDoIt;
  String get improveHealthLongTerm;
  String get notClearYet;

  // Preferences
  String get yourPreferences;
  String get howPreferICommunicateWithYou;
  String get motivational;
  String get close;
  String get direct;
  String get whateverWorksForYou;
  String get whatWouldYouLikeToCallYou;
  String get yourNameOrNickname;

  // Navigation
  String get back;
  String get continue_;
  String get saveChanges;
  String get finish;

  // Welcome
  String get readyForPersonalizedPlan;
  String get modifyYourPersonalizedPlan;
  String get answerQuestionsForIdealPlan;
  String get updateAnswersToAdjust;
  String get swipeOrPressContinue;

  // Validation
  String get selectMainGoal;
  String get specifyMedicalCondition;
  String get selectAtLeastOneSport;
  String get selectWhenPreferSnack;
  String get selectHowOftenEatOut;
  String get selectDietaryStyle;
  String get specifyFoodAllergies;
  String get selectWeeklyBudget;
  String get selectAtLeastOneFavoriteFruit;
  String get selectCommunicationStyle;
  String get selectAtLeastOneDifficulty;
  String get specifyOtherDifficulty;
  String get selectAtLeastOneMotivation;

  // Plan Generation
  String get generatingPlan;
  String get updatingPlan;
  String get pleaseWait;
  String get planTakingLonger;
  String get checkInFewMinutes;
  String errorGeneratingPlan(String error);
  String errorUpdatingPlan(String error);

  // Meal times
  String get morningSnack;
  String get afternoonSnack;

  String get yourNutritionalProfile;
  String get bmi;
  String weightKg(String kg);
  String heightCm(String cm);
  String get calories;
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
  String todayAt(String time);
  String yesterdayAt(String time);
  String welcomeMessage(String name);

  // ⭐⭐⭐ NUEVOS GETTERS PARA CHATSCREEN ⭐⭐⭐
  String get chatTitle;
  String get messagesRemaining;
  String get saveChat;
  String get saveShowcaseTitle;
  String get saveShowcaseDesc;
  String get micShowcaseTitle;
  String get micShowcaseDesc;
  String get voiceChatShowcaseTitle;
  String get voiceChatShowcaseDesc;
  String get messageLimit;
  String get messageLimitDesc;
  String get viewPremiumPlans;
  String get createPlanFirst;
  String get needActivePlan;
  String get createMyPlan;
  String get backToHome;
  String get typeMessage;
  String get stopRecording;
  String get startRecording;
  String get advancedVoiceChat;
  String get imageAttached;
  String get textCopied;
  String get errorLoadingImage;
  String get bodyFatPercentage;
  String get estimated;
  String get recommendation;
  String get observations;
  String get thinkingResponse;
  String get analyzingPlan;
  String get consultingHistory;
  String get preparingResponse;
  String get reviewingMacros;
  String get connectingAI;
  String get calculatingRecommendations;
  String get verifyingProgress;
  String get searchingBestAnswer;
  String get processingQuery;
  String get almostReady;
  String get noMessagesToSave;
  String get changeTitle;
  String get saveConversation;
  String get titleLabel;
  String get titleHint;
  String get save;
  String get chatSaved;
  String get errorSavingChat;
  String get micPermissionRequired;
  String get enableMicPermission;
  String get speechNotAvailable;
  String get errorStartingSpeech;
  String get errorStoppingSpeech;
  String get errorVerifyingPlan;
  String get newConversationTitle;
  String get errorProcessingImage;
  String get errorAnalyzingImage;
  String get pleaseLogin;
  String get errorStartingSession;
  String get sessionStartedError;
  String get errorSendingMessage;
  String get errorAnalyzingImageShort;

  // Plan Generation Dialog
  String get updatingYourPlan;
  String get generatingYourPlan;
  String get processTakesTime;
  String get dontCloseApp;
  String get processingRequest;

  // LoadingMessagesWidget
  String get analyzingResponses;
  String get creatingUniquePlan;
  String get frutiaAccompaniesYouLoading;
  String get almostPerfectPlan;
  String get frutiaKnowsNeeds;
  String get usersTrustUs;
  String get selectingBestRecipes;
  String get prepareForPositiveChange;
  String get calculatingMacros;
  String get adjustingPortions;
  String get filteringRecipes;
  String get aiWorkingForYou;
  String get investingInHealth;
  String get structuringMeals;
  String get consistencyIsKey;
  String get compilingShoppingList;
  String get eatingHealthyPossible;
  String get imagineEnergy;
  String get journeyBeginsNow;
  String get wellnessSeriously;
  String get smallStepGreatLeap;
  String get patienceSecretIngredient;
  String get optimizingBudget;

  // PlanSummaryScreen
  String planSummaryTitle(String clientName);
  String get personalMessageTitle;
  String get nutritionalProfileTitle;
  String get ageLabel;
  String get weightLabel;
  String get heightLabel;
  String get foodExchangesTitle;
  String get foodExchangesSubtitle;
  String get mealTimeLabel;
  String get tapToViewExchanges;
  String get tipsForMeal;
  String get suggestedRecipesTitle;
  String get suggestedRecipesSubtitle;
  String get recipeFor;
  String get instructionsTitle;
  String get goalAlignmentTitle;
  String get sportsSupportTitle;
  String get readyToStartButton;
  String get backButton;

  // SuccessScreen
  String get planCreatedTitle;
  String get planCreatedSubtitle;
  String get startNowButton;

  // HistoryScreen
  String get historyScreenTitle;
  String get historyErrorLoading;
  String get historyNoRecords;
  String get historyYouSelected;

  // ProfessionalMiPlanDiarioScreen (Pantalla1)
  String get userDefault;
  // Duplicate keys removed: noActivePlan, mealRegisteredSuccess, errorRegistering
  String get dataLoadError;
  String get noDataForPDF;
  String get pdfGenError;
  String pdfWelcome(String name);
  String get pdfHowToUse;
  String get pdfSelectOneOption;
  String get pdfFoodGroups;
  String get pdfImportantWarning;
  String get pdfUseAppControl;
  String get pdfAppHelps;
  String get pdfAppFeature1;
  String get pdfAppFeature2;
  String get pdfAppFeature3;
  String get pdfAppFeature4;
  String get pdfTip;
  String get pdfLearnToManipulate;
  String get pdfFlexiblePlan;
  String get pdfFlexibility1;
  String get pdfFlexibility2;
  String get pdfFlexibility3;
  String get pdfFlexibility4;
  String get pdfObjective;
  String get pdfFrutiaChatTitle;
  String get pdfFrutiaChatDesc;
  String get pdfAskAbout;
  String get pdfAsk1;
  String get pdfAsk2;
  String get pdfAsk3;
  String get pdfAsk4;
  String get pdfAsk5;
  String get pdfAsk6;
  String get pdfAvailable247;
  String get attentionTitle;
  String get willExceedMacros;
  String exceedWarningMessage(String food, String macro, String excess);
  String get adjustmentSuggestion;
  String get originalPortion;
  String get adjustedPortion;
  String reducePortionMessage(String percent, String grams);
  String get customAdviceTitle;
  String get askFrutiaChat;
  String get askFrutiaChatExample;
  String get selectAnyway;
  String get cancelButton;
  String get lowBudgetWarning;
  String get alreadySelectedEgg;

  // Additional PDF Keys
  String get pdfGoldRule;
  String get pdfGoldRuleTitle;
  String get pdfGoldRuleDesc;
  String get pdfGoldRuleWarning;
  String get pdfMealTableComponent;
  String get pdfMealTableOption;
  String get pdfMealTablePortion;
  String get pdfMealCalories;
  String get pdfSuggestedRecipes;
  String get pdfProfileWeight;
  String get pdfProfileHeight;
  String get pdfProfileAge;
  String get pdfMacrosTargetTitle;
  String get pdfPersonalizedMsgTitle;
  String get pdfRecsTitle;
  String get pdfRecsWeighingTitle;
  String get pdfRecsWeighingBody1;
  String get pdfRecsWeighingBody2;
  String get pdfRecsWeighingBody3;
  String get pdfRecsHydrationTitle;
  String get pdfRecsHydrationBody1;
  String get pdfRecsHydrationBody2;
  String get pdfRecsHydrationBody3;
  String get pdfRecsHydrationBody4;
  String get pdfRecsOrgTitle;
  String get pdfRecsOrgBody1;
  String get pdfRecsOrgBody2;
  String get pdfRecsOrgBody3;
  String get pdfRecsOrgBody4;
  String get pdfRecsKitchenTitle;
  String get pdfRemember;
  String get pdfRememberBody1;
  String get pdfRememberBody2;
  String get pdfRememberBody3;
  String get pdfWelcomeDesc;
  String pdfPersonalizedPlanTitle(String userName);
  String get contactSupport;
  String get macroExcessWarning;
  String macroExcessProtein(int amount);
  String macroExcessCarbs(int amount);
  String macroExcessFats(int amount);
  String get adviceTitle;
  String get adviceSubtitle;
  String get adviceTip;
  String recChangeToChicken(String meal, String option);
  String recChangeToBreast(String meal, String option);
  String recReducePortion(String meal, String option);
  String recSalmonFat(String meal, String option);
  String recReduceOil(String meal, String option);
  String recReduceAlmonds(String meal, String option);
  String recAvocado(String meal);
  String recReduceCarbs(String meal, String option);
  String recReduceFruits(String meal, String option);
  String get autoAdjustError;
  String get autoAdjustNoExcess;
  String get autoAdjustTooAggressive;
  String get pdfHowToUseStep1;
  String get pdfHowToUseStep2;
  String get pdfHowToUseStep3;
  String get pdfHowToUseStep4;
  String get pdfHowToUseTip;
  String get pdfLearnToManipulateTitle;
  String get pdfLearnToManipulateDesc;
  String get pdfLearnToManipulatePoint1;
  String get pdfLearnToManipulatePoint2;
  String get pdfLearnToManipulatePoint3;
  String get pdfLearnToManipulatePoint4;
  String get pdfLearnToManipulateObjective;
  String get pdfMealGroupsTitle;
  String get pdfImportantSelection;
  String get pdfCookingTip;
  String get errorNoActivePlan;
  String get pdfWelcomeProtein;
  String get pdfWelcomeCarbs;
  String get pdfWelcomeFats;
  String get pdfSelectOneOptionTitle;
  String adviceExceedMacrosNoMeals(String option);
  String adviceExceedMacrosConsumed(
      int consumed, String option, int optionCal, int remaining);
  String adviceExceedMacrosAllMeals(String option);
  String adviceExceedMacrosRemaining(
      int consumed, String option, int optionCal, int remaining, int mealsLeft);
  String get mealBreakfast;
  String get mealLunch;
  String get mealDinner;
  String get mealSnackAm;
  String get mealSnackPm;
  String get mealShake;
  String get mealSnackFruit;
  String get pdfHowToUsePlanTitle;
  String get pdfYourObjectiveIs;
  String get modificationsSubtitle;
  String get editMyPlanTitle;
  String get editMyPlanDescription;
  String get editPlanButton;
  String get updateProfileTitle;
  String get updateProfileDescription;
  String get updateProfileButton;
  String errorLoadingProfileWithMsg(String error);
  String get noImageSelected;
  String errorAnalyzingImageWithMsg(String error);
  String get galleryPermissionDenied;
  String get galleryPermissionRequired;
  String get weightUpdatedSuccess;
  String errorSavingWeightWithMsg(String error);
  String get congratsProgressTitle;
  String get weightChangeDetected;
  String get recommendRecalculatePlan;
  String get later;
  String get bodyAnalysisTitle;
  String get bodyAnalysisSubtitle;
  String get bodyAnalysisTip;
  String get uploadPhoto;
  String get uploadPhotoInstruction;
  String get progressRegistryTitle;
  String get progressRegistrySubtitle;
  String get updatePlanNow;
  String get notAvailable;
  String get language;
  String get selectLanguage;
  String get personalizedTipsTitle;
  String get anthropometricGuidanceTitle;
  String exceededBy(String amount);
  String get difficultySupportTitle;
  String get eatingOutGuidanceTitle;
  String get motivationTitle;
  String get ageSpecificAdviceTitle;
  String get dailyMacrosTitle;
  String get caloriesLabel;
  String get proteinLabel;
  String get carbsLabel;
  String get fatsLabel;
  String get recommendationsTitle;
  String errorLoadingRecipes(String e);
  String get premiumRequiredTitle;
  String get premiumRequiredSubtitle;
  String get premiumUpgradeMessage;
  String get upgradeButton;
  String get myRecipesTitle;
  String get inspirationTab;
  String get noRecipesAvailable;
  String get upgradePlanButton;
  String get searchRecipesHint;
  String get allFilter;
  String get loadingImage;
  String get noFormulasAvailable;
  String viewIdeasFor(String meal);
  String get ingredientsTitle;
  String get defaultIngredientName;
  String get preparationTitle;
  String servingsCount(int count);
  String get shoppingListTitle;
  String get errorLoadingIngredients;
  String get retryButton;
  String get emptyShoppingList;
  String get generatePlanToSeeList;
  String get noActivePlanError;

  String get languageMismatchTitle;
  String get languageMismatchContent;
  String get useEnglish;
  String get useSpanish;

  // New keys for ProfessionalMiPlanDiarioScreen
  String get pdfRecsKitchenBody;
  String get understoodButton;
  String helloUser(String name);
  String get suggestionsTitle;
  String get vegetables;
  String get fruits;
  String get kcal;
  String get proteinLabelShort;
  String get carbsLabelShort;
  String get fatsLabelShort;

  // New keys added by user request
  String get snackAM;
  String get snackPM;
  String get completeMixedSalad;
  String get steamedVegetablesBowl;
  String get mediterraneanSalad;
  String get sauteedVegetables;
  String get largeMixedGreenSalad;
  String get cruciferousVegetablesSalad;
  String get lowCarbVegetablesMix;

  String get personalizedMessageAM;
  String get personalizedMessagePM;
  String get personalizedMessageDefault;

  String get planReadyGoalReach;

  // PlanCarousel
  String get planCarouselPersonalizedRecipes;
  String get planCarouselActivateSubscription;
  String get planCarouselUpgradePlan;
  String get planCarouselErrorLoading;
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
