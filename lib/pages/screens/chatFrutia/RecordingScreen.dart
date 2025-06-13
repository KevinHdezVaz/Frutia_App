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
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';

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
  String _partialTranscription = '';
  String _aiResponse = '';
  String _statusMessage = 'Preparando chat de voz...';
  String _emotionalState = 'neutral';
  String _conversationLevel = 'basic';
  bool _hasVibrator = false;
  double _soundLevel = 0.0;
  double _smoothedSoundLevel = 0.0;
  Timer? _silenceTimer;
  final int _silenceTimeout = 5000;
  bool _showListeningIndicator = false;

  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseScale;
  late AnimationController _thinkingAnimationController;
  late AnimationController _rhythmAnimationController;
  late Animation<double> _rhythmValue;

  StreamSubscription<AudioInterruptionEvent>? _audioSessionSubscription;

  int _countdown = 5; // Contador regresivo inicial
  bool _isCountingDown = true; // Estado del contador
  bool _isPaused = false; // Estado de pausa
  Timer? _countdownTimer; // Timer para el contador

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _elevenLabsService = ElevenLabsService(
      apiKey: "sk_5c7014c450eb767dbc8cd3ca2cdadadaceb4dbc52708cac9",
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 130.0, end: 200.0).animate(
      CurvedAnimation(
          parent: _pulseAnimationController, curve: Curves.easeInOut),
    );

    _thinkingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _rhythmAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _rhythmValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _rhythmAnimationController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _rhythmAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _rhythmAnimationController.forward();
        }
      });

    _initTts();
    _initVibration();
    _configureAudioSession().then((_) {
      _checkPermissionsBeforeRecording();
    });
  }

  Future<void> _configureAudioSession() async {
    if (Platform.isIOS) {
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
            _stopRecording();
          } else {
            _startRecording();
          }
        });
      } catch (e) {
        debugPrint('Error configuring audio session: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _checkPermissionsBeforeRecording() async {
    final permissionService = PermissionService();
    final micStatus =
        await permissionService.checkOrRequest(Permission.microphone);

    if (!micStatus.isGranted) {
      if (micStatus.isPermanentlyDenied && mounted) {
        _showErrorSnackBar(
            'Por favor habilita los permisos de micrófono en Configuración');
        await openAppSettings();
        return;
      }
    }

    if (mounted && micStatus.isGranted) {
      setState(() {
        _statusMessage = 'El chat de voz empezará en $_countdown segundos';
        _startCountdown();
      });
    }
  }

  Future<void> _initTts() async {
    _elevenLabsService.setOnComplete(() => _handleAudioCompletion());

    final languageMap = {
      'es': 'es-ES',
      'en': 'en-US',
      'fr': 'fr-FR',
      'pt': 'pt-BR',
    };

    final ttsLanguage = languageMap[widget.language] ?? 'es-ES';
    await _flutterTts.setLanguage(ttsLanguage);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.1);
    _flutterTts.setCompletionHandler(() => _handleAudioCompletion());
  }

  void _handleAudioCompletion() {
    if (!mounted) return;

    setState(() {
      _isSpeaking = false;
      _isProcessing = false;
      _statusMessage = 'listening'.tr();
      _showListeningIndicator = true;
      _pulseAnimationController.forward();
      _thinkingAnimationController.stop();
      _rhythmAnimationController.stop();

      if (_hasVibrator) Vibration.cancel();

      // No iniciar automáticamente, esperar al usuario
    });
  }

  Future<void> _initVibration() async {
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      setState(() => _hasVibrator = hasVibrator ?? false);
    } catch (e) {
      setState(() => _hasVibrator = false);
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording || _isSpeaking) return;

    if (Platform.isIOS) {
      try {
        final session = await AudioSession.instance;
        final micStatus = await Permission.microphone.status;
        if (!micStatus.isGranted) {
          final status = await Permission.microphone.request();
          if (!status.isGranted) {
            if (mounted) {
              _showErrorSnackBar('Se requieren permisos de micrófono');
              if (status.isPermanentlyDenied) {
                await openAppSettings();
              }
            }
            return;
          }
        }

        if (!await session.setActive(true)) {
          if (mounted) {
            _showErrorSnackBar(
                'El micrófono está siendo usado por otra aplicación');
          }
          return;
        }
      } catch (e) {
        debugPrint('Error checking iOS microphone: $e');
        return;
      }
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {
            _statusMessage = 'listening'.tr();
            _showListeningIndicator = true;
          });
        }
      },
      onError: (error) => _handleRecordingError(error.errorMsg),
    );

    if (available) {
      final localeId = {
            'es': 'es_ES',
            'en': 'en_US',
            'fr': 'fr_FR',
            'pt': 'pt_BR'
          }[widget.language] ??
          'es_ES';

      _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty && mounted) {
            setState(() {
              _partialTranscription = result.recognizedWords;
              _showListeningIndicator = true;
            });
            _resetSilenceTimer();
            _pulseAnimationController.forward();
          }
        },
        onSoundLevelChange: (level) {
          if (_isRecording && mounted) {
            final newLevel = ((level + 160) / 160).clamp(0.0, 1.0);
            setState(() {
              _soundLevel = newLevel;
              _smoothedSoundLevel =
                  lerpDouble(_smoothedSoundLevel, _soundLevel, 0.1)!;
              if (newLevel > 0.1) {
                _showListeningIndicator = true;
                _resetSilenceTimer();
              }
            });
          }
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        partialResults: true,
      );

      if (mounted) {
        setState(() {
          _isRecording = true;
          _statusMessage = 'listening'.tr();
          _showListeningIndicator = true;
          _pulseAnimationController.forward();
        });
      }
      _startSilenceTimer();
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _startSilenceTimer();
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(Duration(milliseconds: _silenceTimeout), () {
      if (_isRecording && mounted) {
        setState(() => _showListeningIndicator = false);
        _stopRecording();
      }
    });
  }

  void _handleRecordingError(String errorMsg) {
    if (!mounted) return;
    setState(() {
      _statusMessage = 'error'.tr() + errorMsg;
      _isRecording = false;
      _isProcessing = false;
      _soundLevel = 0.0;
      _smoothedSoundLevel = 0.0;
      _pulseAnimationController.stop();
      _thinkingAnimationController.stop();
      if (_hasVibrator) Vibration.cancel();
    });
    if (!errorMsg.toLowerCase().contains('permission')) {
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) _startRecording();
      });
    }
  }

  Future<void> _stopRecording() async {
    _silenceTimer?.cancel();
    await _speech.stop();
    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _statusMessage = 'Procesando...';
      _showListeningIndicator = true;
      _pulseAnimationController.stop();
      _thinkingAnimationController.forward();
    });

    if (_partialTranscription.isNotEmpty) {
      await _processTranscription();
    } else {
      setState(() {
        _statusMessage = 'no_speech_detected'.tr();
        _isProcessing = false;
        _startRecording(); // Reiniciar solo si el usuario lo activa manualmente
      });
    }
  }

  Future<void> _processTranscription() async {
    try {
      final response = await widget.chatService.sendVoiceMessage(
        message: _partialTranscription,
        sessionId: null,
      );

      if (mounted) {
        setState(() {
          _aiResponse = response['ai_message']['text'];
          _emotionalState =
              response['ai_message']['emotional_state'] ?? 'neutral';
          _conversationLevel =
              response['ai_message']['conversation_level'] ?? 'basic';
          _statusMessage = 'Hablando IA...';
          _isSpeaking = true;
          _isProcessing = false;
          _showListeningIndicator = true;
          _thinkingAnimationController.forward();
          _rhythmAnimationController.forward();

          if (_hasVibrator) {
            Vibration.cancel();
            Vibration.vibrate(pattern: [1000, 100, 1000, 100], repeat: -1);
          }
        });
      }

      try {
        await _elevenLabsService.speak(
          _aiResponse,
          'pFZP5JQG7iQjIQuC4Bku',
          widget.language,
        );
      } catch (e) {
        await _flutterTts.speak(_aiResponse);
      }
    } catch (e) {
      _handleRecordingError(e.toString());
      // No reiniciar automáticamente, esperar al usuario
    }
  }

  void _closeScreen() {
    _silenceTimer?.cancel();
    _speech.stop();
    _flutterTts.stop();
    _elevenLabsService.stop();
    _pulseAnimationController.stop();
    _thinkingAnimationController.stop();
    _rhythmAnimationController.stop();
    if (_hasVibrator) Vibration.cancel();

    Navigator.pop(context, {
      'transcription': _partialTranscription,
      'ai_response': _aiResponse,
      'emotional_state': _emotionalState,
      'conversation_level': _conversationLevel,
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (!_isPaused && _countdown > 0) {
          setState(() {
            _countdown--;
            _statusMessage = 'El chat de voz empezará en $_countdown segundos';
          });
        } else if (_countdown == 0) {
          _countdownTimer?.cancel();
          _startRecording();
        }
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      _statusMessage =
          _isPaused ? 'Pausado. Toca "Iniciar" para continuar' : 'Reanudando...';
    });
    if (!_isPaused && _countdown > 0) {
      _startCountdown(); // Reanudar el conteo si se despausa
    }
  }

  void _startRecordingManually() {
    _countdownTimer?.cancel();
    _startRecording();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopRecording();
      if (Platform.isIOS) {
        AudioSession.instance.then((session) => session.setActive(false));
      }
    } else if (state == AppLifecycleState.resumed) {
      if (Platform.isIOS) {
        AudioSession.instance.then((session) => session.setActive(true));
      }
      // No reiniciar automáticamente, esperar al usuario
    }
  }

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
    appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [  FrutiaColors.accent, FrutiaColors.accent2],
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
        iconTheme: IconThemeData(color: Colors.black),
        
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
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text(
                          _statusMessage,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isProcessing
                          ? Lottie.asset(
                              'assets/animations/animacioncirculo.json',
                              width: 250,
                              height: 250,
                              controller: _thinkingAnimationController,
                            )
                          : AnimatedBuilder(
                              animation: _pulseScale,
                              builder: (context, child) {
                                return Container(
                                  width: _pulseScale.value,
                                  height: _pulseScale.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFFE5B4).withOpacity(0.7),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isCountingDown)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_countdown',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _togglePause,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isPaused ? Colors.green : Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: Text(
                                _isPaused ? 'Reanudar' : 'Pausar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (!_isCountingDown)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blueGrey,
                              child: IconButton(
                                icon: Icon(Icons.mic, color: Colors.white, size: 35),
                                onPressed: _startRecordingManually,
                              ),
                            ),
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blueGrey,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white, size: 35),
                                onPressed: _closeScreen,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _countdownTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _audioSessionSubscription?.cancel();

    if (Platform.isIOS) {
      AudioSession.instance.then((session) {
        session.setActive(false);
      });
    }

    _speech.stop();
    _flutterTts.stop();
    _elevenLabsService.dispose();
    _pulseAnimationController.dispose();
    _thinkingAnimationController.dispose();
    _rhythmAnimationController.dispose();

    if (_hasVibrator) Vibration.cancel();

    super.dispose();
  }
}

class ParticulasFlotantes extends StatefulWidget {
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
      duration: const Duration(seconds: 30),
    )..repeat();

    for (int i = 0; i < 10; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2 + 1,
        speed: _random.nextDouble() * 0.15 + 0.05,
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
        return SizedBox.expand(
          child: CustomPaint(
            painter: _ParticlesPainter(_particles, _controller.value),
          ),
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
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      final x = (particle.x + time * particle.speed) % 1.0 * size.width;
      final y = (particle.y + time * particle.speed * 0.5) % 1.0 * size.height;
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}