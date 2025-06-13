import 'dart:async';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/pages/screens/miplan/MyPlanPage.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

enum CarouselState { loading, hasData, error, noPlan }

class PlanCarousel extends StatefulWidget {
  const PlanCarousel({Key? key}) : super(key: key);

  @override
  _PlanCarouselState createState() => _PlanCarouselState();
}

class _PlanCarouselState extends State<PlanCarousel> {
  final AuthService _authService = AuthService();
  late final PageController _pageController;
  Timer? _timer;
  CarouselState _state = CarouselState.loading;
  final List<Map<String, dynamic>> _meals = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85, initialPage: 1000);
    _fetchPlanData();
  }

  Future<void> _fetchPlanData() async {
    try {
      final userData = await _authService.getProfile();
      if (!mounted) return;

      final activePlan = userData['active_plan'];
      final planData = activePlan?['plan_data']?['meal_plan'];

      if (planData == null) {
        setState(() => _state = CarouselState.noPlan);
        return;
      }

      _parsePlanData(planData);

      setState(() {
        _state = CarouselState.hasData;
      });

      if (_meals.isNotEmpty) {
        _startAutoScroll();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = CarouselState.error);
      print("Error al cargar el plan para el carrusel: $e");
    }
  }

  void _parsePlanData(Map<String, dynamic> planData) {
    _meals.clear();
    final mealDefinitions = [
      {'title': 'Desayuno', 'icon': Icons.free_breakfast_rounded, 'options': planData['desayuno'] as List?},
      {'title': 'Almuerzo', 'icon': Icons.lunch_dining_rounded, 'options': planData['almuerzo'] as List?},
      {'title': 'Cena', 'icon': Icons.dinner_dining_rounded, 'options': planData['cena'] as List?},
    ];

    for (var meal in mealDefinitions) {
      if (meal['options'] != null && (meal['options'] as List).isNotEmpty) {
        _meals.add(meal);
      }
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_pageController.hasClients || _meals.length <= 1) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case CarouselState.loading:
        return const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator(color: FrutiaColors.accent)),
        );
      case CarouselState.error:
        return const Card(
          child: ListTile(
            leading: Icon(Icons.error_outline, color: Colors.red),
            title: Text('No se pudo cargar tu plan.'),
          ),
        );
      case CarouselState.noPlan:
      case CarouselState.hasData:
        if (_meals.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Tu plan no tiene comidas definidas.'),
            ),
          );
        }
        return Column(
          children: [
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  final meal = _meals[index % _meals.length];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _MealCarouselCard(
                      icon: meal['icon'] as IconData,
                      title: meal['title'] as String,
                      options: meal['options'] as List<dynamic>?,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SmoothPageIndicator(
              controller: _pageController,
              count: _meals.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey.shade300,
              ),
              onDotClicked: (index) {
                _pageController.animateToPage(
                  _pageController.page!.round() - (_pageController.page!.round() % _meals.length) + index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
            ),
          ],
        );
    }
  }
}


class _MealCarouselCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<dynamic>? options;
  final bool isPremium; // Nuevo parámetro para determinar si es premium

  const _MealCarouselCard({
    required this.icon,
    required this.title,
    this.options,
    this.isPremium = false, // Valor por defecto false
  });

  @override
  Widget build(BuildContext context) {
    final optionCount = options?.length ?? 0;
    final borderColor = isPremium ? Colors.green : Colors.orange;
    final backgroundColor = isPremium 
        ? Colors.green[50]?.withOpacity(0.7) 
        : Colors.orange[50]?.withOpacity(0.7);

    return Container(
     decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: [
      isPremium ? Colors.green.shade100 : Colors.orange.shade100,
      isPremium ? Colors.green.shade50 : Colors.orange.shade50,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: isPremium ? Colors.green : Colors.orange,
    width: 2.0,
  ),
  boxShadow: [
    BoxShadow(
      color: (isPremium ? Colors.green : Colors.orange).withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ],
),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPlanPage()));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon, 
                      color: borderColor, 
                      size: 28
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  optionCount > 1
                      ? 'Tienes $optionCount opciones deliciosas:'
                      : 'Tu opción para hoy es:',
                  style: GoogleFonts.lato(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                if (options?.isNotEmpty == true)
                  Text(
                    '• ${options![0]['opcion']}',
                    style: GoogleFonts.lato(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
