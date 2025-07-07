import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- MODELOS DE DATOS PARA ESTA PANTALLA ---

// Modelo para un detalle de precio (no se usa con el nuevo plan, pero se mantiene la estructura)
class PriceDetail {
  final String store;
  final double price;
  final String currency;
  PriceDetail(
      {required this.store, required this.price, required this.currency});
}

// Modelo para un ingrediente individual
class Ingredient {
  final String item;
  final String quantity;
  final String? imageUrl;
  final List<PriceDetail> prices;

  Ingredient({
    required this.item,
    required this.quantity,
    this.imageUrl,
    this.prices = const [],
  });

  // Factory para crear un Ingrediente desde una MealOption de tu plan principal
  factory Ingredient.fromMealOption(MealOption option) {
    String item = option.name;
    String quantity = '';

    // Extrae la cantidad del nombre, ej: "Pollo (200g)" -> item: "Pollo", quantity: "200g"
    final regex = RegExp(r'\((.*?)\)');
    final match = regex.firstMatch(option.name);
    if (match != null) {
      item = option.name.substring(0, match.start).trim();
      quantity = match.group(1) ?? '';
    }

    return Ingredient(
      item: item,
      quantity: quantity,
      imageUrl: option.imageUrl,
      prices: [], // El nuevo modelo de IA no incluye precios por ingrediente
    );
  }
}

// Modelo para el item en la UI de la lista de compras
class ShoppingIngredientItem {
  final Ingredient ingredientData;
  bool isChecked;
  final String mealType;

  ShoppingIngredientItem({
    required this.ingredientData,
    this.isChecked = false,
    required this.mealType,
  });

  String get item => ingredientData.item;
  String get quantity => ingredientData.quantity;
  String? get imageUrl => ingredientData.imageUrl;
  List<PriceDetail> get prices => ingredientData.prices;
}

// --- PANTALLA PRINCIPAL DE COMPRAS ---
class ComprasScreen extends StatefulWidget {
  const ComprasScreen({Key? key}) : super(key: key);

  @override
  _ComprasScreenState createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  List<ShoppingIngredientItem> _ingredients = [];
  bool _isLoading = true;
  String? _error;
  final PlanService _planService = PlanService();
  late SharedPreferences _prefs;

  final Map<String, bool> _isCategoryExpanded = {};
  final Map<String, String> _categoryImages = {
    'Desayuno': 'assets/images/desayun.webp',
    'Almuerzo': 'assets/images/almuerzo.webp',
    'Cena': 'assets/images/cena.webp',
    'Shake': 'assets/images/snack.webp',
    // Se pueden añadir más si la API los devuelve
  };

  @override
  void initState() {
    super.initState();
    _initAndLoadIngredients();
  }

  Future<void> _initAndLoadIngredients() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadIngredientsFromPlan();
  }

  // --- FUNCIÓN PRINCIPAL REESCRITA PARA SER DINÁMICA ---
  Future<void> _loadIngredientsFromPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Hacemos que la variable `planData` pueda aceptar un valor nulo.
      final MealPlanData? planData = await _planService.getCurrentPlan();
      if (!mounted) return;

      // 2. Añadimos una comprobación para manejar el caso en que no se reciba un plan.
      if (planData == null) {
        throw Exception('No se encontró un plan de alimentación activo.');
      }

      // Si llegamos aquí, sabemos que planData no es nulo y podemos continuar.
      final List<ShoppingIngredientItem> tempShoppingList = [];

      // Iteramos sobre la nueva estructura del plan (nutritionPlan.meals)
      planData.nutritionPlan.meals.forEach((mealType, mealCategories) {
        // Inicializamos la categoría como expandida si tiene items
        if (mealCategories.isNotEmpty &&
            !_isCategoryExpanded.containsKey(mealType)) {
          _isCategoryExpanded[mealType] = true;
        }

        for (var category in mealCategories) {
          for (var option in category.options) {
            final ingredient = Ingredient.fromMealOption(option);
            // Evitamos duplicados exactos dentro de la misma categoría de comida
            if (!tempShoppingList.any((item) =>
                item.item == ingredient.item && item.mealType == mealType)) {
              tempShoppingList.add(
                ShoppingIngredientItem(
                  ingredientData: ingredient,
                  mealType: mealType,
                ),
              );
            }
          }
        }
      });

      // Cargamos el estado 'checked' desde la memoria local
      for (var ingredient in tempShoppingList) {
        final uniqueKey = _getIngredientUniqueKey(ingredient);
        ingredient.isChecked = _prefs.getBool(uniqueKey) ?? false;
      }

      setState(() {
        _ingredients = tempShoppingList;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getIngredientUniqueKey(ShoppingIngredientItem ingredient) {
    return 'shopping_item_${ingredient.mealType.replaceAll(' ', '_').toLowerCase()}_${ingredient.item.replaceAll(' ', '_').toLowerCase()}_${ingredient.quantity.replaceAll(' ', '_').toLowerCase()}';
  }

  void _toggleIngredientCheck(ShoppingIngredientItem ingredient) {
    setState(() {
      ingredient.isChecked = !ingredient.isChecked;
      final uniqueKey = _getIngredientUniqueKey(ingredient);
      _prefs.setBool(uniqueKey, ingredient.isChecked);
    });
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
          'Lista de compras',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: FrutiaColors.accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Error al cargar ingredientes',
                style: GoogleFonts.lato(
                    fontSize: 20,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontSize: 16, color: FrutiaColors.secondaryText),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadIngredientsFromPlan,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ingredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 60, color: FrutiaColors.secondaryText.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Tu lista de compras está vacía.',
                style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: FrutiaColors.secondaryText)),
            const SizedBox(height: 8),
            Text('Genera un plan de alimentación para obtener tu lista.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontSize: 16,
                    color: FrutiaColors.secondaryText.withOpacity(0.7))),
          ],
        ),
      );
    }

    final groupedIngredients = groupBy(_ingredients, (item) => item.mealType);
    final orderedCategories = groupedIngredients.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: orderedCategories.length,
      itemBuilder: (context, index) {
        final category = orderedCategories[index];
        final categoryItems = groupedIngredients[category]!;
        categoryItems.sort((a, b) => a.item.compareTo(b.item));
        return _buildCategorySection(category, categoryItems);
      },
    );
  }

  Widget _buildCategorySection(
      String category, List<ShoppingIngredientItem> items) {
    final isExpanded = _isCategoryExpanded[category] ?? false;

    return Column(
      children: [
        _buildCategoryHeader(
          category: category,
          isExpanded: isExpanded,
          itemCount: items.length,
          checkedCount: items.where((item) => item.isChecked).length,
          onTap: () {
            setState(() {
              _isCategoryExpanded[category] = !isExpanded;
            });
          },
        ),
        AnimatedCrossFade(
          firstChild: Column(
            children: items.map((item) => _buildIngredientCard(item)).toList(),
          ),
          secondChild: Container(),
          crossFadeState:
              isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryHeader({
    required String category,
    required bool isExpanded,
    required int itemCount,
    required int checkedCount,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Card(
          elevation: 6.0,
          shadowColor: Colors.black.withOpacity(0.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Image.asset(
                _categoryImages[category] ??
                    'assets/images/fondoAppFrutia.webp', // Fallback image
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(2.0, 2.0))
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$checkedCount/$itemCount',
                        style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedRotation(
                      turns: isExpanded ? 0.0 : -0.5,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.expand_more,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientCard(ShoppingIngredientItem ingredient) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: FrutiaColors.accent.withOpacity(0.2), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (ingredient.imageUrl != null &&
                    ingredient.imageUrl!.isNotEmpty) {
                  _showFullScreenImage(context, ingredient.imageUrl!);
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: FrutiaColors.accent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (ingredient.imageUrl != null &&
                          ingredient.imageUrl!.isNotEmpty)
                      ? Image.network(
                          ingredient.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: FrutiaColors.accent));
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/images/fondoAppFrutia.webp',
                                  fit: BoxFit.cover),
                        )
                      : Image.asset('assets/images/fondoAppFrutia.webp',
                          fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${ingredient.item} ${ingredient.quantity.isNotEmpty ? '(${ingredient.quantity})' : ''}',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: ingredient.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: ingredient.isChecked
                      ? FrutiaColors.secondaryText
                      : FrutiaColors.primaryText,
                ),
              ),
            ),
            Checkbox(
              value: ingredient.isChecked,
              onChanged: (_) => _toggleIngredientCheck(ingredient),
              activeColor: FrutiaColors.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}
