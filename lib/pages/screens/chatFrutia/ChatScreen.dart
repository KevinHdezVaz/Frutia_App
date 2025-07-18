import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/model/ChatMessage.dart';
import 'package:Frutia/pages/screens/chatFrutia/PermissionService.dart';
import 'package:Frutia/pages/screens/chatFrutia/VoiceChatScreen.dart';
import 'package:Frutia/pages/screens/chatFrutia/WaveVisualizer.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/pages/screens/miplan/PremiumScreen.dart';
import 'package:Frutia/services/ChatServiceApi.dart';
import 'package:Frutia/services/RachaProgreso.dart';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:clipboard/clipboard.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/painting.dart'
    as painting; // Import explícito para TextDirection

import 'dart:math';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart'; // Para Clipboard

class ChatScreen extends StatefulWidget {
  final String inputMode;
  final List<ChatMessage>? initialMessages;
  final int? sessionId;
  final String? initialMessage;

  const ChatScreen({
    Key? key,
    required this.inputMode,
    this.initialMessages,
    this.sessionId,
    this.initialMessage,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String _lastWords = '';
  String _transcribedText = '';
  bool _isTyping = false;
  int _typingIndex = 0;

  // --- NUEVAS VARIABLES DE ESTADO ---
  bool _isPremium = false;
  int _userMessageCount = 0;
  final int _messageLimit = 3;

  Timer? _typingTimer; // Nullable

  bool _isSpeechInitialized = false;
  AnimationController?
      _sunController; // Nullable  late Animation<double> _sunAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ChatServiceApi _chatService = ChatServiceApi();

  final Color frutia_background = Colors.white; // Un crema suave y cálido
  final Color frutia_accent =
      Color(0xFFFF8A65); // Durazno/Coral como acento principal
  final Color frutia_primary_text =
      Color(0xFF5D4037); // Marrón oscuro para texto

  // Colores mejorados para los bubbles
  final Color user_bubble_color = const Color.fromARGB(
      255, 236, 112, 67); // Color principal para el usuario

  final Color bot_bubble_color =
      FrutiaColors.accent; // Gris oscuro elegante para el bot

  final Color user_text_color =
      Colors.white; // Texto blanco para mejor contraste
  final Color bot_text_color = Colors.white; // Texto blanco también para el bot
  final Color time_text_color = Colors.white70; // Color más suave para la hora

  List<ChatMessage> _messages = [];
  int? _currentSessionId;
  bool _isSaved = false;
  String? _emotionalState;
  String? _conversationLevel;
  bool _initialMessageSent = false;

  double _soundLevel = 0.0; // Nueva variable para el nivel de sonido
  // Lógica para conteo de tokens y resumen
  final int _tokenLimit = 500;
  int _totalTokens = 0;

  List<TextSpan> _parseTextToSpans(String text) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(text)) {
      // Texto antes del match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: const TextStyle(
              color: Colors.black87,
              fontFamily: 'Lora',
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        );
      }

      // Texto en negrita
      spans.add(
        TextSpan(
          text: match.group(1), // El texto dentro de **
          style: const TextStyle(
            color: Colors.black87,
            fontFamily: 'Lora',
            fontSize: 15,
            height: 1.6,
            letterSpacing: 0.2,
            fontWeight: FontWeight.bold, // Negrita
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Texto restante después del último match
    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: const TextStyle(
            color: Colors.black87,
            fontFamily: 'Lora',
            fontSize: 15,
            height: 1.6,
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    return spans;
  }

  // --- NEW: GlobalKeys for the new showcase targets ---
  final GlobalKey _saveButtonKey = GlobalKey(debugLabel: 'saveButtonShowcase');
  final GlobalKey _micButtonKey = GlobalKey(debugLabel: 'micButtonShowcase');
  final GlobalKey _voiceChatButtonKey =
      GlobalKey(debugLabel: 'voiceChatButtonShowcase');

  bool _isCheckingPlan = true; // Empieza en true para mostrar el loader
  bool _hasActivePlan = false; // Determina si el usuario tiene un plan

  @override
  void initState() {
    super.initState();
    // En lugar de llamar a _checkUserPlanStatus, llamamos a una función más completa
    _initializeScreen();
  }

  // --- NUEVO WIDGET PAYWALL ---
  Widget _buildPaywall() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FrutiaColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FrutiaColors.accent, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline_rounded,
              color: FrutiaColors.accent, size: 40),
          const SizedBox(height: 12),
          Text(
            'Límite de mensajes alcanzado',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.primaryText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hazte premium para chatear con Frutia sin límites y acceder a todas las funciones.',
            style: GoogleFonts.lato(
                fontSize: 14, color: FrutiaColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FrutiaColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ver Planes Premium'),
          )
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildNoPlanWidget() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 80,
                color: FrutiaColors.accent.withOpacity(0.7),
              ),
              const SizedBox(height: 24),
              Text(
                'Crea tu Plan Primero',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: frutia_primary_text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Necesitas un plan de alimentación activo para poder chatear con Frutia y obtener consejos personalizados.',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: FrutiaColors.secondaryText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                    builder: (context) => const QuestionnaireFlow(),
                  ))
                      .then((_) {
                    setState(() {
                      _isCheckingPlan = true;
                    });
                    _checkUserPlanStatus();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrutiaColors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text(
                  'Crear Mi Plan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _navigateBack(context),
                child: const Text(
                  'Volver al inicio',
                  style: TextStyle(color: FrutiaColors.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatUI(BuildContext innerContext) {
    return Stack(
      children: [
        _FloatingParticles(),
        if (_isLoading && _messages.isEmpty)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
              strokeWidth: 6.0,
            ),
          )
        else
          Column(
            children: [
              AppBar(
                backgroundColor: FrutiaColors.accent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => _navigateBack(innerContext),
                ),
                actions: [
                  if (!_isSaved)
                    Showcase(
                      key: _saveButtonKey,
                      title: 'Guardar Chat',
                      description:
                          'Usa este botón para guardar la conversación, si no la guardas se perdera.',
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: TextButton.icon(
                          icon: const Icon(Icons.save,
                              color: Colors.white, size: 22),
                          label: const Text("Guardar Chat",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          onPressed: _saveChat,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == 0) {
                      return _buildTypingIndicator();
                    }
                    final messageIndex = _isTyping ? index - 1 : index;
                    return _buildMessageBubble(_messages[messageIndex]);
                  },
                ),
              ),
              _buildInput(),
            ],
          ),
      ],
    );
  }

  /// Inicializa toda la lógica del chat una vez que se confirma que hay un plan.
  void _initializeChat() {
    _messages = widget.initialMessages?.reversed.toList() ?? [];
    _currentSessionId = widget.sessionId;
    _isSaved = widget.sessionId != null;

    _initializeSpeech();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _isTyping) {
        setState(() => _typingIndex = (_typingIndex + 1) % 3);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _showShowcase();
        });
      }
    });

    if (!_initialMessageSent) {
      _initialMessageSent = true;
      if (_currentSessionId == null && _messages.isEmpty) {
        _startNewSession().then((_) {
          if (widget.initialMessage != null &&
              widget.initialMessage!.isNotEmpty) {
            _sendMessage(widget.initialMessage!);
          }
        });
      } else if (widget.initialMessage != null &&
          widget.initialMessage!.isNotEmpty) {
        _sendMessage(widget.initialMessage!);
      }
    }
  }

  /// Verifica si el usuario tiene un plan de comidas configurado.
  Future<void> _checkUserPlanStatus() async {
    try {
      // Reutilizamos el servicio que obtiene el perfil del usuario
      final responseData = await RachaProgresoService.getProgresoWithUser();
      if (!mounted) return;

      final profile = responseData['profile'];
      final bool planIsComplete = profile != null &&
          (profile['plan_setup_complete'] == true ||
              profile['plan_setup_complete'] == 1);

      setState(() {
        _hasActivePlan = planIsComplete;
        _isCheckingPlan = false; // Terminamos de verificar
      });

      // 2. Si el plan está completo, procedemos a inicializar el chat.
      if (planIsComplete) {
        _initializeChat();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingPlan = false; // Terminamos de verificar (con error)
          _hasActivePlan = false; // Asumimos que no tiene plan si hay error
        });
        _showErrorSnackBar('No se pudo verificar el estado de tu plan.');
      }
    }
  }

  Future<void> _showShowcase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Set this to false for testing, or true if you want it to show only once
      // Currently, it's always false, so it will show every time the screen loads
      final bool showcaseShown = prefs.getBool('chatShowcaseShown') ??
          false; // Leer de SharedPreferences
      if (!showcaseShown && !_isSaved && mounted) {
        // Collect all the keys you want to showcase in order
        final List<GlobalKey> keysToShow = [
          _saveButtonKey,
          _micButtonKey,
          _voiceChatButtonKey,
        ];

        // Ensure the ShowCaseWidget context is available before starting
        if (ShowCaseWidget.of(context).mounted) {
          ShowCaseWidget.of(context).startShowCase(keysToShow);
          await prefs.setBool('chatShowcaseShown', true);
        } else {
          debugPrint(
              'Showcase DEBUG: ShowCaseWidget is not mounted in context.');
        }
      } else {
        debugPrint(
            'Showcase DEBUG: Showcase conditions not met or already shown.');
      }
    } catch (e) {
      debugPrint('Error showing showcase: $e');
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        _showErrorSnackBar('Se requieren permisos de micrófono');
        return;
      }
      _isSpeechAvailable = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
      if (_isSpeechAvailable) {
        setState(() {
          _isSpeechInitialized = true;
        });
        // Lista los idiomas disponibles
        final locales = await _speech.locales();
        debugPrint(
            'Available locales: ${locales.map((l) => l.localeId).toList()}');
        debugPrint('Speech initialized successfully');
      } else {
        debugPrint('Speech initialization failed');
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      _showErrorSnackBar('Error initializing speech recognition');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialMessageSent) {
      _initialMessageSent = true;
      if (_currentSessionId == null && _messages.isEmpty) {
        _startNewSession().then((_) {
          if (widget.initialMessage != null &&
              widget.initialMessage!.isNotEmpty) {
            _sendMessage(widget.initialMessage!);
          }
        });
      } else if (widget.initialMessage != null &&
          widget.initialMessage!.isNotEmpty) {
        _sendMessage(widget.initialMessage!);
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _speech.cancel();
    _controller.dispose();
    if (_typingTimer?.isActive == true) {
      _typingTimer!.cancel();
    }
    if (_sunController?.isAnimating == true) {
      _sunController!.dispose();
    }
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  int _countTokens(String message) {
    return message.split(RegExp(r'\s+')).length;
  }

  void _updateTokenCount(String message) {
    final tokens = _countTokens(message);
    setState(() {
      _totalTokens += tokens;
    });
    if (_totalTokens > _tokenLimit) {}
  }

  void _startNewChatWithSummary(String summary) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          inputMode: widget.inputMode,
          initialMessage: summary,
        ),
      ),
    );
  }

  Future<bool> _isUserAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _startNewSession() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final isAuthenticated = await _isUserAuthenticated();
      if (!isAuthenticated) {
        print('User not authenticated, redirecting to login');
        _showErrorSnackBar('Por favor, inicia sesión para continuar');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthCheckMain()),
        );
        return;
      }

      final currentUser = await _storageService.getUser();
      final userName = currentUser?.name ?? 'Amigú';
      final response = await _chatService.startNewSession(userName: userName);

      if (!mounted) return;

      print('Start new session response: $response');

      if (response['session_id'] == null) {
        throw Exception('No session_id received from backend');
      }

      final aiMessage = ChatMessage(
        id: -1,
        chatSessionId: response['session_id'] ?? -1,
        userId: 0,
        text: response['ai_message']?['text'] ??
            'Error: No se recibió una respuesta válida.',
        isUser: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      setState(() {
        _currentSessionId = response['session_id'];
        _emotionalState =
            response['ai_message']['emotional_state'] ?? 'neutral';
        _conversationLevel =
            response['ai_message']['conversation_level'] ?? 'basic';
        _messages.insert(0, aiMessage);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Error starting new session: $e');
        _showErrorSnackBar('Error al iniciar la sesión: $e');
      }
    }
  }

  Future<void> _sendMessage(String message, {bool isTemporary = false}) async {
    if (message.trim().isEmpty) return;

    if (_currentSessionId == null && !isTemporary) {
      print('No session ID, starting new session');
      await _startNewSession();
      if (_currentSessionId == null) {
        _showErrorSnackBar('No se pudo iniciar la sesión. Inténtalo de nuevo.');
        return;
      }
    }

    final currentUser = await _storageService.getUser();
    final newMessage = ChatMessage(
      id: -1,
      chatSessionId: _currentSessionId ?? -1,
      userId: currentUser?.id ?? -1,
      text: message,
      isUser: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, newMessage);
      _isTyping = true;
      _typingIndex = 0;
      _typingTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (mounted) setState(() => _typingIndex = (_typingIndex + 1) % 3);
      });
      _updateTokenCount(newMessage.text);
    });
    _controller.clear();

    try {
      print('Sending message with session_id: $_currentSessionId');
      final response = isTemporary
          ? await _chatService.sendTemporaryMessage(
              message,
              userName: currentUser?.name ?? 'Amigú',
            )
          : await _chatService.sendMessage(
              message: message,
              sessionId: _currentSessionId,
              isTemporary: false,
              userName: currentUser?.name ?? 'Amigú',
            );

      if (!mounted) {
        return;
      }

      print('Received response: $response');
      final aiMessage = ChatMessage(
        id: -1,
        chatSessionId: response['session_id'] ?? _currentSessionId ?? -1,
        userId: 0,
        text: response['ai_message']['text'],
        isUser: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      setState(() {
        _messages.insert(0, aiMessage);
        _isTyping = false;
        _typingTimer!.cancel();
        if (!isTemporary && response['session_id'] != null) {
          _currentSessionId = response['session_id'];
        }
        _updateTokenCount(aiMessage.text);
      });

      Vibration.vibrate(duration: 200);
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isTyping = false;
        _typingTimer!.cancel();
      });
      print('Error sending message: $e');
      _showErrorSnackBar('Error al enviar el mensaje: $e');
    }
  }

  Future<void> _saveChat() async {
    if (_messages.isEmpty) {
      _showErrorSnackBar('noMessagesToSave'.tr());
      return;
    }

    final titleController = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Guardar Conversacion para despues",
            style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: titleController,
          autofocus: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: "Titulo",
            hintText: "Escribe titulo...",
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Color(0xFFF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF4BB6A8), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4BB6A8)),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                Navigator.pop(context, titleController.text.trim());
              }
            },
            child: Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    try {
      final session = await _chatService.saveChatSession(
        title: title,
        messages: _messages.reversed
            .map((m) => {
                  'text': m.text,
                  'is_user': m.isUser,
                  'created_at': m.createdAt.toIso8601String(),
                })
            .toList(),
        sessionId: _currentSessionId,
      );

      if (!mounted) return;

      setState(() {
        _isSaved = true;
        _currentSessionId = session.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chat guardado corrrectamente"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('errorSavingChat'.tr(args: [e.toString()]));
    }
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    final permissionService = PermissionService();
    final micStatus =
        await permissionService.checkOrRequest(Permission.microphone);
    debugPrint('Microphone permission status: $micStatus');

    if (!micStatus.isGranted) {
      if (micStatus.isPermanentlyDenied) {
        _showErrorSnackBar(
            'Por favor habilita los permisos de micrófono en Configuración');
        await openAppSettings();
      }
      return;
    }

    if (!_isSpeechInitialized || !_isSpeechAvailable) {
      _showErrorSnackBar('El reconocimiento de voz no está disponible');
      await _initializeSpeech();
      if (!_isSpeechInitialized || !_isSpeechAvailable) {
        return;
      }
    }

    try {
      setState(() {
        _isListening = true;
        _controller.clear();
      });

      const localeId = 'es_ES'; // Valor fijo para español (España)
      debugPrint('Starting speech recognition with locale: $localeId');

      await _speech.listen(
        onResult: (result) {
          debugPrint('Recognized words: ${result.recognizedWords}');
          setState(() {
            _controller.text = result.recognizedWords;
            _controller.selection = TextSelection.collapsed(
              offset: _controller.text.length,
            );
          });
        },
        localeId: localeId,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: (level) {
          debugPrint('Sound level: $level');
          setState(() {
            _soundLevel = level;
          });
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Error starting speech recognition: $e\n$stackTrace');
      setState(() => _isListening = false);
      _showErrorSnackBar('Error al iniciar: $e');
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
      });
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
      });
      _showErrorSnackBar('Error al detener: $e');
    }
  }

  Widget _buildVoiceVisualizer() {
    if (!_isListening) return const SizedBox.shrink();
    return WaveVisualizer(
      soundLevel: _soundLevel,
      primaryColor: Colors.grey,
      secondaryColor: Colors.black, // e.g., Color(0xFF88D5C2)
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final time = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              FlutterClipboard.copy(message.text).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Texto copiado'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              });
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: PhysicalModel(
                color: Colors.transparent,
                elevation: 2,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isUser ? 16 : 4),
                  topRight: Radius.circular(message.isUser ? 4 : 16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        message.isUser ? user_bubble_color : bot_bubble_color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(message.isUser ? 16 : 4),
                      topRight: Radius.circular(message.isUser ? 4 : 16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: message.isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (message.imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              message.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      SelectableText.rich(
                        TextSpan(
                          children: _parseTextToSpans(message.text).map((span) {
                            return TextSpan(
                              text: span.text,
                              style: span.style?.copyWith(
                                    color: message.isUser
                                        ? user_text_color
                                        : bot_text_color,
                                  ) ??
                                  TextStyle(
                                    color: message.isUser
                                        ? user_text_color
                                        : bot_text_color,
                                  ),
                            );
                          }).toList(),
                        ),
                        textAlign:
                            message.isUser ? TextAlign.end : TextAlign.start,
                        style: TextStyle(
                          color:
                              message.isUser ? user_text_color : bot_text_color,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: time_text_color,
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmotionalStateText(String? state) {
    switch (state) {
      case 'sensitive':
        return 'sensitiveState'.tr();
      case 'crisis':
        return 'crisisState'.tr();
      default:
        return 'neutralState'.tr();
    }
  }

  String _getConversationLevelText(String? level) {
    switch (level) {
      case 'advanced':
        return 'advancedLevel'.tr();
      default:
        return 'basicLevel'.tr();
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ChatBubble(
        clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 5),
        backGroundColor: Colors.white.withOpacity(0.8),
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _typingIndex ? Colors.red : Colors.grey,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _initializeScreen() async {
    setState(() {
      _isCheckingPlan = true;
    });
    try {
      final responseData = await RachaProgresoService.getProgresoWithUser();
      if (!mounted) return;

      final user = responseData['user'];
      final profile = responseData['profile'];

      final bool planIsComplete = profile != null &&
          (profile['plan_setup_complete'] == true ||
              profile['plan_setup_complete'] == 1);

      setState(() {
        _hasActivePlan = planIsComplete;
        _isPremium = user?['subscription_status'] == 'active';
        _userMessageCount = user?['message_count'] ?? 0;
        _isCheckingPlan = false;
      });

      if (planIsComplete) {
        _initializeChat();
      }
    } catch (e) {
      // ... (tu manejo de errores)
    }
  }

  Widget _buildInput() {
    // Si el usuario no es premium y ha alcanzado el límite, muestra el paywall.
    if (!_isPremium && _userMessageCount >= _messageLimit) {
      return _buildPaywall();
    }

    // De lo contrario, muestra el input normal.
    switch (widget.inputMode) {
      case 'keyboard':
        return _buildKeyboardInput();
      case 'voice':
        return _buildVoiceInput();
      default:
        return _buildKeyboardInput();
    }
  }

  void _navigateBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AuthCheckMain(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var slideAnimation = animation.drive(tween);
          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBack(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: frutia_background,
        body: Builder(
          builder: (innerContext) {
            if (_isCheckingPlan) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
                ),
              );
            }

            if (!_hasActivePlan) {
              return _buildNoPlanWidget();
            }

            return _buildChatUI(innerContext);
          },
        ),
      ),
    );
  }

  Widget _buildKeyboardInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (_isListening) _buildVoiceVisualizer(),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: _controller.text.isEmpty ? ' ' : _controller.text,
                  style: const TextStyle(fontSize: 16, fontFamily: 'Lora'),
                ),
                maxLines: null,
                textDirection: painting.TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth - 80);

              final lineCount = textPainter.computeLineMetrics().length;
              final baseHeight = 60.0;
              final lineHeight = 20.0;
              final calculatedHeight =
                  baseHeight + (lineCount - 1) * lineHeight;
              final textFieldHeight = calculatedHeight.clamp(baseHeight, 200.0);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: textFieldHeight,
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Escribe tu mensaje...",
                    hintStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- SHOWCASE FOR MIC ICON ---
                        Showcase(
                          key: _micButtonKey,
                          title: 'Entrada de Voz',
                          description:
                              'Si no qiueres escribir, puedes tocar aqui para grabar tu mensaje o detener la grabación.',
                          tooltipBackgroundColor: FrutiaColors.accent,
                          targetShapeBorder: const CircleBorder(),
                          titleTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          descTextStyle: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          disableMovingAnimation: true,
                          disableScaleAnimation: true,
                          child: IconButton(
                            icon: Icon(
                              _isListening ? Icons.stop_circle : Icons.mic_none,
                              color: _isListening
                                  ? Colors.red
                                  : FrutiaColors.accent,
                              size: _isListening ? 30 : 24,
                            ),
                            tooltip: _isListening
                                ? 'Detener grabación'
                                : 'Iniciar grabación',
                            onPressed: () async {
                              if (_isListening) {
                                await _stopListening();
                              } else {
                                await _startListening();
                              }
                            },
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.send, color: FrutiaColors.accent),
                            onPressed: () {
                              _sendMessage(_controller.text);
                              _controller.clear();
                              // Ocultar el teclado
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          ),
                        if (_controller.text.isEmpty)
                          // --- SHOWCASE FOR VOICE CHAT ICON ---
                          Showcase(
                            key: _voiceChatButtonKey,
                            title: 'Chat de Voz Avanzado',
                            description:
                                'Inicia una conversación de voz fluida con la IA.',
                            tooltipBackgroundColor: FrutiaColors.accent,
                            targetShapeBorder: const CircleBorder(),
                            titleTextStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            descTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            disableMovingAnimation: true,
                            disableScaleAnimation: true,
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.record_voice_over,
                                  color: FrutiaColors.accent,
                                  size: 22,
                                ),
                                tooltip: 'Chat de voz avanzado',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VoiceChatScreen(language: "es"),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {}); // Reconstruir para actualizar la altura
                  },
                  scrollController: ScrollController(),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildVoiceInput() {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: () async {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? Colors.red.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: _isListening
                        ? Colors.red.withOpacity(0.4)
                        : Colors.white.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 30,
                color: _isListening ? Colors.white : Colors.black54,
              ),
            ),
          ),
        ),
        if (_controller.text
            .isNotEmpty) // Usa _controller.text en lugar de _transcribedText
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              _controller.text,
              style: TextStyle(color: Colors.black87, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _FloatingParticles extends StatefulWidget {
  @override
  __FloatingParticlesState createState() => __FloatingParticlesState();
}

class __FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 10), // Reducido para movimiento más rápido
    )..repeat();

    // Generar partículas con velocidades más visibles
    for (int i = 0; i < 20; i++) {
      // Aumentar número de partículas
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
          size: Size.infinite,
          painter: _ParticlesPainter(_particles, _controller.value),
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
      ..color = FrutiaColors.accent
          .withOpacity(0.2) // Aumentar opacidad para mejor visibilidad
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
