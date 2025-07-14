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
      setState(() {
        _allRecipes = planData?.recipes ?? [];
        _allFormulas = planData?.formulas ?? [];
        _filteredRecipes = _allRecipes;
        _isLoading = false;
      });
      debugPrint('Recipes loaded: ${_allRecipes.length}');
      debugPrint('Formulas loaded: ${_allFormulas.length}');
    } catch (e) {
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

  const _InspiracionTab({
    required this.recipes,
    required this.searchController,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> filters = ['Todos', 'Desayuno', 'Almuerzo', 'Cena'];
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
              prefixIcon: Icon(Icons.search, color: FrutiaColors.accent),
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
        shadowColor: Colors.black.withOpacity(0.5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: recipe.id ?? recipe.title,
              child: Image.asset(
                'assets/images/fondoAppFrutia.webp',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.4),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
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
                      Text(
                        '${recipe.prepTimeMinutes ?? 30} min',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
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
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [FrutiaColors.accent, FrutiaColors.accent2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FlexibleSpaceBar(
                background: Hero(
                  tag: recipe.id ?? recipe.title,
                  child: Image.asset(
                    'assets/images/fondoAppFrutia.webp',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
              ),
            ),
            leading: BackButton(color: Colors.white),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: FrutiaColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description ?? 'Deliciosa receta para tu plan.',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: FrutiaColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _InfoChip(
                        icon: Icons.timer_outlined,
                        text: '${recipe.prepTimeMinutes ?? 30} min',
                        color: FrutiaColors.accent,
                      ),
                      _InfoChip(
                        icon: Icons.local_fire_department_outlined,
                        text: '~${recipe.calories} kcal',
                        color: FrutiaColors.accent,
                      ),
                      _InfoChip(
                        icon: Icons.restaurant_menu_outlined,
                        text: recipe.mealType,
                        color: FrutiaColors.accent,
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  _DetailSection(
                    title: 'Cómo se Ajusta a tu Plan',
                    icon: Icons.link_outlined,
                    iconColor: FrutiaColors.progress,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.planComponents
                          .map((item) => _ChecklistItem(text: item))
                          .toList(),
                    ),
                  ),
                  _DetailSection(
                    title: 'Ingredientes Adicionales',
                    icon: Icons.add_shopping_cart_outlined,
                    iconColor: Colors.orange,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.additionalIngredients
                          .map((item) => _ChecklistItem(
                                text: item.name,
                                quantity: item.quantity,
                              ))
                          .toList(),
                    ),
                  ),
                  _DetailSection(
                    title: 'Preparación',
                    icon: Icons.soup_kitchen_outlined,
                    iconColor: Colors.purple,
                    content: Column(
                      children: recipe.steps.asMap().entries.map((entry) {
                        int idx = entry.key + 1;
                        String step = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text('$idx'),
                            radius: 15,
                            backgroundColor:
                                FrutiaColors.accent.withOpacity(0.1),
                            foregroundColor: FrutiaColors.accent,
                          ),
                          title: Text(
                            step,
                            style: GoogleFonts.lato(
                              color: FrutiaColors.primaryText,
                            ),
                          ),
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

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget content;
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.primaryText,
              ),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: FrutiaColors.accent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: FrutiaColors.primaryText,
              ),
            ),
          ),
          if (quantity != null)
            Text(
              quantity!,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: FrutiaColors.secondaryText,
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            FrutiaColors.accent2.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: FrutiaColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
