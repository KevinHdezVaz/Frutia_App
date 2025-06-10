import 'dart:convert';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  final StorageService _storage = StorageService();

  /// Envía los datos del perfil del usuario al backend para guardarlos.
  Future<void> saveProfile(Map<String, dynamic> profileData) async {
    print('[ProfileService] Iniciando guardado de perfil...'); // Log de inicio
    print('[ProfileService] Datos del perfil: $profileData'); // Log de datos

    final token = await _storage.getToken();
    if (token == null) {
      print(
          '[ProfileService] Error: Token no encontrado. Usuario no autenticado.'); // Log de error
      throw Exception('Usuario no autenticado.');
    }

    print('[ProfileService] Token obtenido correctamente.'); // Log de éxito

    try {
      print(
          '[ProfileService] Realizando petición a $baseUrl/profile...'); // Log de URL
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      );

      print(
          '[ProfileService] Respuesta recibida. Status code: ${response.statusCode}'); // Log de status
      print(
          '[ProfileService] Cuerpo de la respuesta: ${response.body}'); // Log de cuerpo (útil para depuración)

      if (response.statusCode != 200) {
        print(
            '[ProfileService] Error en la respuesta del servidor.'); // Log de error
        throw Exception(
            'Error al guardar el perfil. Código: ${response.statusCode}');
      }

      print('[ProfileService] Perfil guardado exitosamente.'); // Log de éxito
    } catch (e) {
      print(
          '[ProfileService] Excepción al guardar el perfil: $e'); // Log de excepción
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
