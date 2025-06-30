import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:Frutia/pages/screens/chatFrutia/ElevenLabsService.dart';
import 'package:Frutia/pages/screens/chatFrutia/PermissionService.dart';
import 'package:Frutia/services/ChatServiceApi.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:showcaseview/showcaseview.dart'; // Importa showcaseview
import 'package:shared_preferences/shared_preferences.dart'; // Para gestionar si ya se mostró

// WIDGET MEJORADO: Visualizador de ondas de sonido para el micrófono
class SoundWaveVisualizer extends StatefulWidget {
  final bool isRecording;

  const SoundWaveVisualizer({
    Key? key,
    required this.isRecording,
  }) : super(key: key);

  @override
  _SoundWaveVisualizerState createState() => _SoundWaveVisualizerState();
}

class _SoundWaveVisualizerState extends State<SoundWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 2000), // Duración más larga para una pulsación suave
    );

    if (widget.isRecording) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SoundWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (!widget.isRecording && _waveController.isAnimating) {
      _waveController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Solo muestra el widget si está grabando
    if (!widget.isRecording) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(animationValue: _waveController.value),
          child: Container(),
        );
      },
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }
}

// PAINTER MEJORADO: Dibuja ondas de pulsación constante
class WavePainter extends CustomPainter {
  final double animationValue; // Un valor que va de 0.0 a 1.0
  final int waveCount = 3;

  WavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        size.width / 2.2; // El radio máximo que puede alcanzar una onda

    // Dibuja múltiples ondas para un efecto más notable
    for (int i = 0; i < waveCount; i++) {
      // Cada onda está desfasada en la animación
      final waveValue = (animationValue + (i / waveCount)) % 1.0;
      final radius = maxRadius * waveValue;

      // La opacidad es alta al principio y se desvanece a medida que la onda se expande
      final opacity = (1.0 - waveValue) * 0.7;

      final paint = Paint()
        ..color = Colors.red.withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0; // Un poco más gruesa

      // Solo dibuja si el radio es significativo para evitar un punto en el centro
      if (radius > 5) {
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class RecordingScreen extends StatefulWidget {
  final String language;
  final ChatServiceApi chatService;

  const RecordingScreen({
    Key? key,
    required this.language,
    required this.chatService,
  }) : super(key: key);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late ElevenLabsService _elevenLabsService;
  late FlutterTts _flutterTts;
  bool _isRecording = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  bool _isAiAudioPlaying = false;

  String _partialTranscription = '';
  String _finalUserTranscription = ''; // <-- NUEVA VARIABLE AQUÍ

  String _aiResponse = '';
  String _statusMessage = 'Toca el micrófono para grabar';
  String _emotionalState = 'neutral';
  String _conversationLevel = 'basic';
  bool _hasVibrator = false;
  double _soundLevel = 0.0;
  Timer? _silenceTimer;
  final int _silenceTimeout = 3000;
  bool _showListeningIndicator = false;
  bool _isSpeechInitialized = false;

  late AnimationController _thinkingAnimationController;
  late AnimationController _rhythmAnimationController;

  StreamSubscription<AudioInterruptionEvent>? _audioSessionSubscription;

  // --- GlobalKey para el Showcase del micrófono ---
  final GlobalKey _micButtonShowcaseKey =
      GlobalKey(debugLabel: 'recordingMicButtonShowcase');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts(); // Se inicializa FlutterTts

    _elevenLabsService = ElevenLabsService(
      apiKey: "sk_5c7014c450eb767dbc8cd3ca2cdadadaceb4dbc52708cac9",
      flutterTts: _flutterTts, // <-- Añade esta línea
    );

    _thinkingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _rhythmAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _rhythmAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _rhythmAnimationController.forward();
        }
      });

    _initTts();
    _initVibration();
    if (Platform.isIOS) {
      _configureAudioSession();
    }

    // --- Llama al showcase después de que el widget se haya construido ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRecordingScreenShowcase();
    });
  }

  Future<void> _showRecordingScreenShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final bool showcaseShown =
        prefs.getBool('recordingScreenShowcaseShown') ?? false;

    if (!showcaseShown && mounted) {
      // Un pequeño retraso para asegurar que los elementos estén completamente renderizados
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted && ShowCaseWidget.of(context).mounted) {
        ShowCaseWidget.of(context).startShowCase([_micButtonShowcaseKey]);
        await prefs.setBool('recordingScreenShowcaseShown', true);
        debugPrint('RecordingScreen: Showcase del micrófono iniciado!');
      } else {
        debugPrint(
            'RecordingScreen: ShowCaseWidget o el contexto no están montados.');
      }
    } else {
      debugPrint(
          'RecordingScreen: Showcase de micrófono ya mostrado o condiciones no cumplidas.');
    }
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.defaultToSpeaker |
                AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      ));
      await session.setActive(true);

      _audioSessionSubscription =
          session.interruptionEventStream.listen((event) {
        if (event.begin) {
          _stopAllActivity();
        }
      });
    } catch (e) {
      debugPrint('Error configuring audio session: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Future<bool> _checkPermissionsBeforeRecording() async {
    final permissionService = PermissionService();
    final micStatus =
        await permissionService.checkOrRequest(Permission.microphone);

    if (!micStatus.isGranted) {
      _showErrorSnackBar('Permiso de micrófono requerido para continuar.');
      if (micStatus.isPermanentlyDenied && mounted) {
        await openAppSettings();
      }
      return false;
    }
    return true;
  }

  Future<void> _initTts() async {
    _elevenLabsService.setOnStart(() {
      if (!mounted) return;
      setState(() {
        _isAiAudioPlaying = true;
      });
      _rhythmAnimationController.forward(from: 0);
    });
    _elevenLabsService.setOnComplete(_handleAudioCompletion);

    final languageMap = {
      'es': 'es-ES',
      'en': 'en-US',
      'fr': 'fr-FR',
      'pt': 'pt-BR'
    };
    await _flutterTts.setLanguage(languageMap[widget.language] ?? 'es-ES');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.1);
    _flutterTts.setCompletionHandler(() => _handleAudioCompletion());

    _flutterTts.setStartHandler(() {
      if (!mounted) return;
      setState(() {
        _isAiAudioPlaying = true;
      });
      _rhythmAnimationController.forward(from: 0);
    });
    _flutterTts.setCompletionHandler(_handleAudioCompletion);
  }

  void _closeScreen() {
    _stopAllActivity();
    if (mounted) {
      final String userTextToSend = _finalUserTranscription.isNotEmpty
          ? _finalUserTranscription
          : _partialTranscription;

      Navigator.pop(context, {
        'transcription': userTextToSend,
        'ai_response': _aiResponse,
        'emotional_state': _emotionalState,
        'conversation_level': _conversationLevel,
      });
    }
  }

  void _handleAudioCompletion() {
    if (!mounted) return;
    setState(() {
      _isSpeaking = false;
      _isProcessing = false;
      _isAiAudioPlaying = false;
      _statusMessage = 'Toca el micrófono para grabar';
      _showListeningIndicator = false;
      _rhythmAnimationController.stop();
    });
  }

  Future<void> _initVibration() async {
    _hasVibrator = (await Vibration.hasVibrator()) ?? false;
  }

  void _onMicButtonPressed() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording || _isSpeaking || _isProcessing) return;
    if (!await _checkPermissionsBeforeRecording()) return;

    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _speech.initialize(
        onError: (error) => _handleRecordingError(error.errorMsg),
        onStatus: (status) {
          if (mounted && status == 'listening') {
            setState(() {
              _statusMessage = 'Escuchando...';
              _showListeningIndicator = true;
            });
          }
        },
      );
      if (!_isSpeechInitialized) {
        _showErrorSnackBar('No se pudo inicializar el reconocimiento de voz.');
        return;
      }
    }

    final localeId = {
          'es': 'es_ES',
          'en': 'en_US',
          'fr': 'fr_FR',
          'pt': 'pt-BR'
        }[widget.language] ??
        'es_ES';

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _partialTranscription = result.recognizedWords;
          _showListeningIndicator = true;
        });
        _resetSilenceTimer();
      },
      onSoundLevelChange: (level) {
        if (!mounted) return;
        setState(() {
          _soundLevel = (level.clamp(-160, 0) + 160) / 160;
        });
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 60),
      partialResults: true,
    );

    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _statusMessage = 'Escuchando...';
      _showListeningIndicator = true;
    });
    if (_hasVibrator) Vibration.vibrate(duration: 50);
    _startSilenceTimer();
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _startSilenceTimer();
  }

  void _startSilenceTimer() {
    _silenceTimer = Timer(Duration(milliseconds: _silenceTimeout), () {
      if (_isRecording && mounted) {
        _stopRecording();
      }
    });
  }

  void _handleRecordingError(String errorMsg) {
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Error: $errorMsg';
      _isRecording = false;
      _isProcessing = false;
      _soundLevel = 0.0;
    });
  }

  Future<void> _stopRecording() async {
    _silenceTimer?.cancel();
    if (!_isRecording) return;

    await _speech.stop();

    if (!mounted) return;

    if (_hasVibrator) Vibration.vibrate(duration: 50);

    setState(() {
      _isRecording = false;
      _soundLevel = 0.0;
      if (_partialTranscription.trim().isEmpty) {
        _statusMessage = 'No se detectó voz. Toca para grabar.';
        _showListeningIndicator = false;
      } else {
        _isProcessing = true;
        _statusMessage = 'Procesando...';
      }
    });

    if (_partialTranscription.trim().isNotEmpty) {
      await _processTranscription();
    }
  }

  Future<void> _processTranscription() async {
    if (_partialTranscription.trim().isNotEmpty) {
      _finalUserTranscription = _partialTranscription;
    }

    try {
      final response = await widget.chatService.sendVoiceMessage(
        message: _finalUserTranscription, // Usa la transcripción final
        sessionId: null,
      );

      if (!mounted) return;

      setState(() {
        _aiResponse = response['ai_message']['text'];
        _emotionalState =
            response['ai_message']['emotional_state'] ?? 'neutral';
        _conversationLevel =
            response['ai_message']['conversation_level'] ?? 'basic';
        _statusMessage = 'IA Hablando...';
        _isSpeaking = true;
        _isProcessing = false;
        _showListeningIndicator = true;
        _rhythmAnimationController.forward();
        _partialTranscription = '';
      });

      await _speakResponse(_aiResponse);
    } catch (e) {
      _handleRecordingError("Error al procesar: ${e.toString()}");
    }
  }

  Future<void> _speakResponse(String text) async {
    try {
      await _elevenLabsService.speak(
          text, 'pFZP5JQG7iQjIQuC4Bku', widget.language);
    } catch (e) {
      debugPrint("Error con ElevenLabs, usando fallback TTS: $e");
      try {
        await _flutterTts.speak(text);
      } catch (e2) {
        _showErrorSnackBar("Error en ambos servicios de audio.");
        _handleAudioCompletion();
      }
    }
  }

  void _stopAiSpeaking() {
    _elevenLabsService.stop();
    _flutterTts.stop();
    _handleAudioCompletion();
  }

  void _stopAllActivity() {
    _silenceTimer?.cancel();
    if (_speech.isListening) {
      _speech.stop();
    }
    _flutterTts.stop();
    _elevenLabsService.stop();

    if (mounted) {
      setState(() {
        _isRecording = false;
        _isSpeaking = false;
        _isProcessing = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopAllActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _closeScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [FrutiaColors.accent, FrutiaColors.accent2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            'Chat de voz',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: _closeScreen,
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: ParticulasFlotantes()),
              Column(
                children: [
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: _showListeningIndicator ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isRecording
                            ? (_partialTranscription.isEmpty
                                ? 'Escuchando...'
                                : _partialTranscription)
                            : _statusMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isProcessing
                            ? Lottie.asset(
                                'assets/images/animacioncirculo.json',
                                width: 250,
                                height: 250,
                                controller: _thinkingAnimationController,
                                key: const Key('processing'),
                              )
                            : _isAiAudioPlaying
                                ? Lottie.asset(
                                    'assets/images/speaking.json',
                                    width: 250,
                                    height: 250,
                                    controller: _rhythmAnimationController,
                                    key: const Key('speaking'),
                                  )
                                : CircleAvatar(
                                    radius: 125,
                                    backgroundColor: Colors.transparent,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/frutamedica.png',
                                        width: 250,
                                        height: 250,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    key: const Key('idle'),
                                  ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // --- ShowCase para el Botón del Micrófono ---
                        Showcase(
                          key: _micButtonShowcaseKey,
                          title: 'Botón de Micrófono',
                          description:
                              'Toca para iniciar la grabación de tu voz. La grabación se enviara a Frutia automaticamente cuando dejes de hablar.',
                          tooltipBackgroundColor: FrutiaColors.accent,
                          targetShapeBorder: const CircleBorder(),
                          titleTextStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          descTextStyle: GoogleFonts.lato(
                              color: Colors.white, fontSize: 14),
                          disableMovingAnimation: true,
                          disableScaleAnimation: true,
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SoundWaveVisualizer(isRecording: _isRecording),
                                GestureDetector(
                                  onTap: _onMicButtonPressed,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: _isRecording
                                          ? Colors.red
                                          : FrutiaColors.accent2,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isRecording
                                                  ? Colors.red
                                                  : FrutiaColors.accent)
                                              .withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.mic,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Botón de Detener/Cerrar
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade300,
                          child: IconButton(
                            icon: Icon(
                              _isSpeaking ? Icons.stop : Icons.close,
                              color: Colors.black54,
                              size: 30,
                            ),
                            onPressed:
                                _isSpeaking ? _stopAiSpeaking : _closeScreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _audioSessionSubscription?.cancel();
    _speech.cancel();
    _flutterTts.stop();
    _elevenLabsService.dispose();
    _thinkingAnimationController.dispose();
    _rhythmAnimationController.dispose();
    if (_hasVibrator) Vibration.cancel();
    super.dispose();
  }
}

// Los widgets ParticulasFlotantes, Particle y _ParticlesPainter no necesitan cambios
// y se pueden dejar como estaban en la versión anterior.
class ParticulasFlotantes extends StatefulWidget {
  const ParticulasFlotantes({Key? key}) : super(key: key);

  @override
  _ParticulasFlotantesState createState() => _ParticulasFlotantesState();
}

class _ParticulasFlotantesState extends State<ParticulasFlotantes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 2, // Tamaños más grandes
        speed: _random.nextDouble() * 0.3 + 0.1, // Velocidades más altas
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(_particles, _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class Particle {
  double x, y, size, speed;
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double time;

  _ParticlesPainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FrutiaColors.accent.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      final newY = (particle.y - time * particle.speed);
      final y = (newY < 0 ? 1.0 + newY : newY) * size.height;
      final x =
          (particle.x * size.width) + sin(time * 2 * pi * particle.speed) * 20;
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
