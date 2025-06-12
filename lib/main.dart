// lib/main.dart

import 'dart:async';
import 'package:Frutia/providers/QuestionnaireProvider.dart';
import 'package:Frutia/providers/ShoppingProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/onscreen/SplashScreen.dart';
import 'package:Frutia/services/BonoService.dart';
import 'package:Frutia/services/settings/theme_data.dart';
import 'package:Frutia/services/settings/theme_provider.dart';
import 'package:Frutia/utils/constantes.dart';
import 'firebase_options.dart';

// --- AÑADE ESTA IMPORTACIÓN ---
import 'package:flutter_localizations/flutter_localizations.dart';


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
  
  // --- LÍNEA ELIMINADA ---
  // Ya no necesitas la llamada manual a initializeDateFormatting.
  // await initializeDateFormatting('es_ES', null);

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
  // ...
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
          
          // --- AÑADE ESTAS LÍNEAS PARA LA LOCALIZACIÓN ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'), // Español
            Locale('en', 'US'), // Inglés (opcional)
          ],
          locale: const Locale('es', 'ES'), // Establece el idioma por defecto
          // ---------------------------------------------
          
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
