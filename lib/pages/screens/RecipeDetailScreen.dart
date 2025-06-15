import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/pages/screens/ModificationsScreen.dart';
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
    print('MyPlanPage: Inicializando estado');
    _tabController = TabController(length: 4, vsync: this);
    _loadPlanData();
  }

  Future<void> _loadPlanData() async {
    print('MyPlanPage: Iniciando carga de datos del plan');
    try {
      final userData = await AuthService().getProfile();
      print('MyPlanPage: Datos del usuario obtenidos: ${userData.keys}');
      if (!mounted) {
        print('MyPlanPage: Widget no montado, abortando');
        return;
      }

      final activePlan = userData['active_plan'];
      print('MyPlanPage: Plan activo: $activePlan');

      if (activePlan != null && activePlan['plan_data'] != null) {
        final planData = activePlan['plan_data'];
        print('MyPlanPage: Datos del plan: $planData');
        if (planData['meal_plan'] is Map<String, dynamic>) {
          _parsePlanData(planData['meal_plan']);
        } else {
          print('MyPlanPage: Error - Formato del plan incorrecto');
          throw Exception('El formato del plan es incorrecto.');
        }
      } else {
        print('MyPlanPage: Error - No se encontró un plan activo');
        throw Exception('No se encontró un plan activo.');
      }
    } catch (e) {
      print('MyPlanPage: Error al cargar datos del plan: $e');
      if (mounted) setState(() => _errorMessage = "Error: ${e.toString()}");
    } finally {
      if (mounted) {
        print('MyPlanPage: Finalizando carga de datos, isLoading=false');
        setState(() => _isLoading = false);
      }
    }
  }

  void _parsePlanData(Map<String, dynamic> mealPlanData) {
    print('MyPlanPage: Parseando datos del plan');
    List<Map<String, dynamic>> processCategory(String category) {
      final List<Map<String, dynamic>> options = [];
      if (mealPlanData[category] is List) {
        print(
            'MyPlanPage: Procesando categoría $category con ${mealPlanData[category].length} elementos');
        for (var item in (mealPlanData[category] as List)) {
          if (item is Map) {
            options.add({
              'name': item['opcion'] as String? ?? 'Opción inválida',
              'image_url': item['details']
                  ?['image_url'], // Puede ser null inicialmente
              'details': item['details'],
            });
          }
        }
      } else {
        print('MyPlanPage: Advertencia - $category no es una lista');
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
          'MyPlanPage: Opciones parseadas - Desayuno: ${_breakfastOptions.length}, Almuerzo: ${_lunchOptions.length}, Cena: ${_dinnerOptions.length}, Recomendaciones: ${_recommendations.length}');
    });

    // Asignar imagen estática genérica
    _fetchImagesForPlan();
  }

  Future<void> _fetchImagesForPlan() async {
    print('MyPlanPage: Asignando imagen estática genérica');
    const genericImageUrl =
        'https://placehold.co/600x400/cccccc/ffffff?text=Imagen+Generica';
    final allOptions = [
      ..._breakfastOptions,
      ..._lunchOptions,
      ..._dinnerOptions
    ];

    for (var option in allOptions) {
      if (option['image_url'] == null) {
        print('MyPlanPage: Asignando imagen genérica para ${option['name']}');
        if (mounted) {
          setState(() {
            option['image_url'] = genericImageUrl;
          });
        }
      }
    }
    print('MyPlanPage: Finalizada asignación de imágenes');
  }

  @override
  void dispose() {
    print('MyPlanPage: Disposing TabController');
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'MyPlanPage: Construyendo UI, isLoading=$_isLoading, errorMessage=$_errorMessage');
    return Scaffold(
      appBar: AppBar(
        title: Text('Recetas (aun en contruccion)',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: FrutiaColors.primaryBackground,
        elevation: 0,
        foregroundColor: FrutiaColors.primaryText,
        bottom: TabBar(
          controller: _tabController,
          labelColor: FrutiaColors.accent,
          indicatorColor: FrutiaColors.accent,
          tabs: const [
            Tab(text: 'Desayuno'),
            Tab(text: 'Almuerzo'),
            Tab(text: 'Cena'),
            Tab(text: 'Consejos'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: FrutiaColors.accent))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    MealListView(items: _breakfastOptions),
                    MealListView(items: _lunchOptions),
                    MealListView(items: _dinnerOptions),
                    RecommendationsListView(items: _recommendations),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print('MyPlanPage: Navegando a ModificationsScreen');
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ModificationsScreen()));
        },
        label: const Text('Modificar'),
        icon: const Icon(Icons.edit),
        backgroundColor: FrutiaColors.accent,
      ),
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
      return const Center(child: Text("No hay opciones de comida."));
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
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: FrutiaColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: FrutiaColors.accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(items[index],
                      style: const TextStyle(fontSize: 15, height: 1.4))),
            ],
          ),
        );
      },
    );
  }
}
