import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/services/plan_service.dart';

class PremiumRecetasScreen extends StatefulWidget {
  const PremiumRecetasScreen({Key? key}) : super(key: key);

  @override
  _PremiumRecetasScreenState createState() => _PremiumRecetasScreenState();
}

class _PremiumRecetasScreenState extends State<PremiumRecetasScreen>
    with SingleTickerProviderStateMixin {
  final PlanService _planService = PlanService();
  late final TextEditingController _searchController;
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;
  List<InspirationRecipe> _allRecipes = [];
  List<MealFormula> _allFormulas = [];
  List<InspirationRecipe> _filteredRecipes = [];
  String _activeFilter = 'Todos';
  List<String> _mealFilters = ['Todos'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_performFiltering);
    _tabController = TabController(length: 1, vsync: this);
    _fetchPlanData();
  }

  Future<void> _fetchPlanData() async {
    try {
      final planData = await _planService.getCurrentPlan();
      if (!mounted) return;

      List<InspirationRecipe> foundRecipes = [];
      List<String> mealNames = [];

      if (planData?.nutritionPlan.meals != null) {
        // Usamos .entries para obtener tanto el nombre de la comida como sus datos
        for (var entry in planData!.nutritionPlan.meals.entries) {
          final String mealName = entry.key; // "Desayuno", "Almuerzo", etc.
          final Meal meal = entry.value;

          mealNames.add(mealName); // Guardamos el nombre para los filtros

          if (meal.suggestedRecipes.isNotEmpty) {
            // Asignamos el nombre de la comida a cada una de sus recetas
            for (var recipe in meal.suggestedRecipes) {
              recipe.mealType = mealName; // ¡Aquí está la magia!
            }
            foundRecipes.addAll(meal.suggestedRecipes);
          }
        }
      }

      setState(() {
        _allRecipes = foundRecipes;
        _filteredRecipes = _allRecipes;
        // Creamos la lista de filtros dinámicamente
        _mealFilters = ['Todos', ...mealNames];
        _isLoading = false;
      });
      debugPrint('Recipes loaded from meals: ${_allRecipes.length}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Error al cargar recetas: ${e.toString()}";
        _isLoading = false;
      });
      debugPrint('Error loading plan data: $e');
    }
  }

  void _performFiltering() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        final titleMatch = recipe.title.toLowerCase().contains(query);
        // Esta línea ahora funciona gracias al cambio en _fetchPlanData
        final categoryMatch =
            _activeFilter == 'Todos' || recipe.mealType == _activeFilter;
        return titleMatch && categoryMatch;
      }).toList();
    });
  }

  void _setActiveFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _performFiltering();
    });
  }

  void _showInspirationFor(String mealType) {
    _setActiveFilter(mealType);
    _tabController.animateTo(0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: FrutiaColors.accent));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    return DefaultTabController(
      length: 1,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
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
                'Mis Recetas',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.2),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                unselectedLabelStyle: GoogleFonts.lato(
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Inspiración'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _InspiracionTab(
              recipes: _filteredRecipes,
              searchController: _searchController,
              activeFilter: _activeFilter,
              onFilterChanged: _setActiveFilter,
              filters: _mealFilters,
            ).animate().fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}

class _InspiracionTab extends StatelessWidget {
  final List<InspirationRecipe> recipes;
  final TextEditingController searchController;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final List<String> filters;

  const _InspiracionTab({
    required this.recipes,
    required this.searchController,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar recetas...',
              hintStyle: GoogleFonts.lato(
                color: FrutiaColors.secondaryText,
              ),
              prefixIcon: const Icon(Icons.search, color: FrutiaColors.accent),
              filled: true,
              fillColor: FrutiaColors.secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return ChoiceChip(
                label: Text(
                  filters[index],
                  style: GoogleFonts.poppins(
                    color: activeFilter == filters[index]
                        ? Colors.white
                        : FrutiaColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: activeFilter == filters[index],
                onSelected: (_) => onFilterChanged(filters[index]),
                selectedColor: FrutiaColors.accent,
                backgroundColor: FrutiaColors.secondaryBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms);
            },
          ),
        ),
        const SizedBox(height: 16),
        // --- WIDGET DE TÍTULO CON BORDE DEGRADADO ---
        const _GradientTitle(title: 'Tus recetas de hoy'),
        const SizedBox(height: 16),
        Expanded(
          child: recipes.isEmpty
              ? Center(
                  child: Text(
                    'No se encontraron recetas con ese filtro.',
                    style: GoogleFonts.lato(
                      color: FrutiaColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) => _RecipeCard(
                    recipe: recipes[index],
                  ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms),
                ),
        ),
      ],
    );
  }
}

// --- NUEVO WIDGET PARA EL TÍTULO CON BORDE ---
class _GradientTitle extends StatelessWidget {
  final String title;
  const _GradientTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4), // Grosor del borde
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [FrutiaColors.accent, FrutiaColors.accent2],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        color: FrutiaColors.primaryBackground, // Color de fondo de la pantalla
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FrutiaColors.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _MisFormulasTab extends StatelessWidget {
  final List<MealFormula> formulas;
  final ValueChanged<String> onShowInspiration;

  const _MisFormulasTab({
    required this.formulas,
    required this.onShowInspiration,
  });

  @override
  Widget build(BuildContext context) {
    return formulas.isEmpty
        ? Center(
            child: Text(
              'No hay fórmulas disponibles.',
              style: GoogleFonts.lato(
                color: FrutiaColors.secondaryText,
                fontSize: 16,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: formulas.length,
            itemBuilder: (context, index) {
              return _FormulaCard(
                formula: formulas[index],
                onShowInspiration: () =>
                    onShowInspiration(formulas[index].mealType),
              ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms);
            },
          );
  }
}

class _FormulaCard extends StatefulWidget {
  final MealFormula formula;
  final VoidCallback onShowInspiration;

  const _FormulaCard({required this.formula, required this.onShowInspiration});

  @override
  __FormulaCardState createState() => __FormulaCardState();
}

class __FormulaCardState extends State<_FormulaCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: FrutiaColors.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ListTile(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              leading: CircleAvatar(
                backgroundColor: widget.formula.color.withOpacity(0.1),
                child: Icon(widget.formula.icon, color: widget.formula.color),
              ),
              title: Text(
                widget.formula.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primaryText,
                ),
              ),
              trailing: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: FrutiaColors.accent,
              ),
            ),
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    const Divider(),
                    ...widget.formula.categories
                        .map((category) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.title,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: FrutiaColors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...category.options
                                      .map((option) => ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            leading: Icon(
                                              option.icon,
                                              size: 20,
                                              color: FrutiaColors.accent,
                                            ),
                                            title: Text(
                                              option.description,
                                              style: GoogleFonts.lato(
                                                color:
                                                    FrutiaColors.secondaryText,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ],
                              ),
                            ))
                        .toList(),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: widget.onShowInspiration,
                      icon: const Icon(Icons.lightbulb_outline, size: 18),
                      label: Text(
                        'Ver Ideas para ${widget.formula.mealType}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: widget.formula.color,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final InspirationRecipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe)),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen estática de assets con overlay oscuro
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
              child: Image.asset(
                'assets/images/fondoAppFrutia.webp',
                fit: BoxFit.cover,
              ),
            ),

            // Gradiente encima de la imagen
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Contenido del card
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('${recipe.readyInMinutes} min',
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 8),
                      Icon(Icons.local_fire_department_outlined,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '~${recipe.calories} kcal',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final InspirationRecipe recipe;
  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extraemos los pasos de `analyzedInstructions` para una mejor visualización
    final List<String> steps = recipe.analyzedInstructions.isNotEmpty &&
            recipe.analyzedInstructions[0]['steps'] != null
        ? (recipe.analyzedInstructions[0]['steps'] as List)
            .map<String>((step) => step['step'].toString())
            .toList()
        : recipe.instructions
            .split(RegExp(r'\. |\n')); // Fallback a instrucciones simples

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            stretch: true,
            backgroundColor: FrutiaColors.accent,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 48.0, vertical: 12.0),
              title: Text(
                recipe.title,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 8.0,
                    children: [
                      _InfoChip(
                          icon: Icons.timer_outlined,
                          text: '${recipe.readyInMinutes} min'),
                      _InfoChip(
                          icon: Icons.local_fire_department_outlined,
                          text: '~${recipe.calories} kcal'),
                      _InfoChip(
                          icon: Icons.groups_outlined,
                          text: '${recipe.servings} porciones'),
                    ],
                  ),
                  const Divider(height: 40),
                  // En el método build de RecipeDetailScreen, busca esta parte:

                  _DetailSection(
                    title: 'Ingredientes',
                    icon: Icons.add_shopping_cart_outlined,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.extendedIngredients.map((item) {
                        // ▼▼▼ REEMPLAZA ESTAS LÍNEAS ▼▼▼
                        // final amount = item['amount']?.toStringAsFixed(1) ?? '';
                        // final unit = item['unitShort'] ?? item['unit'] ?? '';
                        // final name = item['name'] ?? 'Ingrediente';
                        // return _ChecklistItem(text: name, quantity: '$amount $unit');
                        // ▲▲▲ POR ESTAS LÍNEAS DE ABAJO ▼▼▼

                        final name = item['name'] as String? ?? 'Ingrediente';
                        final quantity = item['original'] as String? ??
                            ''; // <-- Usamos el campo 'original'

                        return _ChecklistItem(text: name, quantity: quantity);
                      }).toList(),
                    ),
                  ),
                  _DetailSection(
                    title: 'Preparación',
                    icon: Icons.soup_kitchen_outlined,
                    content: Column(
                      children: steps.asMap().entries.map((entry) {
                        int idx = entry.key + 1;
                        String step = entry.value;
                        if (step.trim().isEmpty)
                          return const SizedBox
                              .shrink(); // No mostrar pasos vacíos
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                FrutiaColors.accent.withOpacity(0.1),
                            foregroundColor: FrutiaColors.accent,
                            child: Text('$idx'),
                            radius: 16,
                          ),
                          title: Text(step,
                              style:
                                  GoogleFonts.lato(fontSize: 16, height: 1.5)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. WIDGETS DE AYUDA ---
// Estos son los componentes que usa la pantalla para organizarse.

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  const _DetailSection(
      {required this.title, required this.icon, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: FrutiaColors.accent.withOpacity(0.1),
              child: Icon(icon, color: FrutiaColors.accent),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primaryText),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: content,
        ),
        const Divider(height: 40),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  final String? quantity;
  const _ChecklistItem({required this.text, this.quantity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline,
              color: FrutiaColors.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                  fontSize: 16, color: FrutiaColors.primaryText, height: 1.4),
            ),
          ),
          if (quantity != null && quantity!.trim().isNotEmpty)
            Text(
              quantity!,
              style: GoogleFonts.lato(
                  fontSize: 16, color: FrutiaColors.secondaryText),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: FrutiaColors.accent),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                color: FrutiaColors.primaryText,
                fontSize: 14),
          ),
        ],
      ),
    );
  }
}
