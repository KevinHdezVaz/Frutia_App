import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:user_auth_crudd10/utils/colors.dart';

class MyPlanPage extends StatefulWidget {
  const MyPlanPage({super.key});

  @override
  _MyPlanPageState createState() => _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> meals = [
    {
      'title': 'Desayuno',
      'description': 'Avena con frutas y nueces (300 kcal)',
      'icon': Icons.free_breakfast,
    },
    {
      'title': 'Comida',
      'description': 'Pechuga a la plancha con ensalada (500 kcal)',
      'icon': Icons.lunch_dining,
    },
    {
      'title': 'Cena',
      'description': 'Salmón con verduras al vapor (400 kcal)',
      'icon': Icons.dinner_dining,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const dailyCalorieGoal = 2000; // Example goal
    final currentCalories = meals.fold<int>(
        0,
        (sum, meal) =>
            sum + (int.parse(meal['description'].split('(')[1].split(' ')[0])));

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
                // Encabezado
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mi Plan',
                        style: GoogleFonts.lato(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.primaryText,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 800.ms).slideX(
                            begin: -0.2,
                            end: 0.0,
                            duration: 800.ms,
                            curve: Curves.easeOut,
                          ),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          color: FrutiaColors.primaryText,
                          size: 28,
                        ),
                        onPressed: () {
                          // Show plan details or info
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Detalles del plan')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: FrutiaColors.secondaryBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: currentCalories / dailyCalorieGoal,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      FrutiaColors.accent),
                                ),
                              ),
                              Text(
                                '${(currentCalories / dailyCalorieGoal * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: FrutiaColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Progreso Diario',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: FrutiaColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$currentCalories / $dailyCalorieGoal kcal',
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
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 24),

                // Carousel de Comidas
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 220,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: 0.8,
                    onPageChanged: (index, reason) async {
                      setState(() {
                        _currentIndex = index;
                      });
                      if (await Vibration.hasVibrator() ?? false) {
                        Vibration.vibrate(duration: 50); // Short vibration
                      }
                    },
                  ),
                  items: meals.map((meal) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Card(
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: FrutiaColors.secondaryBackground
                              .withOpacity(0.95),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: FrutiaColors.accent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    meal['icon'],
                                    color: FrutiaColors.accent,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        meal['title'],
                                        style: GoogleFonts.lato(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: FrutiaColors.primaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        meal['description'],
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: FrutiaColors.secondaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {
                                          // View meal details
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Ver detalles de ${meal['title']}')),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: FrutiaColors.accent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                        ),
                                        child: Text(
                                          'Ver Detalles',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 800.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.0, 1.0),
                              duration: 800.ms,
                              curve: Curves.easeOut,
                            );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Indicadores del Carousel
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: meals.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _carouselController.animateToPage(entry.key),
                      child: Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == entry.key
                              ? FrutiaColors.accent
                              : Colors.grey.withOpacity(0.4),
                          border: Border.all(
                            color: FrutiaColors.primaryText,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
