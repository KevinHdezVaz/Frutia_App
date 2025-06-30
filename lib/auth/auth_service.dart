import 'dart:convert';
import 'dart:io';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Importa si no lo tienes
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart'; // ¡Importa OneSignal!

import '../model/User.dart' as frutia;

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  final StorageService _storage = StorageService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final storage = StorageService();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Configuración para iOS:
    clientId: Platform.isIOS
        ? '730095641142-qj58r88ha7vnjlro9b5gsmb8upo9idcu.apps.googleusercontent.com' // De GoogleService-Info.plist
        : null,
    serverClientId:
        '730095641142-2sc256o1n605r12hshom8sop83l5p4sk.apps.googleusercontent.com', // De google-services.json (client_type 3)
  );

  /// Intenta registrar un nuevo usuario.
  /// Devuelve el mapa del usuario y el token si es exitoso.
  /// Lanza una AuthException si falla.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      await _storage.saveToken(data['token']);
      // Despúes de un registro exitoso, intenta enviar el Player ID
      await _sendOneSignalPlayerIdToBackend(); // <--- Llamada aquí
      return data;
    } else {
      String errorMessage = data['message'] ?? 'Ocurrió un error desconocido.';
      if (data['errors'] != null) {
        errorMessage = data['errors'].values.first[0];
      }
      throw AuthException(errorMessage);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      debugPrint('Iniciando login con Google...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final String? firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) {
        throw AuthException("No se obtuvo token de Firebase");
      }

      final success = await _sendTokenToBackend(firebaseToken, 'google');
      if (success) {
        await _sendOneSignalPlayerIdToBackend(); // <--- Llamada aquí
      }
      return success;
    } on AuthException catch (e) {
      debugPrint('Error de autenticación: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error inesperado en Google Sign-In: $e');
      throw AuthException('Error inesperado al iniciar sesión con Google');
    }
  }

  Future<bool> _sendTokenToBackend(
      String firebaseToken, String provider) async {
    try {
      final endpoint = provider == 'google' ? 'google-login' : 'facebook-login';
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_token': firebaseToken}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _storage.saveToken(data['token']);

        if (data['user'] != null) {
          await _storage.saveUser(frutia.User.fromJson(data['user']));
        }
        return true;
      } else {
        String errorMessage =
            data['message'] ?? 'Error en autenticación con Google';
        if (data['errors'] != null) {
          errorMessage = data['errors'].values.first[0];
        }
        throw AuthException(errorMessage);
      }
    } catch (e) {
      debugPrint('Error en _sendTokenToBackend: $e');
      throw AuthException(e.toString());
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      await _storage.saveToken(data['token']);
      await _sendOneSignalPlayerIdToBackend(); // <--- Llamada aquí
      return data;
    } else {
      throw AuthException(data['message'] ?? 'Credenciales inválidas.');
    }
  }

  /// Cierra la sesión del usuario.
  Future<void> logout() async {
    final token = await _storage.getToken();
    if (token == null) return; // No hay sesión que cerrar

    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
    } finally {
      // Siempre elimina el token local, incluso si la llamada a la API falla.
      await _storage.removeToken();
      // Opcional: Remover External ID de OneSignal al cerrar sesión
    }
  }

  /// Obtiene los datos del perfil del usuario autenticado.
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _storage.getToken();
    if (token == null) throw AuthException('No autenticado.');

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw AuthException('No se pudo obtener el perfil.');
    }
  }

  // --- NUEVO MÉTODO: Obtener y Enviar OneSignal Player ID ---
  Future<void> _sendOneSignalPlayerIdToBackend() async {
    try {
      // Obtén el Player ID de OneSignal
      // Puede tomar un momento para que OneSignal lo inicialice,
      // por eso el pequeño retraso o la verificación de que no sea nulo.
      String? playerId = OneSignal.User.pushSubscription.id;

      if (playerId == null) {
        print('OneSignal Player ID no disponible. Intentando de nuevo...');
        // Opcional: Esperar un poco más o reintentar
        await Future.delayed(const Duration(seconds: 2));
        playerId = OneSignal.User.pushSubscription.id;
        if (playerId == null) {
          print(
              'OneSignal Player ID sigue sin estar disponible. No se enviará al backend.');
          return;
        }
      }

      print('OneSignal Player ID obtenido: $playerId');

      final String apiUrl =
          '$baseUrl/user/update-onesignal-id'; // URL de tu API
      final String? token = await _storage.getToken();

      if (token == null) {
        print(
            'No hay token de autenticación disponible para enviar el Player ID.');
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'onesignal_player_id': playerId,
        }),
      );

      if (response.statusCode == 200) {
        print(
            'OneSignal Player ID enviado y guardado en el backend con éxito.');
      } else {
        print(
            'Error al enviar OneSignal Player ID al backend: ${response.statusCode}');
        print('Respuesta del backend: ${response.body}');
      }
    } catch (e) {
      print('Excepción al intentar enviar OneSignal Player ID al backend: $e');
    }
  }
  // --- FIN NUEVO MÉTODO ---
}
