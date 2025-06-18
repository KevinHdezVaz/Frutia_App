import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Importar el TTS nativo
import 'package:path_provider/path_provider.dart';

class ElevenLabsService {
  final String apiKey;
  final FlutterTts flutterTts; // Inyectar la dependencia del TTS nativo
  final String baseUrl = 'https://api.elevenlabs.io/v1/text-to-speech';
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isSpeaking = false;

  // Callbacks para notificar al exterior sobre el estado
  VoidCallback? _onStart;
  VoidCallback? _onComplete;

  ElevenLabsService({required this.apiKey, required this.flutterTts}) {
    _configureAudioPlayer();
    _configureTtsHandlers();
  }

  /// Configura los manejadores para ambos sistemas de TTS
  void _configureTtsHandlers() {
    // Manejador para cuando el audio de ElevenLabs (audioplayers) termina
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _isSpeaking = false;
        _onComplete?.call();
      }
    });

    // Manejador para cuando el audio del TTS nativo (flutter_tts) comienza
    flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _onStart?.call();
    });

    // Manejador para cuando el audio del TTS nativo (flutter_tts) termina
    flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _onComplete?.call();
    });
  }

  // Métodos para establecer los callbacks desde RecordingScreen
  void setOnStart(VoidCallback onStart) {
    _onStart = onStart;
  }
  
  void setOnComplete(VoidCallback onComplete) {
    _onComplete = onComplete;
  }

  Future<void> _configureAudioPlayer() async {
    // ... (sin cambios aquí, tu configuración original es correcta)
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.setVolume(1.0);
  }

  Future<void> speak(String text, String voiceId, String language) async {
    if (_isSpeaking) {
      await stop();
    }

    try {
      // --- INTENTO 1: USAR ELEVENLABS ---
      print("▶️ Intentando usar ElevenLabs...");
      final response = await http
          .post(
            Uri.parse('$baseUrl/$voiceId'),
            headers: _buildHeaders(),
            body: _buildBody(text, language),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        // Si el status no es 200, lanza una excepción para activar el fallback
        throw Exception('Error de ElevenLabs: ${response.statusCode}');
      }

      // Notificar que el audio va a empezar (para ElevenLabs)
      _isSpeaking = true;
      _onStart?.call();

      await _playAudioBytes(response.bodyBytes);

    } catch (e) {
      // --- INTENTO 2: FALLBACK AL TTS NATIVO ---
      print("⚠️ ElevenLabs falló ($e). Usando TTS nativo como fallback.");
      _isSpeaking = true; // El start handler de flutterTts se encargará de esto
      await flutterTts.speak(text);
    }
  }

  Future<void> _playAudioBytes(Uint8List bytes) async {
    if (Platform.isIOS) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/el_audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(bytes);
      await _audioPlayer.play(DeviceFileSource(file.path));
      // La limpieza del archivo se podría manejar en el onPlayerStateChanged
    } else {
      await _audioPlayer.play(BytesSource(bytes));
    }
  }

  Map<String, String> _buildHeaders() => {
        'accept': 'audio/mpeg',
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      };

  String _buildBody(String text, String language) => json.encode({
        'text': text,
        'model_id': 'eleven_multilingual_v2',
        'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
      });

  Future<void> stop() async {
    // Detener ambos reproductores por si acaso
    await _audioPlayer.stop();
    await flutterTts.stop();
    _isSpeaking = false;
  }

  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
  }

  bool get isSpeaking => _isSpeaking;
}