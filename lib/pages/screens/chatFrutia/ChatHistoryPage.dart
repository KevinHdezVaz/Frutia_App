import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/model/ChatMessage.dart';
import 'package:Frutia/pages/screens/chatFrutia/ChatScreenFrutia.dart';
import 'package:Frutia/utils/colors.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado adicional (opcional, para consistencia)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Historial de Chat',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: FrutiaColors.primaryText,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideX(
                    begin: -0.2,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),
              ),
              const SizedBox(height: 16),

              // Lista de chats
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: sampleChats.length,
                  itemBuilder: (context, index) {
                    final chat = sampleChats[index];
                    return _buildChatCard(
                      context: context,
                      chat: chat,
                      delay: 200 + index * 200,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: FrutiaColors.primaryBackground,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: FrutiaColors.accent,
              unselectedItemColor: FrutiaColors.disabledText,
              backgroundColor: FrutiaColors.primaryBackground,
              currentIndex: 0, // Índice inicial (ajústalo según tu lógica)
              onTap: (index) {
                // Lógica de navegación (puedes expandirla según necesites)
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreenFrutia(
                        onBack: () => Navigator.pop(context),
                        messages: sampleChats[index].messages,
                      ),
                    ),
                  );
                }
              },
              elevation: 0,
              iconSize: 22,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.person,
                      color: 0 == 0
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Perfil",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.message,
                      color: 0 == 1
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Frutia",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.food_bank,
                      color: 0 == 2
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Mi Plan",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.auto_graph_outlined,
                      color: 0 == 3
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Progreso",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.book,
                      color: 0 == 4
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Nosotros",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatCard({
    required BuildContext context,
    required Chat chat,
    required double delay,
  }) {
    return GestureDetector(
      onTap: () {
        // Navegar a ChatScreenFrutia con los mensajes del chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreenFrutia(
              onBack: () => Navigator.pop(context),
              messages: chat.messages,
            ),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: FrutiaColors.secondaryBackground,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ícono o avatar de Frutia
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: FrutiaColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat,
                  color: FrutiaColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Información del chat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.title,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.preview,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: FrutiaColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Timestamp
              Text(
                _formatTimestamp(chat.lastMessageTimestamp),
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: FrutiaColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 800.ms)
        .slideY(begin: 0.3, end: 0.0, duration: 800.ms, curve: Curves.easeOut);
  }

  // Método para formatear el timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
