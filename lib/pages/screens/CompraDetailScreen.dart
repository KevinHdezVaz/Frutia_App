import 'package:Frutia/l10n/app_localizations.dart';
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

  factory Ingredient.fromExtended(
      Map<String, dynamic> extended, AppLocalizations l10n) {
    return Ingredient(
      item: extended['name'] as String? ?? l10n.defaultIngredientName,
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

  String? _currencySymbol;
  final Map<String, bool> _isCategoryExpanded = {};

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
      final l10n = AppLocalizations.of(context)!;

      if (planData == null) {
        throw Exception(l10n.noActivePlanError);
      }

      final String? currency = planData.nutritionPlan.currencySymbol;
      final List<ShoppingIngredientItem> tempShoppingList = [];

      planData.nutritionPlan.meals.forEach((mealTypeKey, meal) {
        // Traducir mealTypeKey para usar como categoría en la lista
        final translatedMealType = getLocalizedMealTitle(mealTypeKey, l10n);

        for (var category in meal.components) {
          for (var option in category.options) {
            final ingredient = Ingredient.fromMealOption(option);
            if (!tempShoppingList.any((item) =>
                item.item == ingredient.item &&
                item.mealType == translatedMealType)) {
              tempShoppingList.add(
                ShoppingIngredientItem(
                  ingredientData: ingredient,
                  mealType: translatedMealType,
                ),
              );
            }
          }
        }

        for (var recipe in meal.suggestedRecipes) {
          for (var extIngredient in recipe.extendedIngredients) {
            final ingredient = Ingredient.fromExtended(
                extIngredient as Map<String, dynamic>, l10n);
            if (!tempShoppingList.any((item) =>
                item.item == ingredient.item &&
                item.mealType == translatedMealType)) {
              tempShoppingList.add(
                ShoppingIngredientItem(
                  ingredientData: ingredient,
                  mealType: translatedMealType,
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
        _currencySymbol = currency;
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

  String getLocalizedMealTitle(String backendKey, AppLocalizations l10n) {
    final lower = backendKey.toLowerCase().trim();
    switch (lower) {
      case 'breakfast':
        return l10n.breakfast;
      case 'lunch':
        return l10n.lunch;
      case 'dinner':
        return l10n.dinner;
      case 'snack_am':
      case 'morning snack':
        return l10n.snackAM;
      case 'snack_pm':
      case 'afternoon snack':
        return l10n.snackPM;
      default:
        return backendKey
            .split(' ')
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join(' ');
    }
  }

  // ⭐ NUEVA VERSIÓN: Insensible a mayúsculas y más variantes
  String getLocalizedFoodName(String backendName, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'es') {
      return backendName.trim();
    }

    final String input = backendName.trim().toLowerCase();

    // Mapa base en minúsculas para búsqueda robusta
    const Map<String, String> esToEn = {
      'huevo entero': 'Whole egg',
      'huevos enteros': 'Whole eggs',
      'claras + huevo entero': 'Egg whites + Whole egg',
      'claras pasteurizadas': 'Pasteurized egg whites',
      'pechuga de pollo': 'Chicken breast',
      'pollo muslo': 'Chicken thigh',
      'pollo muslo con piel': 'Chicken thigh with skin',
      'carne molida': 'Ground beef',
      'carne molida 80/20': 'Ground beef 80/20',
      'carne de res magra': 'Lean beef',
      'atún en lata': 'Canned tuna',
      'atún fresco': 'Fresh tuna',
      'salmón fresco': 'Fresh salmon',
      'pescado blanco': 'White fish',
      'pechuga de pavo': 'Turkey breast',
      'yogurt griego': 'Greek yogurt',
      'yogur griego': 'Greek yogurt',
      'yogurt griego alto en proteínas': 'High-protein Greek yogurt',
      'yogur griego alto en proteínas': 'High-protein Greek yogurt',
      'proteína whey': 'Whey protein',
      'proteína en polvo': 'Protein powder',
      'caseína': 'Casein',
      'tofu firme': 'Firm tofu',
      'tempeh': 'Tempeh',
      'seitán': 'Seitan',
      'queso panela': 'Panela cheese',
      'ricotta': 'Ricotta',
      'hamburguesa de lentejas': 'Lentil burger',
      'claras de huevo': 'Egg whites',
      'papa': 'Potato',
      'arroz blanco': 'White rice',
      'camote': 'Sweet potato',
      'fideo': 'Noodles',
      'frijoles': 'Beans',
      'quinua': 'Quinoa',
      'quinoa': 'Quinoa',
      'quinua/quinoa': 'Quinoa',
      'avena': 'Oats',
      'avena orgánica': 'Organic oats',
      'avena / avena orgánica': 'Organic oats',
      'pan integral': 'Whole wheat bread',
      'pan integral artesanal': 'Artisan whole wheat bread',
      'pan integral / pan integral artesanal': 'Whole wheat bread',
      'tortilla de maíz': 'Corn tortilla',
      'tortillas de maíz': 'Corn tortillas',
      'galletas de arroz': 'Rice crackers',
      'crema de arroz': 'Cream of rice',
      'cereal de maíz': 'Corn cereal',
      'pasta integral': 'Whole wheat pasta',
      'aceite de oliva': 'Olive oil',
      'aceite de oliva extra virgen': 'Extra virgin olive oil',
      'aceite de oliva / extra virgen': 'Extra virgin olive oil',
      'aceite de palta': 'Avocado oil',
      'aceite vegetal': 'Vegetable oil',
      'maní': 'Peanuts',
      'mantequilla de maní': 'Peanut butter',
      'mantequilla de maní casera': 'Homemade peanut butter',
      'mantequilla de maní / casera': 'Peanut butter',
      'almendras': 'Almonds',
      'nueces': 'Walnuts',
      'pistachos': 'Pistachios',
      'pecanas': 'Pecans',
      'aguacate': 'Avocado',
      'palta': 'Avocado',
      'aguacate / palta / hass': 'Hass Avocado',
      'aguacate hass': 'Hass avocado',
      'hass': 'Hass avocado',
      'semillas de chía orgánicas': 'Organic chia seeds',
      'linaza orgánica': 'Organic flaxseed',
      'semillas de ajonjolí': 'Sesame seeds',
      'aceitunas': 'Olives',
      'miel': 'Honey',
      'chocolate negro 70%': '70% Dark chocolate',
      'mantequilla': 'Butter',
      'manteca de cerdo': 'Lard',
      'plátano': 'Banana',
      'manzana': 'Apple',
      'naranja': 'Orange',
      'berries (mix orgánico)': 'Berries (organic mix)',
      'mango': 'Mango',
      'papaya': 'Papaya',
      'sandia': 'Watermelon',
      'sandía': 'Watermelon',
      'melón': 'Melon',
      'fresas': 'Strawberries',
      'arándanos': 'Blueberries',
      'moras': 'Blackberries',
      'pera': 'Pear',
      'ensalada mixta': 'Mixed salad',
      'ensalada completa mixta': 'Complete mixed salad',
      'brócoli': 'Broccoli',
      'zanahoria': 'Carrot',
      'ejotes': 'Green beans',
      'espinaca': 'Spinach',
      'espinacas salteadas': 'Sautéed spinach',
      'lechuga': 'Lettuce',
      'pimiento': 'Bell pepper',
      'calabacín': 'Zucchini',
      'tomate': 'Tomato',
      'pepino': 'Cucumber',
      'coliflor': 'Cauliflower',
      'champiñones': 'Mushrooms',
      'bowl de vegetales al vapor': 'Steamed vegetables bowl',
      'ensalada mediterránea': 'Mediterranean salad',
      'vegetales salteados': 'Sautéed vegetables',
      'ensalada verde mixta grande': 'Large mixed green salad',
      'ensalada de vegetales crucíferos': 'Cruciferous vegetables salad',
      'mix de vegetales bajos en carbos': 'Low-carb vegetables mix',
      'tortillas integrales': 'Whole wheat tortillas',
    };

    return esToEn[input] ?? backendName.trim();
  }

  String translatePortion(String portion, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'es') {
      return portion.trim();
    }

    String translated = portion.trim();
    final lower = translated.toLowerCase();

    // Reemplazos de unidades y frases comunes
    translated = translated
        .replaceAll('peso en crudo', 'raw weight')
        .replaceAll('(peso en crudo)', '(raw weight)')
        .replaceAll('peso cocido', 'cooked weight')
        .replaceAll('(peso cocido)', '(cooked weight)')
        .replaceAll('escurrido', 'drained')
        .replaceAll('peso seco', 'dry weight')
        .replaceAll('(peso seco)', '(dry weight)')
        .replaceAll('unidades', 'units')
        .replaceAll('unidads', 'units')
        .replaceAll('unidad', 'unit')
        .replaceAll('uds', 'units')
        .replaceAll('unid.', 'units')
        .replaceAll('unid', 'units')
        .replaceAll('cucharadas', 'tablespoons')
        .replaceAll('cucharada', 'tablespoon')
        .replaceAll('tazas grandes', 'large cups')
        .replaceAll('tazas', 'cups')
        .replaceAll('taza', 'cup');

    return translated;
  }

  // ⭐ Imagen dinámica según categoría traducida
  String _getCategoryImage(String translatedCategory) {
    final lower = translatedCategory.toLowerCase();
    if (lower.contains('desayuno') || lower.contains('breakfast')) {
      return 'assets/images/desayun.webp';
    }
    if (lower.contains('almuerzo') || lower.contains('lunch')) {
      return 'assets/images/almuerzo.webp';
    }
    if (lower.contains('cena') || lower.contains('dinner')) {
      return 'assets/images/cena.webp';
    }
    return 'assets/images/snack.webp'; // Para snacks
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          l10n.shoppingListTitle,
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
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: FrutiaColors.accent));
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
                l10n.errorLoadingIngredients,
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
                child: Text(l10n.retryButton),
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
            Text(l10n.emptyShoppingList,
                style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: FrutiaColors.secondaryText)),
            const SizedBox(height: 8),
            Text(l10n.generatePlanToSeeList,
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
    final translatedCategory = _getLocalizedMealLabel(context, category);
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
                _getCategoryImage(translatedCategory),
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
                        translatedCategory,
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
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
                      angle: isExpanded ? 0 : -3.14159,
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

  Widget _buildIngredientCard(
      ShoppingIngredientItem ingredient, String? currencySymbol) {
    final l10n = AppLocalizations.of(context)!;
    // ⭐ Traducir el nombre del ingrediente
    final displayName = getLocalizedFoodName(ingredient.item, l10n);

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
                      '${displayName} ${ingredient.quantity.isNotEmpty ? '(${translatePortion(ingredient.quantity, l10n)})' : ''}',
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

  String _getLocalizedMealLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('desayuno') || lowerKey.contains('breakfast')) {
      return l10n.breakfast;
    }
    if (lowerKey.contains('almuerzo') ||
        lowerKey.contains('lunch') ||
        lowerKey.contains('comida')) {
      return l10n.lunch;
    }
    if (lowerKey.contains('cena') || lowerKey.contains('dinner')) {
      return l10n.dinner;
    }
    if (lowerKey.contains('snack')) {
      if (lowerKey.contains('mañana') || lowerKey.contains('am')) {
        return l10n.snackAM;
      }
      if (lowerKey.contains('tarde') || lowerKey.contains('pm')) {
        return l10n.snackPM;
      }
      return l10n.snackAM; // fallback
    }
    return key;
  }
}
