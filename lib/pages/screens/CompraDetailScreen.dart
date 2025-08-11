import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- MODELOS DE DATOS PARA ESTA PANTALLA ---

class Ingredient {
  final String item;
  final String quantity;
  final String? imageUrl;
  final List<PriceInfo> prices;

  Ingredient({
    required this.item,
    required this.quantity,
    this.imageUrl,
    this.prices = const [],
  });

  factory Ingredient.fromMealOption(MealOption option) {
    String item = option.name;
    String quantity = '';

    final regex = RegExp(r'\((.*?)\)');
    final match = regex.firstMatch(option.name);
    if (match != null) {
      item = option.name.substring(0, match.start).trim();
      quantity = match.group(1) ?? '';
    }

    return Ingredient(
      item: item,
      quantity: option.portion,
      imageUrl: option.imageUrl,
      prices: option.prices,
    );
  }

  factory Ingredient.fromExtended(Map<String, dynamic> extended) {
    return Ingredient(
      item: extended['name'] as String? ?? 'Ingrediente',
      quantity: extended['original'] as String? ?? '',
      prices: const [],
    );
  }
}

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
  List<PriceInfo> get prices => ingredientData.prices;
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

  // --- CAMBIO 1: Añadir estado para el símbolo de la moneda ---
  String? _currencySymbol;

  final Map<String, bool> _isCategoryExpanded = {};
  final Map<String, String> _categoryImages = {
    'Desayuno': 'assets/images/desayun.webp',
    'Almuerzo': 'assets/images/almuerzo.webp',
    'Cena': 'assets/images/cena.webp',
    'Snacks': 'assets/images/snack.webp',
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

  Future<void> _loadIngredientsFromPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final MealPlanData? planData = await _planService.getCurrentPlan();
      if (!mounted) return;

      if (planData == null) {
        throw Exception('No se encontró un plan de alimentación activo.');
      }

      // --- CAMBIO 2: Extraer y guardar el símbolo de la moneda ---
      final String? currency = planData.nutritionPlan.currencySymbol;

      final List<ShoppingIngredientItem> tempShoppingList = [];

      planData.nutritionPlan.meals.forEach((mealType, meal) {
        for (var category in meal.components) {
          for (var option in category.options) {
            final ingredient = Ingredient.fromMealOption(option);
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

        for (var recipe in meal.suggestedRecipes) {
          for (var extIngredient in recipe.extendedIngredients) {
            final ingredient =
                Ingredient.fromExtended(extIngredient as Map<String, dynamic>);
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

      for (var ingredient in tempShoppingList) {
        final uniqueKey = _getIngredientUniqueKey(ingredient);
        ingredient.isChecked = _prefs.getBool(uniqueKey) ?? false;
      }

      setState(() {
        _ingredients = tempShoppingList;
        _currencySymbol = currency; // Guardar en el estado
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
          decoration: const BoxDecoration(
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
        if (isExpanded)
          ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // --- CAMBIO 3: Pasar el símbolo de la moneda al widget ---
              return _buildIngredientCard(items[index], _currencySymbol);
            },
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
                            const Shadow(
                                blurRadius: 4.0,
                                color: Colors.black54,
                                offset: Offset(2.0, 2.0))
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
                    Transform.rotate(
                      angle:
                          isExpanded ? 0 : -3.14159, // -180 grados en radianes
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

  // --- CAMBIO 4: Actualizar la firma del método ---
  Widget _buildIngredientCard(
      ShoppingIngredientItem ingredient, String? currencySymbol) {
    return GestureDetector(
      onTap: () => _toggleIngredientCheck(ingredient),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: FrutiaColors.accent.withOpacity(0.2), width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                    if (ingredient.prices.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      // --- CAMBIO 5: Usar el símbolo de la moneda ---
                      ...ingredient.prices.map((price) => Text(
                            '${price.store}: ${price.price.toStringAsFixed(2)} ${currencySymbol ?? ''}',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.primaryText,
                            ),
                          )),
                    ]
                  ],
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
      ),
    );
  }
}
