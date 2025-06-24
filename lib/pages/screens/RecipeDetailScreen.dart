import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/pages/screens/ModificationsScreen.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/pages/screens/miplan/MyPlanDetailsScreen.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecetasScreen extends StatefulWidget {
  const RecetasScreen({super.key});

  @override
  State<RecetasScreen> createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;
  String _errorMessage = '';

  List<Map<String, dynamic>> _breakfastOptions = [];
  List<Map<String, dynamic>> _lunchOptions = [];
  List<Map<String, dynamic>> _dinnerOptions = [];
  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    print('RecetasScreen: Inicializando estado');
    _tabController = TabController(length: 3, vsync: this);
    _loadPlanData();
  }

  Future<void> _loadPlanData() async {
    print('RecetasScreen: Iniciando carga de datos del plan');
    try {
      final userData = await AuthService().getProfile();
      print('RecetasScreen: Datos del usuario obtenidos: ${userData.keys}');
      if (!mounted) {
        print('RecetasScreen: Widget no montado, abortando');
        return;
      }

      final activePlan = userData['active_plan'];
      print('RecetasScreen: Plan activo: $activePlan');

      if (activePlan != null && activePlan['plan_data'] != null) {
        final planData = activePlan['plan_data'];
        print('RecetasScreen: Datos del plan: $planData');
        if (planData['meal_plan'] is Map<String, dynamic>) {
          _parsePlanData(planData['meal_plan']);
        } else {
          print(
              'RecetasScreen: Error - Formato del plan incorrectStoryboard: RecetasScreen incorrecto');
          throw Exception('El formato del plan es incorrecto.');
        }
      } else {
        print('RecetasScreen: Error - No se encontró un plan activo');
        throw Exception('No se encontró un plan activo.');
      }
    } catch (e) {
      print('RecetasScreen: Error al cargar datos del plan: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              '¡Aún no tienes un plan nutricional! Crea uno para comenzar tu viaje saludable.';
        });
      }
    } finally {
      if (mounted) {
        print('RecetasScreen: Finalizando carga de datos, isLoading=false');
        setState(() => _isLoading = false);
      }
    }
  }

  void _parsePlanData(Map<String, dynamic> mealPlanData) {
    print('RecetasScreen: Parseando datos del plan');
    List<Map<String, dynamic>> processCategory(String category) {
      final List<Map<String, dynamic>> options = [];
      if (mealPlanData[category] is List) {
        print(
            'RecetasScreen: Procesando categoría $category con ${mealPlanData[category].length} elementos');
        for (var item in (mealPlanData[category] as List)) {
          if (item is Map) {
            options.add({
              'name': item['opcion'] as String? ?? 'Opción inválida',
              'image_url': item['details']?['image_url'],
              'details': item['details'],
            });
          }
        }
      } else {
        print('RecetasScreen: Advertencia - $category no es una lista');
      }
      return options;
    }

    setState(() {
      _breakfastOptions = processCategory('desayuno');
      _lunchOptions = processCategory('almuerzo');
      _dinnerOptions = processCategory('cena');
      _recommendations =
          List<String>.from(mealPlanData['recomendaciones'] ?? []);
      print(
          'RecetasScreen: Opciones parseadas - Desayuno: ${_breakfastOptions.length}, Almuerzo: ${_lunchOptions.length}, Cena: ${_dinnerOptions.length}, Recomendaciones: ${_recommendations.length}');
    });

    _fetchImagesForPlan();
  }

  Future<void> _fetchImagesForPlan() async {
    print('RecetasScreen: Asignando imagen estática genérica');
    const genericImageUrl =
        'https://placehold.co/600x400/cccccc/ffffff?text=Imagen+Generica';
    final allOptions = [
      ..._breakfastOptions,
      ..._lunchOptions,
      ..._dinnerOptions
    ];

    for (var option in allOptions) {
      if (option['image_url'] == null) {
        print(
            'RecetasScreen: Asignando imagen genérica para ${option['name']}');
        if (mounted) {
          setState(() {
            option['image_url'] = genericImageUrl;
          });
        }
      }
    }
    print('RecetasScreen: Finalizada asignación de imágenes');
  }

  @override
  void dispose() {
    print('RecetasScreen: Disposing TabController');
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'RecetasScreen: Construyendo UI, isLoading=$_isLoading, errorMessage=$_errorMessage');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recetas',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FrutiaColors.accent, FrutiaColors.accent2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: FrutiaColors.primaryBackground,
        elevation: 0,
        foregroundColor: FrutiaColors.primaryText,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: FrutiaColors.secondaryText,
          indicatorColor: FrutiaColors.accent,
          labelStyle:
              GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Desayuno'),
            Tab(text: 'Almuerzo'),
            Tab(text: 'Cena'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: FrutiaColors.accent),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando tus recetas...',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: FrutiaColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms)
          : _errorMessage.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FrutiaColors.primaryBackground,
                        FrutiaColors.secondaryBackground.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu_outlined,
                          color: FrutiaColors.accent,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Personaliza tu dieta con recetas saludables adaptadas a ti.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: FrutiaColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            print(
                                'RecetasScreen: Navegando a CreatePlanScreen');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuestionnaireFlow(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FrutiaColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          child: Text(
                            'Crear Mi Plan',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate().scale(delay: 200.ms, duration: 300.ms),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            print('RecetasScreen: Reintentando carga de datos');
                            _loadPlanData();
                          },
                          child: Text(
                            'Reintentar',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: FrutiaColors.accent2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    MealListView(items: _breakfastOptions),
                    MealListView(items: _lunchOptions),
                    MealListView(items: _dinnerOptions),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class MealListView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const MealListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    print('MealListView: Construyendo lista con ${items.length} elementos');
    if (items.isEmpty) {
      print('MealListView: Lista vacía, mostrando mensaje');
      return Center(
        child: Text(
          "No hay opciones de comida.",
          style: GoogleFonts.lato(
            fontSize: 18,
            color: FrutiaColors.secondaryText,
          ),
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title = item['name'] ?? 'Sin nombre';
        final imageUrl = item['image_url'] as String?;

        print(
            'MealListView: Renderizando elemento $index: $title, imageUrl=$imageUrl');
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: InkWell(
            onTap: () {
              final recipeDetails = item['details'];
              print('MealListView: onTap para $title, details=$recipeDetails');
              if (recipeDetails != null &&
                  recipeDetails is Map<String, dynamic>) {
                print(
                    'MealListView: Navegando a MyPlanDetailsScreen para $title');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MyPlanDetailsScreen(recipeData: item)),
                );
              } else {
                print('MealListView: No se navega, details no válido');
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: (imageUrl != null)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            return progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print(
                                'MealListView: Error cargando imagen para $title: $error');
                            return const Icon(Icons.no_photography_outlined,
                                color: Colors.grey, size: 40);
                          },
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: FrutiaColors.accent)),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: FrutiaColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (100 * index).ms)
            .slideY(begin: 0.5, curve: Curves.easeOut);
      },
    );
  }
}

class RecommendationsListView extends StatelessWidget {
  final List<String> items;
  const RecommendationsListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    print(
        'RecommendationsListView: Construyendo lista con ${items.length} recomendaciones');
    if (items.isEmpty) {
      print('RecommendationsListView: Lista vacía, mostrando mensaje');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: FrutiaColors.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No hay recomendaciones",
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FrutiaColors.secondaryText,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FrutiaColors.accent.withOpacity(0.05),
                FrutiaColors.accent2.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: FrutiaColors.accent.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: FrutiaColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FrutiaColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  items[index],
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    height: 1.5,
                    color: FrutiaColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideX(
              begin: 0.3,
              curve: Curves.easeOutQuart,
            );
      },
    );
  }
}
