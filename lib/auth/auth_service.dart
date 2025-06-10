import 'dart:convert';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:http/http.dart' as http;

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  final StorageService _storage = StorageService();

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
      return data;
    } else {
      // Laravel validation errors (422) a menudo vienen con un mapa de errores
      String errorMessage = data['message'] ?? 'Ocurrió un error desconocido.';
      if (data['errors'] != null) {
        errorMessage = data['errors'].values.first[0];
      }
      throw AuthException(errorMessage);
    }
  }

  /// Intenta iniciar sesión.
  /// Devuelve el mapa del usuario y el token si es exitoso.
  /// Lanza una AuthException si falla.
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
}
