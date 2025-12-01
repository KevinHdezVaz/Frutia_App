import 'dart:async';
import 'package:Frutia/providers/QuestionnaireProvider.dart';
import 'package:Frutia/providers/ShoppingProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frutia/onscreen/SplashScreen.dart';
import 'package:Frutia/services/BonoService.dart';
import 'package:Frutia/services/settings/theme_data.dart';
import 'package:Frutia/services/settings/theme_provider.dart';
import 'package:Frutia/utils/constantes.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:showcaseview/showcaseview.dart';

import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final BonoService _bonoService = BonoService(baseUrl: baseUrl);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ BLOQUEAR ORIENTACIÓN A VERTICAL
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int isviewed = prefs.getInt('onBoard') ?? 1;

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.initialize("5fad8140-b31f-4893-b00f-5f896e38b7d6");
  OneSignal.Notifications.addClickListener((event) {
    print('NOTIFICATION OPENED HANDLER: ${event.notification.body}');
  });
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print(
        'NOTIFICATION WILL DISPLAY IN FOREGROUND: ${event.notification.body}');
    event.preventDefault();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => QuestionnaireProvider()),
      ],
      child: ShowCaseWidget(
        builder: (context) => MyApp(isviewed: isviewed),
        autoPlay: false,
        enableAutoScroll: true,
        blurValue: 1.5,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final int isviewed;

  const MyApp({super.key, required this.isviewed});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          themeMode: themeProvider.currentTheme,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: SplashScreen(isviewed: isviewed),
          builder: (context, child) {
            return ShowCaseWidget(
              builder: (ctx) => child!,
            );
          },
        );
      },
    );
  }
}
