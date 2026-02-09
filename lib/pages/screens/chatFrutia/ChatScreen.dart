import 'dart:convert';
import 'dart:io';

import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/l10n/app_localizations.dart';
import 'package:Frutia/model/ChatMessage.dart';
import 'package:Frutia/model/ChatSession.dart';
import 'package:Frutia/pages/screens/chatFrutia/PermissionService.dart';
import 'package:Frutia/pages/screens/chatFrutia/VoiceChatScreen.dart';
import 'package:Frutia/pages/screens/chatFrutia/WaveVisualizer.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/pages/screens/miplan/PremiumScreen.dart';
import 'package:Frutia/services/ChatServiceApi.dart';
import 'package:Frutia/services/RachaProgreso.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:http/http.dart' as http;

import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:clipboard/clipboard.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/painting.dart'
    as painting; // Import explícito para TextDirection

import 'dart:math';
import 'dart:async';
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
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String _lastWords = '';
  String _transcribedText = '';
  bool _isTyping = false;
  int _typingIndex = 0;
  File? _stagedImageFile; // Guardará la imagen que está lista para ser enviada

  // --- NUEVAS VARIABLES DE ESTADO ---
  bool _isPremium = false;
  int _userMessageCount = 0;
  final int _messageLimit = 3;

  Timer? _typingTimer; // Nullable
  final ImagePicker _picker = ImagePicker();

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
  final Color bot_text_color = Colors.white;
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

  List<TextSpan> _parseTextToSpans(String text, Color textColor) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(
              color: textColor, // Usar el color pasado
              fontFamily: 'Lora',
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: textColor, // Usar el color pasado
            fontFamily: 'Lora',
            fontSize: 15,
            height: 1.6,
            letterSpacing: 0.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      lastIndex = match.end;
    }
    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(
            color: textColor, // Usar el color pasado
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
    _initialMessageSent = false;

    _initializeScreen();
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
        debugPrint('✅ Plan activo encontrado, inicializando chat...');
        _initializeChat();
      } else {
        debugPrint('⚠️ Usuario sin plan activo');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingPlan = false;
          _hasActivePlan = false;
        });
        debugPrint('❌ Error en _initializeScreen: $e');
        _showErrorSnackBar(l10n.errorVerifyingPlan); // ⭐ CAMBIADO
      }
    }
  }

  // En: lib/pages/screens/chatFrutia/ChatScreen.dart -> _ChatScreenState

  Future<void> _performBodyAnalysis() async {
    // 1. Abrir la galería para que el usuario elija una imagen.
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Opcional: comprime un poco la imagen
    );

    // Si el usuario cancela la selección, no hacemos nada.
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    // ▼▼▼ CAMBIOS CLAVE SIN DIÁLOGO ▼▼▼
    // 2. Capturar el texto que ya está escrito en el TextField.
    final String userText = _controller.text;

    // 3. Limpiar el TextField y ocultar el teclado para una mejor experiencia.
    _controller.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    // ▲▲▲ FIN DE LOS CAMBIOS ▲▲▲

    // 4. Crear el mensaje del usuario que contiene AMBOS, la imagen y el texto.
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      chatSessionId: _currentSessionId ?? -1,
      isUser: true,
      imagePath: imageFile.path,
      text: userText.isNotEmpty ? userText : null, // Guarda el texto capturado
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    setState(() {
      _messages.insert(0, userMessage);
      _isTyping = true;
    });

    // 5. Llamar al servicio, pasándole ambos datos.
    try {
      final analysisResult = await _chatService.analyzeBodyImage(
        imageFile,
        text: userText, // Pasamos el texto al servicio
      );

      // El resto de la lógica para manejar la respuesta exitosa no cambia.
      final assistantResponseMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        chatSessionId: _currentSessionId ?? -1,
        isUser: false,
        analysisData: analysisResult,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      setState(() {
        _messages.insert(0, assistantResponseMessage);
      });
    } catch (e) {
      // El manejo de errores tampoco cambia.
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        chatSessionId: _currentSessionId ?? -1,
        isUser: false,
        text: 'Lo siento, no pude analizar la imagen. Inténtalo de nuevo. 😥',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, errorMessage);
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      // Leer la imagen como bytes y convertir a base64
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Obtener el usuario actual
      final currentUser = await _storageService.getUser();

      // Llamar al backend para análisis
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-body-fat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'user_id': currentUser?.id,
          'session_id': _currentSessionId,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Crear mensaje con la imagen
        final imageMessage = ChatMessage(
          id: -1,
          chatSessionId: _currentSessionId ?? -1,
          userId: currentUser?.id ?? -1,
          imagePath: pickedFile.path,
          isUser: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Crear mensaje con los resultados
        final analysisMessage = ChatMessage(
          id: -1,
          chatSessionId: _currentSessionId ?? -1,
          userId: 0, // ID del bot
          text: data['analysis'],
          isUser: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        setState(() {
          _messages.insert(0, analysisMessage);
          _messages.insert(0, imageMessage);
          _isLoading = false;
        });
      } else {
        throw Exception('Error al analizar la imagen');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  // ▼▼▼ NUEVO: Función para manejar el envío de mensajes con imagen ▼▼▼
  Future<void> _sendImageMessage(String imagePath) async {
    final currentUser = await _storageService.getUser();
    final newMessage = ChatMessage(
      id: -1,
      chatSessionId: _currentSessionId ?? -1,
      userId: currentUser?.id ?? -1,
      imagePath: imagePath, // Usamos el nuevo campo
      isUser: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, newMessage);
      _isTyping = true;
    });

    // Aquí iría la lógica para subir la imagen a tu backend
    // y obtener una respuesta del modelo de IA sobre la imagen.
    // Por ahora, simulamos una respuesta después de 2 segundos.
    await Future.delayed(const Duration(seconds: 2));

    final aiResponse = ChatMessage(
      id: -1,
      chatSessionId: _currentSessionId ?? -1,
      userId: 0,
      text: "¡Qué buena foto! Analizándola...",
      isUser: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, aiResponse);
      _isTyping = false;
    });
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
            l10n.messageLimit, // ⭐ CAMBIADO
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.primaryText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.messageLimitDesc, // ⭐ CAMBIADO

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
            child: Text(l10n.viewPremiumPlans), // ⭐ CAMBIADO
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
                l10n.createPlanFirst, // ⭐ CAMBIADO
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: frutia_primary_text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.needActivePlan, // ⭐ CAMBIADO
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
                    // ✅ CORRECTO: Usar _initializeScreen
                    _initializeScreen();
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
                label: Text(
                  l10n.createMyPlan, // ⭐ CAMBIADO
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _navigateBack(context),
                child: Text(
                  l10n.backToHome, // ⭐ CAMBIADO
                  style: TextStyle(color: FrutiaColors.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// En tu archivo ChatScreen.dart -> _ChatScreenState

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
              // ▼▼▼ APPBAR ACTUALIZADA CON EL DISEÑO QUE PREFIERES ▼▼▼
              AppBar(
                backgroundColor: FrutiaColors.accent,
                elevation: 2,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => _navigateBack(innerContext),
                ),

                // Título con Avatar y subtítulo de mensajes restantes
                title: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        'F',
                        style: TextStyle(
                            color: FrutiaColors.accent,
                            fontWeight: FontWeight.bold),
                      ),
                      radius: 18,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.chatTitle, // ⭐ CAMBIADO

                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isPremium)
                          Text(
                            '${max(0, _messageLimit - _userMessageCount)} ${l10n.messagesRemaining}', // ⭐ CAMBIADO
                            style: GoogleFonts.lato(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Botón de "Guardar Chat" visible directamente
                actions: [
                  if (!_isSaved)
                    Showcase(
                      key: _saveButtonKey,
                      title: l10n.saveShowcaseTitle, // ⭐ CAMBIADO
                      description: l10n.saveShowcaseDesc, // ⭐ CAMBIADO
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: TextButton.icon(
                          icon: const Icon(Icons.save,
                              color: Colors.white, size: 22),
                          label: Text(l10n.saveChat, // ⭐ CAMBIADO
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
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  behavior: HitTestBehavior
                      .opaque, // Esto hace que todo el área sea tappable
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
              ),
              _buildInput(),
            ],
          ),
      ],
    );
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

// ❌ BORRAR TODO ESTO:
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
    _loadingTextTimer?.cancel(); // ⬅️ AGREGAR ESTO

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
        debugPrint('❌ User not authenticated, redirecting to login');
        _showErrorSnackBar(l10n.pleaseLogin); // ⭐ CAMBIADO
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthCheckMain()),
        );
        return;
      }

      final currentUser = await _storageService.getUser();
      final userName = currentUser?.name ?? 'Amigú';

      debugPrint('📤 Creando nueva sesión para: $userName');

      final response = await _chatService.startNewSession(userName: userName);

      if (!mounted) return;

      debugPrint('📥 Respuesta de nueva sesión: $response');

      if (response['session_id'] == null) {
        throw Exception('No session_id received from backend');
      }

      setState(() {
        _currentSessionId = response['session_id'];
        _isLoading = false;
      });

      debugPrint('✅ Sesión iniciada correctamente: $_currentSessionId');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('❌ Error starting new session: $e');
        _showErrorSnackBar('${l10n.errorStartingSession}: $e'); // ⭐ CAMBIADO
      }
    }
  }

  Future<void> _sendMessage(String message, {bool isTemporary = false}) async {
    if (message.trim().isEmpty) return;

    // ⭐ CAMBIO CLAVE: Crear sesión SOLO si no existe
    if (_currentSessionId == null && !isTemporary) {
      debugPrint('⚠️ Primer mensaje, creando sesión...');
      await _startNewSession();

      if (_currentSessionId == null) {
        _showErrorSnackBar('No se pudo iniciar la sesión. Inténtalo de nuevo.');
        return;
      }

      debugPrint('✅ Nueva sesión creada: $_currentSessionId');
    } else if (_currentSessionId != null) {
      debugPrint('✅ Usando sesión existente: $_currentSessionId');
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
      _startLoadingTextAnimation();
      _typingTimer?.cancel();
      _typingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (mounted) setState(() => _typingIndex = (_typingIndex + 1) % 3);
      });
      _updateTokenCount(newMessage.text!);
    });
    _controller.clear();

    try {
      debugPrint('📤 Enviando mensaje con session_id: $_currentSessionId');

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

      if (!mounted) return;

      debugPrint('📥 Respuesta recibida: $response');

      // ⭐ IMPORTANTE: NO cambiar session_id si ya existe
      if (_currentSessionId == null && response['session_id'] != null) {
        debugPrint('✅ Asignando session_id: ${response['session_id']}');
        setState(() {
          _currentSessionId = response['session_id'];
        });
      } else if (response['session_id'] != _currentSessionId) {
        debugPrint(
            '⚠️ Backend devolvió session_id diferente: ${response['session_id']} vs $_currentSessionId');
        // NO cambiar el session_id local
      }

      final aiMessage = ChatMessage(
        id: response['ai_message']['id'] ?? -1,
        chatSessionId: _currentSessionId ?? -1,
        userId: 0,
        text: response['ai_message']['text'],
        isUser: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      setState(() {
        _messages.insert(0, aiMessage);
        _isTyping = false;
        _typingTimer?.cancel();
        _stopLoadingTextAnimation();

        if (response['user_message_count'] != null) {
          _userMessageCount = response['user_message_count'];
        }

        _updateTokenCount(aiMessage.text!);
      });

      // ⭐ Auto-guardar después del primer mensaje
      if (!isTemporary && _currentSessionId != null) {
        await _autoSaveChat();
      }

      Vibration.vibrate(duration: 200);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _typingTimer?.cancel();
        _stopLoadingTextAnimation();
      });
      debugPrint('❌ Error sending message: $e');
      _showErrorSnackBar('Error al enviar el mensaje: $e');
    }
  }

// ⭐ MÉTODO SIMPLIFICADO: Solo marcar como guardado
  Future<void> _autoSaveChat() async {
    if (_currentSessionId == null) return;

    // Si ya está guardado, no hacer nada
    if (_isSaved) return;

    try {
      debugPrint(
          '💾 Marcando sesión como guardada (Session: $_currentSessionId)...');

      // Generar título automático
      final title = _generateAutoTitle();

      // Solo actualizar el flag is_saved y el título
      await _chatService.markSessionAsSaved(_currentSessionId!, title);

      if (mounted) {
        setState(() {
          _isSaved = true;
        });
      }

      debugPrint('✅ Sesión marcada como guardada');
    } catch (e) {
      debugPrint('❌ Error al marcar sesión: $e');
    }
  }

  String _generateAutoTitle() {
    if (_messages.isEmpty) return l10n.newConversationTitle; // ⭐ CAMBIADO

    final firstUserMessage = _messages.reversed.firstWhere(
      (m) => m.isUser && m.text != null && m.text!.trim().isNotEmpty,
      orElse: () => _messages.last,
    );

    if (firstUserMessage.text == null)
      return l10n.newConversationTitle; // ⭐ CAMBIADO

    final title = firstUserMessage.text!.length > 40
        ? '${firstUserMessage.text!.substring(0, 40)}...'
        : firstUserMessage.text!;

    return title;
  }

  Future<void> _saveChat() async {
    if (_messages.isEmpty) {
      _showErrorSnackBar(l10n.noMessagesToSave); // ⭐ CAMBIADO
      return;
    }

    final titleController = TextEditingController();

    if (_isSaved) {
      try {
        final sessions = await _chatService.getSessions(saved: true);
        final currentSession = sessions.firstWhere(
          (s) => s.id == _currentSessionId,
          orElse: () => ChatSession(
            id: _currentSessionId!,
            userId: 0,
            title: _generateAutoTitle(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isSaved: true,
          ),
        );
        titleController.text = currentSession.title;
      } catch (e) {
        debugPrint('Error obteniendo título actual: $e');
      }
    }

    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _isSaved ? l10n.changeTitle : l10n.saveConversation, // ⭐ CAMBIADO
          style: TextStyle(color: Colors.black),
        ),
        content: TextField(
          controller: titleController,
          autofocus: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: l10n.titleLabel, // ⭐ CAMBIADO
            hintText: l10n.titleHint, // ⭐ CAMBIADO
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
            child: Text(l10n.cancel,
                style: TextStyle(color: Colors.black)), // ⭐ CAMBIADO
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4BB6A8)),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                Navigator.pop(context, titleController.text.trim());
              }
            },
            child: Text(l10n.save,
                style: TextStyle(color: Colors.white)), // ⭐ CAMBIADO
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    try {
      await _chatService.saveChatSession(
        title: title,
        messages: _messages.reversed
            .map((m) => {
                  'text': m.text,
                  'is_user': m.isUser,
                  'image_url': m.imageUrl,
                  'created_at': m.createdAt.toIso8601String(),
                })
            .toList(),
        sessionId: _currentSessionId,
      );

      if (!mounted) return;

      setState(() {
        _isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chatSaved), // ⭐ CAMBIADO
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('${l10n.errorSavingChat}: $e'); // ⭐ CAMBIADO
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
        _showErrorSnackBar(l10n.enableMicPermission); // ⭐ CAMBIADO

        await openAppSettings();
      }
      return;
    }

    if (!_isSpeechInitialized || !_isSpeechAvailable) {
      _showErrorSnackBar(l10n.speechNotAvailable); // ⭐ CAMBIADO
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
      _showErrorSnackBar('${l10n.errorStartingSpeech}: $e'); // ⭐ CAMBIADO
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
      _showErrorSnackBar('${l10n.errorStoppingSpeech}: $e'); // ⭐ CAMBIADO
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

// In: lib/pages/screens/chatFrutia/ChatScreen.dart -> _ChatScreenState

  Widget _buildMessageBubble(ChatMessage message) {
    // This part for the analysis card is correct.
    if (message.analysisData != null) {
      return _buildAnalysisResultCard(message.analysisData!);
    }

    final time = DateFormat('HH:mm').format(message.createdAt);
    final bool isUser = message.isUser;

    // ▼▼▼ CHANGE 1: CORRECTLY IDENTIFY IMAGE MESSAGES ▼▼▼
    // An image message now has either a local path OR a network URL.
    final bool isImageMessage =
        (message.imagePath != null && message.imagePath!.isNotEmpty) ||
            (message.imageUrl != null && message.imageUrl!.isNotEmpty);
    // ▲▲▲ END OF CHANGE 1 ▲▲▲

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              if (!isImageMessage && message.text != null) {
                FlutterClipboard.copy(message.text!).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.textCopied), // ⭐ CAMBIADO
                      backgroundColor: FrutiaColors.accent,
                    ),
                  );
                });
              }
            },
            child: ChatBubble(
              clipper: ChatBubbleClipper1(
                type:
                    isUser ? BubbleType.sendBubble : BubbleType.receiverBubble,
              ),
              alignment: isUser ? Alignment.topRight : Alignment.topLeft,
              margin: const EdgeInsets.only(top: 10),
              backGroundColor: isUser ? user_bubble_color : bot_bubble_color,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ▼▼▼ CHANGE 2: LOGIC TO DISPLAY THE CORRECT IMAGE TYPE ▼▼▼
                    if (isImageMessage)
                      Padding(
                        padding: EdgeInsets.only(
                            bottom:
                                message.text != null && message.text!.isNotEmpty
                                    ? 8.0
                                    : 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Builder(
                            builder: (context) {
                              // If there's an internet URL, use Image.network
                              if (message.imageUrl != null &&
                                  message.imageUrl!.isNotEmpty) {
                                return Image.network(
                                  message.imageUrl!,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                        l10n.errorLoadingImage); // ⭐ CAMBIADO
                                  },
                                );
                              }
                              // Otherwise, use the local file path with Image.file
                              else {
                                return Image.file(File(message.imagePath!));
                              }
                            },
                          ),
                        ),
                      ),
                    // ▲▲▲ END OF CHANGE 2 ▲▲▲

                    // This logic for displaying text is correct.
                    if (message.text != null && message.text!.isNotEmpty)
                      RichText(
                        text: TextSpan(
                          children: _parseTextToSpans(message.text!,
                              isUser ? user_text_color : bot_text_color),
                          style: TextStyle(
                            color: isUser ? user_text_color : bot_text_color,
                            fontSize: 16,
                            fontFamily: 'Lora',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
            child: Text(
              time,
              style: TextStyle(
                color: FrutiaColors.secondaryText.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Widget para mostrar la IMAGEN y el TEXTO del usuario.
  Widget _buildUserImageBubble(ChatMessage message) {
    return ChatBubble(
      clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: 20),
      backGroundColor: user_bubble_color, // Usando tu color definido
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        // ▼▼▼ CAMBIO PRINCIPAL AQUÍ ▼▼▼
        // Usamos una Columna para apilar la imagen y el texto.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Alinea el texto a la izquierda dentro de la burbuja
          children: [
            // La imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(File(message.imagePath!)),
            ),

            // El texto (solo si existe y no está vacío)
            if (message.text != null && message.text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, left: 4, right: 4, bottom: 4),
                child: Text(
                  message.text!,
                  style: TextStyle(
                    color:
                        user_text_color, // Usa el color de texto que ya definiste
                    fontSize: 16,
                    fontFamily: 'Lora',
                  ),
                ),
              ),
          ],
        ),
        // ▲▲▲ FIN DEL CAMBIO ▲▲▲
      ),
    );
  }

  Widget _buildAnalysisResultCard(Map<String, dynamic> result) {
    final double percentage = result['percentage']?.toDouble() ?? 0.0;
    final String recommendation =
        result['recommendation'] ?? l10n.notDefined; // ⭐ CAMBIADO
    final List<dynamic> observations = result['observations'] ?? [];

    return ChatBubble(
      clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
      backGroundColor: const Color(0xffE7E7ED),
      margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}${l10n.bodyFatPercentage}', // ⭐ CAMBIADO
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800),
                ),
                Text(l10n.estimated, // ⭐ CAMBIADO
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const Divider(height: 20),
                Text(l10n.recommendation, // ⭐ CAMBIADO
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(recommendation,
                    style: GoogleFonts.lato(color: Colors.black87)),
                const SizedBox(height: 12),
                if (observations.isNotEmpty) ...[
                  Text(l10n.observations, // ⭐ CAMBIADO
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  ...observations
                      .map((obs) => Text('• $obs',
                          style: GoogleFonts.lato(color: Colors.black87)))
                      .toList(),
                ]
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  String _getEmotionalStateText(String? state) {
    switch (state) {
      case 'sensitive':
        return 'sensitiveState';
      case 'crisis':
        return 'crisisState';
      default:
        return 'neutralState';
    }
  }

  String _getConversationLevelText(String? level) {
    switch (level) {
      case 'advanced':
        return 'advancedLevel';
      default:
        return 'basicLevel';
    }
  }

  // En ChatScreen.dart, reemplaza _buildTypingIndicator()

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ChatBubble(
        clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(top: 5),
        backGroundColor: bot_bubble_color, // ⬅️ Usa el color del bot
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⭐ NUEVO: CircularProgressIndicator
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              // Texto que cambia
              Flexible(
                child: Text(
                  _getLoadingText(), // ⬅️ Texto dinámico
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

// ⭐ VARIABLES AL INICIO DE _ChatScreenState (junto a las otras variables)
  int _loadingTextIndex = 0;
  Timer? _loadingTextTimer;

  String _getLoadingText() {
    final texts = [
      l10n.thinkingResponse, // ⭐ CAMBIADO
      l10n.analyzingPlan, // ⭐ CAMBIADO
      l10n.consultingHistory, // ⭐ CAMBIADO
      l10n.preparingResponse, // ⭐ CAMBIADO
      l10n.reviewingMacros, // ⭐ CAMBIADO
      l10n.connectingAI, // ⭐ CAMBIADO
      l10n.calculatingRecommendations, // ⭐ CAMBIADO
      l10n.verifyingProgress, // ⭐ CAMBIADO
      l10n.searchingBestAnswer, // ⭐ CAMBIADO
      l10n.processingQuery, // ⭐ CAMBIADO
      l10n.almostReady, // ⭐ CAMBIADO
    ];
    return texts[_loadingTextIndex % texts.length];
  }

// ⭐ FUNCIÓN PARA INICIAR EL TIMER (llamar cuando empiece _isTyping)
  void _startLoadingTextAnimation() {
    _loadingTextIndex = 0;
    _loadingTextTimer?.cancel();

    // ⬅️ CAMBIO AQUÍ: De 500ms a 3000ms (3 segundos)
    _loadingTextTimer =
        Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (mounted && _isTyping) {
        setState(() {
          _loadingTextIndex++;
        });
      }
    });
  }

// ⭐ FUNCIÓN PARA DETENER EL TIMER (llamar cuando termine _isTyping)
  void _stopLoadingTextAnimation() {
    _loadingTextTimer?.cancel();
    _loadingTextIndex = 0;
  }

  void _initializeChat() {
    // Cargar mensajes previos (si vienen del widget)
    _messages = widget.initialMessages?.reversed.toList() ?? [];
    _currentSessionId = widget.sessionId;
    _isSaved = widget.sessionId != null;

    debugPrint('═══════════════════════════════════════');
    debugPrint('🔧 INICIALIZANDO CHAT:');
    debugPrint('   - Session ID recibido: ${widget.sessionId}');
    debugPrint('   - Session ID actual: $_currentSessionId');
    debugPrint('   - Mensajes cargados: ${_messages.length}');
    debugPrint('   - ¿Es guardado?: $_isSaved');
    debugPrint('   - Initial message: ${widget.initialMessage}');
    debugPrint('═══════════════════════════════════════');

    // Inicializar speech
    _initializeSpeech();

    // Timer para los puntos de "typing"
    _typingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _isTyping) {
        setState(() => _typingIndex = (_typingIndex + 1) % 3);
      }
    });

    // Mostrar showcase después de un delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _showShowcase();
        });
      }
    });

    // ⭐ NUEVA LÓGICA SIMPLE:
    if (_currentSessionId == null && _messages.isEmpty) {
      debugPrint('📝 Chat nuevo sin sesión, esperando primer mensaje...');
      return;
    }

    debugPrint('✅ Chat listo para usar (Session: $_currentSessionId)');

    // ⭐ NUEVO: Manejar initialMessage aquí
    if (widget.initialMessage != null &&
        widget.initialMessage!.isNotEmpty &&
        !_initialMessageSent) {
      _initialMessageSent = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint('📨 Enviando mensaje inicial: ${widget.initialMessage}');
          _sendMessage(widget.initialMessage!);
        }
      });
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

// En: lib/pages/screens/chatFrutia/ChatScreen.dart -> _ChatScreenState
  Widget _buildKeyboardInput() {
    final bool canSend =
        _controller.text.isNotEmpty || _stagedImageFile != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (_stagedImageFile != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_stagedImageFile!,
                        width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(l10n.imageAttached, // ⭐ CAMBIADO
                          style: TextStyle(color: Colors.black54))),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () {
                      setState(() {
                        _stagedImageFile = null;
                      });
                    },
                  )
                ],
              ),
            ).animate().fadeIn(),
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
                    hintText: l10n.typeMessage, // ⭐ CAMBIADO
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
                        if (!canSend) ...[
                          Showcase(
                            tooltipBackgroundColor: FrutiaColors.accent,
                            key: _micButtonKey,
                            title: l10n.micShowcaseTitle, // ⭐ CAMBIADO
                            description: l10n
                                .micShowcaseDesc, // ⭐ CAMBIADO  tooltipBackgroundColor: FrutiaColors.accent,
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
                                _isListening
                                    ? Icons.stop_circle
                                    : Icons.mic_none,
                                color: _isListening
                                    ? Colors.red
                                    : FrutiaColors.accent,
                                size: _isListening ? 30 : 24,
                              ),
                              tooltip: _isListening
                                  ? l10n.stopRecording // ⭐ CAMBIADO
                                  : l10n.startRecording, // ⭐ CAMBIADO
                              onPressed: () async {
                                if (_isListening) {
                                  await _stopListening();
                                } else {
                                  await _startListening();
                                }
                              },
                            ),
                          ),
                          Showcase(
                            key: _voiceChatButtonKey,
                            title: l10n.voiceChatShowcaseTitle, // ⭐ CAMBIADO
                            description:
                                l10n.voiceChatShowcaseDesc, // ⭐ CAMBIADO
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
                                    color: Colors.white,
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
                                tooltip: l10n.advancedVoiceChat, // ⭐ CAMBIADO
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
                        if (canSend)
                          IconButton(
                            icon: Icon(Icons.send, color: FrutiaColors.accent),
                            onPressed: _handleSend,
                          ),
                      ],
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                  scrollController: ScrollController(),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
// En: lib/pages/screens/chatFrutia/ChatScreen.dart -> _ChatScreenState

  /// NUEVA FUNCIÓN 1: Solo elige y "adjunta" la imagen.
  Future<void> _pickAndStageImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    setState(() {
      _stagedImageFile = File(pickedFile.path);
    });
  }

  /// NUEVA FUNCIÓN 2: Decide qué hacer cuando se presiona "Enviar".
  void _handleSend() {
    // Si hay una imagen adjunta, llama a la función de análisis.
    if (_stagedImageFile != null) {
      _sendImageAndTextForAnalysis();
    }
    // Si no, y hay texto, llama a la función de envío de texto normal.
    else if (_controller.text.isNotEmpty) {
      _sendMessage(_controller.text); // Asumo que ya tienes esta función
    }
  }

  // En: lib/pages/screens/chatFrutia/ChatScreen.dart -> _ChatScreenState

  Future<void> _sendImageAndTextForAnalysis() async {
    if (_stagedImageFile == null) return;

    final imageToSend = _stagedImageFile!;
    final userText = _controller.text;

    setState(() {
      _stagedImageFile = null;
      _controller.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    });

    final tempMessageId = DateTime.now().millisecondsSinceEpoch;
    final userMessage = ChatMessage(
      id: tempMessageId,
      chatSessionId: _currentSessionId ?? -1,
      isUser: true,
      imagePath: imageToSend.path,
      text: userText.isNotEmpty ? userText : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMessage);
      _isTyping = true;
    });

    try {
      final imageUrl = await _chatService.uploadImage(imageToSend);

      setState(() {
        final index = _messages.indexWhere((m) => m.id == tempMessageId);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: _messages[index].id,
            chatSessionId: _messages[index].chatSessionId,
            isUser: true,
            imagePath: _messages[index].imagePath,
            imageUrl: imageUrl,
            text: _messages[index].text,
            createdAt: _messages[index].createdAt,
            updatedAt: DateTime.now(),
          );
        }
      });

      final analysisResult =
          await _chatService.analyzeBodyImage(imageToSend, text: userText);

      final assistantResponseMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        chatSessionId: _currentSessionId ?? -1,
        isUser: false,
        analysisData: analysisResult,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      setState(() => _messages.insert(0, assistantResponseMessage));
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        chatSessionId: _currentSessionId ?? -1,
        isUser: false,
        text: l10n.errorProcessingImage, // ⭐ CAMBIADO
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      setState(() => _messages.insert(0, errorMessage));
    } finally {
      setState(() => _isTyping = false);
    }
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
