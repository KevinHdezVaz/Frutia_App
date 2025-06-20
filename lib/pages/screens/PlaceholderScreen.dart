import 'package:Frutia/pages/screens/CompraDetailScreen.dart';
import 'package:Frutia/pages/screens/ModificationsScreen.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/pages/screens/miplan/MyPlanPage.dart';
import 'package:Frutia/pages/screens/RecipeDetailScreen.dart';
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
    // Si tu BottomNavigationBar maneja diferentes pantallas, asegúrate de que todas estén aquí.
    // Ej:
    // const Text('Pantalla de Perfil'), // Índice 0
    // const Text('Pantalla de Frutia'), // Índice 1
    // MyPlanPage(), // Índice 2 (para "Mi Plan")
    // const Text('Pantalla de Progreso'), // Índice 3
    // const Text('Pantalla de Nosotros'), // Índice 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FrutiaColors.accent, FrutiaColors.accent2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Frutia',
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
      body: Container(
        child: _screens[
            _currentIndex], // Asumiendo que _screens se usa para el BottomNav
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
      'icon': Icons.home,
      'image': 'assets/images/plan_alimenticion.jpg'
    },
    {
      'name': 'Recetas',
      'icon': Icons.restaurant_menu,
      'image': 'assets/images/receta.png'
    },
    {
      'name': 'Compras',
      'icon': Icons.shopping_cart,
      'image': 'assets/images/compras.jpg'
    },
    {
      'name': 'Modificaciones',
      'icon': Icons.edit,
      'image': 'assets/images/modificacione.png'
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
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(categories.length, (index) {
                    return _InteractiveCard(
                        category: categories[index], index: index);
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

class _InteractiveCard extends StatefulWidget {
  final Map<String, dynamic> category;
  final int index;

  const _InteractiveCard({required this.category, required this.index});

  @override
  _InteractiveCardState createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard>
    with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isTapped = true;
          });
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() {
            _isTapped = false;
          });
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() {
            _isTapped = false;
          });
          _controller.reverse();
        },
        onPanStart: (_) {
          setState(() {
            _isHovered = true;
          });
          _controller.forward();
        },
        onPanEnd: (_) {
          setState(() {
            _isHovered = false;
          });
          _controller.reverse();
        },
        onTap: () async {
          // <--- HACEMOS onTap ASÍNCRONO
          // Navegación a la pantalla correspondiente según la categoría
          switch (widget.category['name']) {
            case 'Mi Plan':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPlanPage()),
              );
              break;
            case 'Recetas':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecetasScreen()),
              );
              break;
            case 'Compras':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ComprasScreen()),
              );
              break;
         case 'Modificaciones':
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ModificationsScreen()),
  );
  break;
       
            

          }
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Card(
                elevation: _isHovered || _isTapped ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: _isTapped ? Colors.grey[200] : Colors.white,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(widget.category['image']),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(_isHovered ? 0.2 : 0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.category['icon'],
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.category['name'],
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
                ),
              ),
            );
          },
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: (200 + widget.index * 200).ms)
        .slideY(
          begin: 0.3,
          end: 0.0,
          duration: 800.ms,
          curve: Curves.easeOut,
        );
  }
}
