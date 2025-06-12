import 'package:Frutia/model/ChatSession.dart';
import 'package:Frutia/pages/screens/chatFrutia/ChatScreen.dart';
import 'package:Frutia/pages/screens/chatFrutia/VoiceChatScreen.dart';
import 'package:Frutia/services/ChatServiceApi.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen>
    with SingleTickerProviderStateMixin {
  final ChatServiceApi _chatService = ChatServiceApi();
  List<ChatSession> _sessions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Color tiffanyColor = Colors.white;
  final Color ivoryColor = Color(0xFFFDF8F2);
  final Color darkTextColor = Colors.black87;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchSessions() async {
    try {
      setState(() => _isLoading = true);
      final sessions = await _chatService.getSessions(saved: true);
      setState(() {
        _sessions = sessions
            .where((session) => session.deletedAt == null && session.isSaved)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar las conversaciones: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  List<ChatSession> get _filteredSessions {
    if (_searchQuery.isEmpty) return _sessions;

    return _sessions
        .where((session) =>
            session.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            _formatDate(session.createdAt)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _deleteSession(int id) async {
    try {
      await _chatService.deleteSession(id);
      setState(() {
        _sessions.removeWhere((session) => session.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conversación eliminada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Error al eliminar la conversación: $e');
    }
  }

  void _startNewConversation({required String inputMode}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChatScreen(
          initialMessages: [],
          inputMode: inputMode,
          sessionId: null,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tiffanyColor,
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
          'Tus chats con Frutia',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: darkTextColor, size: 28),
            onPressed: _fetchSessions,
            tooltip: 'Recargar',
          ),
          SizedBox(width: 16),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        ),
        child: FloatingActionButton(
          onPressed: () => _startNewConversation(inputMode: 'keyboard'),
          backgroundColor: FrutiaColors.accent,
          child: Icon(Icons.add, color: Colors.white),
          tooltip: 'Nueva Conversación',
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
         Padding(
  padding: const EdgeInsets.all(20.0), // Aumenté el padding externo a 20 para mejor espaciado
  child: Column(
    children: [
      Card(
        color: Colors.white,
        elevation: 6, // Aumenté la elevation a 6 para una sombra más pronunciada
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: FrutiaColors.accent.withOpacity(0.3), width: 1), // Añadí un borde sutil
        ),
        margin: const EdgeInsets.all(8.0), // Añadí padding interno al Card
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar conversaciones...',
            hintStyle: GoogleFonts.poppins(
                color: darkTextColor.withOpacity(0.5)),
            prefixIcon: Icon(Icons.search, color: FrutiaColors.accent),
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: GoogleFonts.poppins(
              color: darkTextColor, fontSize: 16),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
      if (_filteredSessions.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 20.0), // Aumenté el padding superior a 20
          child: _buildNewChatButtons(),
        ),
    ],
  ),
),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: FrutiaColors.accent,
                          strokeWidth: 3,
                        ),
                      )
                    : _filteredSessions.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: FrutiaColors.accent,
                            onRefresh: _fetchSessions,
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                  bottom: 80, left: 16, right: 16),
                              itemCount: _filteredSessions.length,
                              itemBuilder: (context, index) {
                                final session = _filteredSessions[index];
                                return _buildSessionCard(session);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(ChatSession session) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, ivoryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            backgroundColor: FrutiaColors.accent.withOpacity(0.2),
            child: Icon(
              Icons.chat_bubble_outline,
              color: FrutiaColors.accent,
              size: 24,
            ),
          ),
          title: Text(
            session.title,
            style: GoogleFonts.poppins(
              color: darkTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatDate(session.createdAt),
            style: GoogleFonts.poppins(
              color: darkTextColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          trailing: IconButton(
            icon:
                Icon(Icons.delete_outline, color: FrutiaColors.accent, size: 24),
            onPressed: () => _showDeleteDialog(session.id),
          ),
          onTap: () => _openChat(session),
        ),
      ),
    );
  }

  void _showDeleteDialog(int sessionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.2).animate(
                  CurvedAnimation(
                      parent: _pulseController, curve: Curves.easeInOut),
                ),
                child: Icon(Icons.warning_amber_rounded,
                    color: FrutiaColors.accent, size: 48),
              ),
              SizedBox(height: 16),
              Text(
                'Eliminar Conversación',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                '¿Estás seguro de que quieres eliminar esta conversación?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: darkTextColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ivoryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteSession(sessionId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrutiaColors.accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Eliminar',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
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

  Future<void> _openChat(ChatSession session) async {
    try {
      final messages = await _chatService.getSessionMessages(session.id);
      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ChatScreen(
            initialMessages: messages,
            inputMode: 'keyboard',
            sessionId: session.id,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 700),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Error al abrir la conversación: $e');
    }
  }

  Widget _buildNewChatButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _startNewConversation(inputMode: 'keyboard'),
          style: ElevatedButton.styleFrom(
            backgroundColor: FrutiaColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.message, size: 20, color: Colors.white,),
              SizedBox(width: 8),
              Text(
                'Chat Normal',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
       onPressed: () async {
  try {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const VoiceChatScreen(language: "es-ES"), // Pasa el idioma estático
      ),
    );
  } catch (e) {
    print("Error al navegar a VoiceChatScreen: $e");
    // Opcional: muestra un SnackBar o alerta al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al iniciar el chat de voz: $e')),
    );
  }
},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: FrutiaColors.accent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 2,
            side: BorderSide(color: FrutiaColors.accent, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic, size: 20, color: Colors.black,),
              SizedBox(width: 8),
              Text(
                'Chat de Voz',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: FrutiaColors.accent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.1).animate(
                CurvedAnimation(
                    parent: _pulseController, curve: Curves.easeInOut),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: FrutiaColors.accent.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡No hay conversaciones aún!',
              style: GoogleFonts.poppins(
                color: darkTextColor,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Empieza una nueva conversación con Frutia, ya sea por texto o voz.',
              style: GoogleFonts.poppins(
                color: darkTextColor.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildNewChatButtons(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    final formattedTime = _formatTime(date);

    if (dateOnly == today) {
      return 'Hoy a las $formattedTime';
    } else if (dateOnly == yesterday) {
      return 'Ayer a las $formattedTime';
    } else {
      return '${date.day}/${date.month}/${date.year} $formattedTime';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}