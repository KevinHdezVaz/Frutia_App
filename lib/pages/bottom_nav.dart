import 'package:Frutia/pages/screens/PlaceholderScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Frutia/pages/home_page.dart';
import 'package:Frutia/pages/others/profile_page.dart';
import 'package:Frutia/pages/screens/miplan/MyPlanPage.dart';
import 'package:Frutia/pages/screens/chatFrutia/ChatHistoryPage.dart';
import 'package:Frutia/pages/screens/chatFrutia/ChatScreenFrutia.dart';
import 'package:Frutia/pages/screens/progress/ProgressPage.dart';
import 'package:Frutia/services/BonoService.dart';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:Frutia/utils/colors.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;

  const BottomNavBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;
  final BonoService _bonoService = BonoService(baseUrl: baseUrl);
  final StorageService _storageService = StorageService();
  late final List<Widget> _pages;

  void _changeIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // Lista fija de páginas
    _pages = [
      HomePage(),
      ChatHistoryPage(), // Al tocar "Frutia", irá a ChatHistoryPage
      PlaceholderScreen(),
      ProgressScreen(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Stack(
          children: [
            _pages[_selectedIndex],
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
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
                      currentIndex: _selectedIndex,
                      onTap: _changeIndex,
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
                              color: _selectedIndex == 0
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
                              color: _selectedIndex == 1
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
                              color: _selectedIndex == 2
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
                              color: _selectedIndex == 3
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
                              color: _selectedIndex == 4
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
            ),
          ],
        ),
      ),
    );
  }
}

// Plan Feature Widget (sin cambios)
class PlanFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const PlanFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: FrutiaColors.accent, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Color(0xFF2D2D2D)),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Button Widget (sin cambios)
class AnimatedButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const AnimatedButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: (MediaQuery.of(context).size.width - 32 - 20) / 3 - 10,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  color: FrutiaColors.primaryBackground, size: 20),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.color == FrutiaColors.secondaryText
                        ? FrutiaColors.primaryBackground
                        : FrutiaColors.primaryBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
