import 'dart:convert';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/LocaleHelper.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  final StorageService _storage = StorageService();

  // ⭐ NUEVO: Método para obtener headers con idioma
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    final languageCode =
        await LocaleHelper.getAppLanguageCode(); // ⭐ USAR IDIOMA DE LA APP

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept-Language': languageCode, // ⭐ AGREGAR ESTO
    };
  }

  Future<Map<String, dynamic>?> getProfile() async {
    print('[ProfileService] Initiating profile fetch...');

    final token = await _storage.getToken();
    if (token == null) {
      print('[ProfileService] Error: Token not found. User not authenticated.');
      throw Exception('User not authenticated.');
    }

    print('[ProfileService] Token obtained successfully.');

    try {
      final headers = await _getHeaders(); // ⭐ USAR HEADERS CON IDIOMA

      print('[ProfileService] Making request to $baseUrl/profile...');
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers, // ⭐ CAMBIAR AQUÍ
      );

      print(
          '[ProfileService] Response received. Status code: ${response.statusCode}');
      print('[ProfileService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('[ProfileService] Profile fetched successfully.');
        return responseData['user'] as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        print('[ProfileService] Profile not found for this user (404).');
        return null;
      } else {
        print('[ProfileService] Error fetching profile from server.');
        try {
          final errorBody = json.decode(response.body);
          throw Exception(errorBody['message'] ??
              'Error fetching profile. Code: ${response.statusCode}');
        } catch (e) {
          throw Exception(
              'Error fetching profile. Code: ${response.statusCode}. Body: ${response.body}');
        }
      }
    } catch (e) {
      print('[ProfileService] Exception while fetching profile: $e');
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<void> saveProfile(Map<String, dynamic> profileData) async {
    print('[ProfileService] Iniciando guardado de perfil...');
    print('[ProfileService] Datos del perfil: $profileData');

    final token = await _storage.getToken();
    if (token == null) {
      print(
          '[ProfileService] Error: Token no encontrado. Usuario no autenticado.');
      throw Exception('Usuario no autenticado.');
    }

    print('[ProfileService] Token obtenido correctamente.');

    try {
      final headers = await _getHeaders(); // ⭐ USAR HEADERS CON IDIOMA

      print('[ProfileService] Realizando petición a $baseUrl/profile...');
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: headers, // ⭐ CAMBIAR AQUÍ
        body: json.encode(profileData),
      );

      print(
          '[ProfileService] Respuesta recibida. Status code: ${response.statusCode}');
      print('[ProfileService] Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode != 200) {
        print('[ProfileService] Error en la respuesta del servidor.');
        throw Exception(
            'Error al guardar el perfil. Código: ${response.statusCode}');
      }

      print('[ProfileService] Perfil guardado exitosamente.');
    } catch (e) {
      print('[ProfileService] Excepción al guardar el perfil: $e');
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
