// lib/main.dart

import 'dart:async';
import 'dart:convert';
import 'package:Frutia/providers/QuestionnaireProvider.dart';
import 'package:Frutia/providers/ShoppingProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // Asegúrate que esta importación esté
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/onscreen/SplashScreen.dart';
import 'package:Frutia/onscreen/onboardingWrapper.dart';
import 'package:Frutia/pages/bottom_nav.dart';
import 'package:Frutia/services/BonoService.dart';
import 'package:Frutia/services/settings/theme_data.dart';
import 'package:Frutia/services/settings/theme_provider.dart';
import 'package:Frutia/utils/constantes.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

// IMPORTA TU QUESTIONNAIRE PROVIDER
// La ruta puede variar según donde lo hayas guardado.

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

  // USA MULTIPROVIDER PARA REGISTRAR TODOS TUS PROVEEDORES
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => QuestionnaireProvider()),
      ],
      child: MyApp(isviewed: isviewed),
    ),
  );
}

// ... El resto de tu código de main.dart permanece igual ...

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
    // Ya no necesitas esta línea aquí si no la usas en este build.
    // Provider.of lo usarás dentro de los widgets que lo necesiten.
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<ThemeProvider>(
      // Es mejor usar Consumer para reconstruir solo lo necesario
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          themeMode: themeProvider.currentTheme,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: SplashScreen(isviewed: isviewed),
        );
      },
    );
  }
}

enum PaymentStatus { success, failure, approved, pending, unknown }
