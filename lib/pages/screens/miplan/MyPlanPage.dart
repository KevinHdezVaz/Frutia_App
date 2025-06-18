import 'package:Frutia/model/MealPlanData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/pages/screens/ModificationsScreen.dart';
import 'package:Frutia/pages/screens/miplan/MyPlanDetailsScreen.dart';
import 'package:Frutia/services/plan_service.dart'; // Asegúrate de importar PlanService
import 'package:Frutia/utils/colors.dart';
import 'package:audioplayers/audioplayers.dart';

class MyPlanPage extends StatefulWidget {
  const MyPlanPage({super.key});

  @override
  State<MyPlanPage> createState() => _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;
  String _errorMessage = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PlanService _planService = PlanService(); // Instancia de PlanService

  List<Map<String, dynamic>> _breakfastOptions = [];
  List<Map<String, dynamic>> _lunchOptions = [];
  List<Map<String, dynamic>> _dinnerOptions = [];
  List<Map<String, dynamic>> _snackOptions = []; // <--- NUEVA LISTA PARA SNACKS

  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 5, vsync: this); // <--- CAMBIO AQUÍ: 4 -> 5
    _loadPlanData();
  }

  Future<void> _loadPlanData() async {
    setState(() => _isLoading = true);
    try {
      final mealPlanData = await _planService.getCurrentPlan();
      if (!mounted) return;

      if (mealPlanData == null) {
        throw Exception('No se encontró un plan activo.');
      }

      setState(() {
        _breakfastOptions = mealPlanData.desayunos
            .map((item) => item.toRecipeDataMap())
            .toList();
        _lunchOptions = mealPlanData.almuerzos
            .map((item) => item.toRecipeDataMap())
            .toList();
        _dinnerOptions =
            mealPlanData.cenas.map((item) => item.toRecipeDataMap()).toList();
        // --- ASIGNA LOS SNACKS AQUÍ ---
        _snackOptions = mealPlanData.snacks
            .map((item) => item.toRecipeDataMap())
            .toList(); // <--- NUEVA ASIGNACIÓN
        _recommendations = List<String>.from(mealPlanData.recomendaciones);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'No se pudo cargar el plan. Por favor, intenta de nuevo. Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _parsePlanData(MealPlanData mealPlanData) {
    // Convertir listas de MealItem a Map para compatibilidad con MealListView
    List<Map<String, dynamic>> convertMealItems(List<MealItem> items) {
      return items.map((mealItem) {
        return {
          'name': mealItem.option,
          'image_url':
              'https://placehold.co/600x400/cccccc/ffffff?text=Imagen+Generica', // Placeholder, ajustar si el backend provee image_url
          'details': {
            'description': mealItem.description,
            'calories': mealItem.calories,
            'prep_time_minutes': mealItem.prepTimeMinutes,
            'ingredients': mealItem.ingredients,
            'instructions': mealItem.instructions,
          },
        };
      }).toList();
    }

    setState(() {
      _breakfastOptions = convertMealItems(mealPlanData.desayunos);
      _lunchOptions = convertMealItems(mealPlanData.almuerzos);
      _dinnerOptions = convertMealItems(mealPlanData.cenas);
      _recommendations = List<String>.from(mealPlanData.recomendaciones ?? []);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Plan Nutricional',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: FrutiaColors.primaryText,
          ),
        ),
        backgroundColor: FrutiaColors.primaryBackground,
        elevation: 0,
        foregroundColor: FrutiaColors.primaryText,
        bottom: TabBar(
          controller: _tabController,
          labelColor: FrutiaColors.accent,
          unselectedLabelColor: FrutiaColors.secondaryText,
          indicatorColor: FrutiaColors.accent,
          labelStyle:
              GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Desayuno'),
            Tab(text: 'Almuerzo'),
            Tab(text: 'Cena'),
            Tab(text: 'Snacks'), // <--- NUEVO TAB

            Tab(text: 'Consejos'),
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
                    'Cargando tu plan...',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: FrutiaColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms)
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          color: FrutiaColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadPlanData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FrutiaColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Reintentar',
                          style: GoogleFonts.lato(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    MealListView(items: _breakfastOptions),
                    MealListView(items: _lunchOptions),
                    MealListView(items: _dinnerOptions),
                    MealListView(
                        items: _snackOptions), // <--- NUEVO ITEM PARA SNACKS

                    RecommendationsListView(items: _recommendations),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ModificationsScreen()));
        },
        label: Text(
          'Modificar',
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.edit),
        backgroundColor: FrutiaColors.accent,
        foregroundColor: Colors.white,
      ).animate().fadeIn(delay: 800.ms).scale(duration: 400.ms),
    );
  }
}

class MealListView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const MealListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
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
        final title = item['opcion'] ?? 'Sin nombre';
        final imageUrl = item['image_url'] as String?;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: InkWell(
            onTap: () {
              final recipeDetails = item['details'];
              if (recipeDetails != null &&
                  recipeDetails is Map<String, dynamic>) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MyPlanDetailsScreen(recipeData: item)),
                );
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
                        fontSize: 16, fontWeight: FontWeight.bold),
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
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;

  const RecommendationsListView({
    super.key,
    required this.items,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 28),

          // Lista de items con efecto de onda
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildRecommendationItem(items[index], index);
            },
          ),
          const SizedBox(height: 40)
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_outlined,
              size: 48, color: FrutiaColors.secondaryText.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            emptyStateTitle ?? "No hay recomendaciones",
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: FrutiaColors.secondaryText,
            ),
          ),
          if (emptyStateSubtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              emptyStateSubtitle!,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: FrutiaColors.secondaryText.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildRecommendationItem(String text, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Podrías añadir alguna interacción aquí
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FrutiaColors.accent.withOpacity(0.05),
                FrutiaColors.accent.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: FrutiaColors.accent.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Número de recomendación con estilo
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
              // Texto de la recomendación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        height: 1.5,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tags opcionales podrían ir aquí
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (index % 3 == 0)
                          _buildTag("Salud", Icons.favorite_border),
                        if (index % 2 == 0)
                          _buildTag("Nutrición", Icons.restaurant),
                        _buildTag("Consejo", Icons.lightbulb_outline),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 * index).ms)
        .slideX(
          begin: 0.3,
          curve: Curves.easeOutQuart,
        )
        .then()
        .shake(delay: 200.ms, hz: 2); // Pequeña animación después de aparecer
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FrutiaColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: FrutiaColors.accent),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: FrutiaColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
