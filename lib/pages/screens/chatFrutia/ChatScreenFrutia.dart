import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_auth_crudd10/utils/colors.dart'; // Import FrutiaColors

class ChatScreenFrutia extends StatelessWidget {
  const ChatScreenFrutia({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground, // White background
      appBar: AppBar(
        title: Text(
          'Chatea con FRUTIA',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Messages Area
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: ListView(
                  children: [
                    // AI Message
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.0, right: 50.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: FrutiaColors.accent
                              .withOpacity(0.1), // Light red background
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          '¡Hola! ¿En qué puedo ayudarte hoy?',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                    ),
                    // User Message
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.0, left: 50.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: FrutiaColors.accent, // Red background for user
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          'Quiero saber más sobre mis eventos.',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: FrutiaColors.primaryBackground,
                          ),
                        ),
                      ),
                    ),
                    // AI Message
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.0, right: 50.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: FrutiaColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          'Claro, te puedo ayudar con eso. ¿Te refieres a los eventos próximos o a los que ya asististe?',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Input Area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              color: FrutiaColors.primaryBackground,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: FrutiaColors.accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                      ),
                      style: TextStyle(color: Color(0xFF2D2D2D)),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: FrutiaColors.accent,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send,
                          color: FrutiaColors.primaryBackground),
                      onPressed: () {
                        // Placeholder for send action
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
