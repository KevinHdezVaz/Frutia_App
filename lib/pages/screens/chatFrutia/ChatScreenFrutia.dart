import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/model/ChatMessage.dart';
import 'package:Frutia/pages/screens/chatFrutia/ChatHistoryPage.dart';
import 'package:Frutia/utils/colors.dart';

class ChatScreenFrutia extends StatelessWidget {
  final VoidCallback onBack;
  final List<ChatMessage> messages;

  const ChatScreenFrutia({
    super.key,
    required this.onBack,
    this.messages = const [],
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onBack,
      child: Scaffold(
         appBar: AppBar(
          title: Text(
            'Chatea con FRUTIA',
            style: GoogleFonts.lato(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
           elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: FrutiaColors.accent),
            onPressed: onBack,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.history, color: FrutiaColors.accent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatHistoryPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFD1B3), // Naranja suave
                Color(0xFFFF6F61), // Rojo cálido
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Chat Messages Area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return Align(
                          alignment: message.isUserMessage
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: message.isUserMessage
                                ? const EdgeInsets.only(
                                    bottom: 10.0, left: 50.0)
                                : const EdgeInsets.only(
                                    bottom: 10.0, right: 50.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: message.isUserMessage
                                  ? FrutiaColors.accent
                                  : FrutiaColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              message.text,
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: message.isUserMessage
                                    ? FrutiaColors.primaryBackground
                                    : FrutiaColors.primaryText,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 800.ms)
                              .slideX(
                                  begin: message.isUserMessage ? 0.2 : -0.2,
                                  end: 0.0,
                                  duration: 800.ms,
                                  curve: Curves.easeOut),
                        );
                      },
                    ),
                  ),
                ),
                // Input Area
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                   child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Escribe tu mensaje...',
                            hintStyle:
                                TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: FrutiaColors.accent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                          ),
                          style: TextStyle(color: FrutiaColors.primaryText),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: FrutiaColors.accent,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send,
                              color: FrutiaColors.primaryBackground),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideY(
                    begin: 0.3,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}