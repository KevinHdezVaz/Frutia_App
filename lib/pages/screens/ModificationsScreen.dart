// lib/pages/screens/ModificationsScreen.dart
// ESTE ARCHIVO DEBE SER LA PANTALLA QUE CARGA LOS DATOS Y LANZA EL CUESTIONARIO.

import 'dart:convert';

import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Frutia/utils/colors.dart'; // Colores de tu app

class ModificationsScreen extends StatefulWidget {
  const ModificationsScreen({super.key});

  @override
  State<ModificationsScreen> createState() => _ModificationsScreenState();
}

class _ModificationsScreenState extends State<ModificationsScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Carga los datos del perfil al iniciar
  }

  // Función para cargar los datos del perfil del usuario
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _error = null; // Reinicia el estado de error
    });
    try {
      final profile = await _authService
          .getProfile(); // Llama a tu servicio para obtener el perfil
      if (profile != null) {
        // --- MANEJO DE DATOS PARA COMPATIBILIDAD ---
        // Asegúrate de que los datos de lista (ej. 'sport', 'diet_difficulties')
        // se manejen correctamente si vienen como JSON string desde Laravel.
        // Si tu ProfileService ya los parseó a List<dynamic> o List<String>, está bien.
        // Si no, esta es la lógica de deserialización antes de pasar a QuestionnaireFlow.
        if (profile['sport'] is String) {
          profile['sport'] = (profile['sport'] as String)
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
        if (profile['diet_difficulties'] is String) {
          // Asume que Laravel lo envía como un string JSON o separado por comas
          try {
            // Intenta JSON primero
            final decodedList =
                jsonDecode(profile['diet_difficulties'] as String);
            if (decodedList is List) {
              profile['diet_difficulties'] = decodedList.cast<String>();
            } else {
              // Si no es JSON, trata como string simple
              profile['diet_difficulties'] =
                  (profile['diet_difficulties'] as String)
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
            }
          } catch (_) {
            // Si falla JSON, trata como string simple
            profile['diet_difficulties'] =
                (profile['diet_difficulties'] as String)
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
          }
        } else if (profile['diet_difficulties'] == null) {
          profile['diet_difficulties'] =
              []; // Asegura que sea una lista vacía si es null
        }

        if (profile['diet_motivations'] is String) {
          try {
            // Intenta JSON primero
            final decodedList =
                jsonDecode(profile['diet_motivations'] as String);
            if (decodedList is List) {
              profile['diet_motivations'] = decodedList.cast<String>();
            } else {
              // Si no es JSON, trata como string simple
              profile['diet_motivations'] =
                  (profile['diet_motivations'] as String)
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
            }
          } catch (_) {
            // Si falla JSON, trata como string simple
            profile['diet_motivations'] =
                (profile['diet_motivations'] as String)
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
          }
        } else if (profile['diet_motivations'] == null) {
          profile['diet_motivations'] =
              []; // Asegura que sea una lista vacía si es null
        }
        // --- FIN MANEJO DE DATOS ---

        setState(() {
          _profileData = profile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se encontraron datos de perfil existentes.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print(
          'Error al cargar el perfil en ModificationsScreen: $e'); // Para depuración
      setState(() {
        _error = 'Error al cargar el perfil: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Muestra un indicador de carga mientras se obtienen los datos
    if (_isLoading) {
      return Scaffold(
        backgroundColor: FrutiaColors.primaryBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: FrutiaColors.accent),
              const SizedBox(height: 16),
              Text(
                'Cargando tu perfil para modificar...',
                style: GoogleFonts.lato(
                    fontSize: 18, color: FrutiaColors.secondaryText),
              ),
            ],
          ),
        ),
      );
    }

    // Muestra un mensaje de error si la carga falla
    if (_error != null) {
      return Scaffold(
        backgroundColor: FrutiaColors.primaryBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontSize: 18, color: FrutiaColors.primaryText),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProfileData, // Permite reintentar la carga
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrutiaColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Si los datos se cargaron con éxito, muestra el QuestionnaireFlow con los datos iniciales
    // Y espera un resultado de la edición.
    return QuestionnaireFlow(initialProfileData: _profileData);
  }
}
