import 'dart:async';
import 'package:Frutia/providers/QuestionnaireProvider.dart';
import 'package:Frutia/providers/ShoppingProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

// Llaves globales que pueden ser útiles en toda la app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final BonoService _bonoService = BonoService(baseUrl: baseUrl);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int isviewed = prefs.getInt('onBoard') ?? 1;

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configuración de OneSignal
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

// MyApp puede volver a ser un StatelessWidget, ya que no necesita manejar el estado de los deep links.
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
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],
          locale: const Locale('es', 'ES'),
          themeMode: themeProvider.currentTheme,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: SplashScreen(isviewed: isviewed),
          builder: (context, child) {
            // El ShowCaseWidget se puede mantener aquí si se usa en múltiples partes de la app.
            return ShowCaseWidget(
              builder: (ctx) => child!,
            );
          },
        );
      },
    );
  }
}
