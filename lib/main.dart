import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/onscreen/SplashScreen.dart';
import 'package:Frutia/onscreen/onboardingWrapper.dart';
import 'package:Frutia/pages/bottom_nav.dart';
import 'package:Frutia/services/BonoService.dart';
import 'package:Frutia/services/settings/theme_data.dart';
import 'package:Frutia/services/settings/theme_provider.dart';
import 'package:Frutia/model/MathPartido.dart';
import 'package:Frutia/utils/constantes.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

// Llaves globales
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final BonoService _bonoService = BonoService(baseUrl: baseUrl);

// Stream controller para estado del pago
final paymentStatusController =
    StreamController<Map<String, dynamic>>.broadcast();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int isviewed = prefs.getInt('onBoard') ?? 1;

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(isviewed: isviewed),
    ),
  );
}

void _showPaymentMessage(String message, Color color) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class MyApp extends StatelessWidget {
  final int isviewed;

  const MyApp({super.key, required this.isviewed});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      themeMode: themeProvider.currentTheme,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: SplashScreen(isviewed: isviewed),
    );
  }
}

enum PaymentStatus { success, failure, approved, pending, unknown }