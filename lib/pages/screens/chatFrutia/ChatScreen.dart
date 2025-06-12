import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/model/ChatMessage.dart';
import 'package:Frutia/pages/screens/chatFrutia/PermissionService.dart';
import 'package:Frutia/pages/screens/chatFrutia/VoiceChatScreen.dart';
import 'package:Frutia/pages/screens/chatFrutia/WaveVisualizer.dart';
import 'package:Frutia/services/ChatServiceApi.dart';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:permission_handler/permission_handler.dart';
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
  late Timer _typingTimer;
  bool _isSpeechInitialized = false;
  late AnimationController _sunController;
  late Animation<double> _sunAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ChatServiceApi _chatService = ChatServiceApi();

  final Color frutia_background = Colors.white; // Un crema suave y cálido
  final Color frutia_accent = Color(0xFFFF8A65);     // Durazno/Coral como acento principal
  final Color frutia_primary_text = Color(0xFF5D4037); // Marrón oscuro para texto
 

// Colores mejorados para los bubbles
final Color user_bubble_color = const Color.fromARGB(255, 236, 112, 67); // Color principal para el usuario
 
 final Color bot_bubble_color = FrutiaColors.accent;    // Gris oscuro elegante para el bot


final Color user_text_color = Colors.white;         // Texto blanco para mejor contraste
final Color bot_text_color = Colors.white;          // Texto blanco también para el bot
final Color time_text_color = Colors.white70;       // Color más suave para la hora


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

  // Mapa de códigos de idioma para reconocimiento de voz
  final Map<String, String> _speechLocales = {
    'es': 'es_ES',
    'en': 'en_US',
    'fr': 'fr_FR',
    'pt': 'pt_BR',
  };

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

  @override
  void initState() {
    super.initState();
    _messages = widget.initialMessages?.reversed.toList() ?? [];
    _currentSessionId = widget.sessionId;
    _isSaved = widget.sessionId != null && widget.initialMessages != null;

    for (var message in _messages) {
      _updateTokenCount(message.text);
    }

    _sunController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _sunAnimation = Tween<double>(begin: 30.0, end: 40.0).animate(
      // Reduced size
      CurvedAnimation(parent: _sunController, curve: Curves.easeInOut),
    );

    _initializeSpeech();
    _typingTimer = Timer.periodic(Duration.zero, (_) {});
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
    if (_typingTimer.isActive) {
      _typingTimer.cancel();
    }
    _sunController.dispose();
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
    if (_totalTokens > _tokenLimit) {
     }
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
text: response['ai_message']?['text'] ?? 'Error: No se recibió una respuesta válida.',        isUser: false,
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
        _typingTimer.cancel();
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
        _typingTimer.cancel();
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

  // Elimina esta línea:
// String _transcribedText = '';

// En ChatScreen
  Future<void> _startListening() async {
    if (_isListening) return;

    final permissionService = PermissionService();
    final micStatus =
        await permissionService.checkOrRequest(Permission.microphone);

    if (!micStatus.isGranted) {
      if (micStatus.isPermanentlyDenied) {
        _showErrorSnackBar(
            'Por favor habilita los permisos de micrófono en Configuración');
        await openAppSettings();
      }
      return;
    }

    if (!_isSpeechInitialized) {
      _showErrorSnackBar('El reconocimiento de voz no está inicializado');
      return;
    }

    try {
      setState(() {
        _isListening = true;
        _controller.clear();
      });

      final localeId = _speechLocales[context.locale.languageCode] ?? 'es_ES';
      debugPrint('Starting speech recognition with locale: $localeId');

      _speech.listen(
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
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
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
  final time = DateFormat('HH:mm').format(message.createdAt); // Formato más limpio

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Column(
      crossAxisAlignment:
          message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
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
                color: message.isUser ? user_bubble_color : bot_bubble_color,
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
                  
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: message.isUser ? user_text_color : bot_text_color,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      children: _parseTextToSpans(message.text).map((span) {
                        return TextSpan(
                          text: span.text,
                          style: span.style?.copyWith(
                            color: message.isUser ? user_text_color : bot_text_color,
                          ) ?? TextStyle(
                            color: message.isUser ? user_text_color : bot_text_color,
                          ),
                        );
                      }).toList(),
                    ),
                    textAlign: message.isUser ? TextAlign.end : TextAlign.start,
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

   
 
  Widget _buildInput() {
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

  Widget _buildKeyboardInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (_isListening) _buildVoiceVisualizer(),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calcular la altura basada en el contenido
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
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.stop_circle : Icons.mic_none,
                            color: _isListening ? Colors.red : FrutiaColors.accent,
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
                          Container(
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
                                    builder: (context) => VoiceChatScreen(
                                      language:"es"
                                    ),
                                  ),
                                );
                              },
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBack(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: frutia_background,
        body: Stack(
          children: [
            _FloatingParticles(),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(   FrutiaColors.accent), // Color is here
                  strokeWidth: 6.0,
                  backgroundColor: Colors.white.withOpacity(0.3),
                ),
              )
            else
              Column(
                children: [
                  AppBar(
                    backgroundColor:FrutiaColors.accent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => _navigateBack(context),
                    ),
                    actions: [
                      if (!_isSaved)
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: TextButton.icon(
                            icon:
                                Icon(Icons.save, color: Colors.white, size: 22),
                            label: Text(
                              "Guardar Chat",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            onPressed: _saveChat,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                reverse: true,
                                itemCount:
                                    _messages.length + (_isTyping ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (_isTyping && index == 0) {
                                    return _buildTypingIndicator();
                                  }
                                  final messageIndex =
                                      _isTyping ? index - 1 : index;
                                  return _buildMessageBubble(
                                      _messages[messageIndex]);
                                },
                              ),
                            ),
                            _buildInput(),
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
