import 'package:Frutia/model/MealPlanData.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/pages/screens/ModificationsScreen.dart';
import 'package:Frutia/pages/screens/miplan/MyPlanDetailsScreen.dart';
import 'package:Frutia/services/plan_service.dart';
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
  final PlanService _planService = PlanService();

  List<Map<String, dynamic>> _breakfastOptions = [];
  List<Map<String, dynamic>> _lunchOptions = [];
  List<Map<String, dynamic>> _dinnerOptions = [];
  List<Map<String, dynamic>> _snackOptions = [];

  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        // _breakfastOptions =
        //       mealPlanData.desayunos.map((item) => item.toJson()).toList();
        // _lunchOptions =
        //     mealPlanData.almuerzos.map((item) => item.toJson()).toList();
        // _dinnerOptions =
        //    mealPlanData.cenas.map((item) => item.toJson()).toList();
        //_snackOptions =
        //    mealPlanData.snacks.map((item) => item.toJson()).toList();
        //  _recommendations = List<String>.from(mealPlanData.recomendaciones);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              '¡Aún no tienes un plan nutricional! Crea uno para comenzar tu viaje saludable.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'Mi Plan Nutricional',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
            Tab(text: 'Snacks'),
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
                          'Personaliza tu dieta con opciones saludables adaptadas a ti.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: FrutiaColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
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
                          onPressed: _loadPlanData,
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
                    MealListView(items: _snackOptions),
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

    // --> CAMBIO 3: CONSTRUIMOS LA URL COMPLETA AQUÍ DENTRO
    const String baseUrlApp =
        "https://frutia.aftconta.mx"; // <-- URL Base SIN /api

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        // El mapa 'item' ahora viene del método .toJson() corregido
        final title = item['opcion'] ?? 'Sin nombre';

        // --- ¡AQUÍ ESTÁ LA CORRECCIÓN CLAVE! ---
        // 1. Obtenemos el mapa 'details' de forma segura.
        final details = item['details'] as Map<String, dynamic>? ?? {};
        // 2. Buscamos 'image_url' DENTRO de 'details'.
        final imagePath = details['image_url'] as String?;

        // Construimos la URL absoluta y completa
        final String? fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
            ? baseUrlApp + imagePath
            : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MyPlanDetailsScreen(recipeData: item)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: fullImageUrl != null
                      ? Image.network(
                          fullImageUrl, // Usamos la URL completa
                          fit: BoxFit.fitWidth,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator()),
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.no_photography_outlined,
                                  color: Colors.grey, size: 40),
                        )
                      // Si no hay imagen, muestra un ícono de error
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey, size: 40),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(title,
                      style: GoogleFonts.lato(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.5);
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
        onTap: () {},
        child: Container(
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
            borderRadius: BorderRadius.circular(14),
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
        .shake(delay: 200.ms, hz: 2);
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
