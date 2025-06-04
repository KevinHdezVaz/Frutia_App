import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:user_auth_crudd10/utils/colors.dart';

class HomePage extends StatelessWidget {
  // Sample data for the carousel
  final List<Map<String, String>> carouselItems = [
    {
      'title': '¡Mantente hidratado!',
      'subtitle': 'Bebe 8 vasos de agua hoy.',
      'image': 'assets/carousel1.jpg',
    },
    {
      'title': '¡Prueba una nueva receta!',
      'subtitle': 'Explora sabores mediterráneos.',
      'image': 'assets/carousel2.jpg',
    },
    {
      'title': '¡Sigue tus metas!',
      'subtitle': '¡Estás a mitad de camino!',
      'image': 'assets/carousel3.jpg',
    },
  ];

  // Quick Access data with Flutter icons
  final List<Map<String, dynamic>> quickAccessItems = [
    {
      'title': 'Recetas',
      'subtitle': 'Descubre nuevas comidas',
      'icon': Icons.restaurant_menu,
    },
    {
      'title': 'Progreso',
      'subtitle': 'Sigue tu viaje',
      'icon': Icons.show_chart,
    },
    {
      'title': 'Chat IA',
      'subtitle': 'Tu guía de chat IA',
      'icon': Icons.chat,
    },
    {
      'title': 'Lista de compras',
      'subtitle': 'Planifica tus compras',
      'icon': Icons.list,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar personalizado
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications,
                            color: FrutiaColors.primaryText),
                        onPressed: () {},
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: FrutiaColors.secondaryBackground,
                        child: Icon(
                          Icons.person,
                          color: FrutiaColors.primaryText,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms),

                // Carousel Section
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                  ),
                  items: carouselItems.map((item) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: FrutiaColors.shadow,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Image.asset(
                                  item['image']!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: FrutiaColors.nutrition,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: FrutiaColors.primaryBackground,
                                      size: 50,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']!,
                                          style: GoogleFonts.lato(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                FrutiaColors.primaryBackground,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['subtitle']!,
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            color:
                                                FrutiaColors.primaryBackground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(
                    begin: 0.3,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 24),

                // Greeting Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '¡Buenas noches, John!', // Ajustado para el horario (05:45 PM CST)
                    style: GoogleFonts.lato(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: FrutiaColors.primaryText,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideX(
                    begin: -0.2,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '¿Listo para alcanzar tus metas hoy?',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: FrutiaColors.secondaryText,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideX(
                    begin: -0.2,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 16),

                // Daily Intake Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: FrutiaColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: FrutiaColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingesta diaria de calorías',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '1850',
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ 2200 kcal',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: FrutiaColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: 1850 / 2200,
                        backgroundColor: FrutiaColors.primaryBackground,
                        color: FrutiaColors.accent,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '¡Estás en camino hacia tus metas!',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: FrutiaColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              '+ Agregar comida',
                              style: GoogleFonts.inter(
                                color: FrutiaColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideX(
                    begin: -0.2,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 24),

                // Today's Meals Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Comidas de hoy',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: FrutiaColors.primaryText,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideX(
                    begin: -0.2,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 8),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: FrutiaColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: FrutiaColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/meal_image.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 60,
                            height: 60,
                            color: FrutiaColors.nutrition,
                            child: Icon(
                              Icons.restaurant_menu,
                              color: FrutiaColors.primaryBackground,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Almuerzo',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ensalada de garbanzos mediterránea',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FrutiaColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '✓ Garbanzos',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            Text(
                              '✓ Pepino',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            Text(
                              '✓ Tomates',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            Text(
                              '✓ 2 más...',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideX(
                    begin: -0.2,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 24),

                // Explore Full Plan Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrutiaColors.accent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Explorar plan completo',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryBackground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: FrutiaColors.primaryBackground,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 1000.ms, duration: 800.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 24),

                // Quick Access Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Acceso rápido',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: FrutiaColors.primaryText,
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 800.ms).slideX(
                    begin: -0.2,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 8),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: quickAccessItems.map((item) {
                      return Container(
                        decoration: BoxDecoration(
                          color: FrutiaColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: FrutiaColors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFA726),
                                      Color(0xFFFF6F61),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    item['icon'],
                                    size: 40,
                                    color: FrutiaColors.primaryBackground,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['title']!,
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FrutiaColors.primaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle']!,
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: FrutiaColors.secondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 800.ms).slideX(
                    begin: -0.2,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
