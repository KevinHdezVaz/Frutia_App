import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({Key? key}) : super(key: key);

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    _HomeContent(), // Contenido principal con categorías
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [FrutiaColors.secondaryBackground, FrutiaColors.accent],
          ),
        ),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        color: FrutiaColors.secondaryBackground,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: FrutiaColors.accent,
              unselectedItemColor: FrutiaColors.disabledText,
              backgroundColor: FrutiaColors.secondaryBackground,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              elevation: 0,
              iconSize: 22,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.person, size: 22),
                  ),
                  label: "Perfil",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.message, size: 22),
                  ),
                  label: "Frutia",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.food_bank, size: 22),
                  ),
                  label: "Mi Plan",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.auto_graph_outlined, size: 22),
                  ),
                  label: "Progreso",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.book, size: 22),
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
}

class _HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Mi Plan',
      'icon': Icons.food_bank,
      'image': 'https://images.unsplash.com/photo-1512621776951-a57141f9eefd?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
    },
    {
      'name': 'Recetas',
      'icon': Icons.restaurant_menu,
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
    },
    {
      'name': 'Compras',
      'icon': Icons.shopping_cart,
      'image': 'https://images.unsplash.com/photo-1542838686-b08706ce46b9?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
    },
    {
      'name': 'Modificaciones',
      'icon': Icons.edit,
      'image': 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frutia',
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.primaryText,
              ),
            ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2, end: 0.0, duration: 800.ms, curve: Curves.easeOut),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(categories.length, (index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          height: 150, // Fixed height for uniformity
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(category['image']),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3), // Subtle overlay for readability
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category['icon'],
                                size: 40,
                                color: FrutiaColors.accent,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['name'],
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white, // White text for contrast
                                  shadows: [
                                    Shadow(
                                      blurRadius: 2.0,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: (200 + index * 200).ms).slideY(
                            begin: 0.3,
                            end: 0.0,
                            duration: 800.ms,
                            curve: Curves.easeOut,
                          ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}