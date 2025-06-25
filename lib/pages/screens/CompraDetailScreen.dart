import 'package:Frutia/utils/constantes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../model/Ingredient.dart';
import '../../model/MealPlanData.dart';
import '../../model/PriceDetail.dart';

// Model for shopping ingredient item
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
  List<PriceDetail> get prices => ingredientData.prices;
  String? get imageUrl => ingredientData.imageUrl;
}

// Main shopping screen
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

  // Category expansion state
  final Map<String, bool> _isCategoryExpanded = {
    'Desayuno': true,
    'Almuerzo': true,
    'Cena': true,
    'Snacks': true,
  };

  // Category images
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

  String _getIngredientUniqueKey(ShoppingIngredientItem ingredient) {
    return 'shopping_item_${ingredient.mealType.replaceAll(' ', '_').toLowerCase()}_${ingredient.item.replaceAll(' ', '_').toLowerCase()}_${ingredient.quantity.replaceAll(' ', '_').toLowerCase()}';
  }

  Future<void> _loadIngredientsFromPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final MealPlanData? mealPlanData = await _planService.getCurrentPlan();

      if (!mounted) return;

      if (mealPlanData == null) {
        throw Exception('No se encontró un plan de alimentación activo.');
      }

      final List<ShoppingIngredientItem> tempShoppingList = [];
      void addMealIngredients(List<MealItem> mealItems, String mealCategory) {
        for (var mealItem in mealItems) {
          for (var ingredient in mealItem.ingredients) {
            tempShoppingList.add(
              ShoppingIngredientItem(
                ingredientData: ingredient,
                mealType: mealCategory,
              ),
            );
          }
        }
      }

      addMealIngredients(mealPlanData.desayunos, 'Desayuno');
      addMealIngredients(mealPlanData.almuerzos, 'Almuerzo');
      addMealIngredients(mealPlanData.cenas, 'Cena');
      addMealIngredients(mealPlanData.snacks, 'Snacks');

      for (var ingredient in tempShoppingList) {
        final uniqueKey = _getIngredientUniqueKey(ingredient);
        ingredient.isChecked = _prefs.getBool(uniqueKey) ?? false;
      }

      print('--- [LOG 1] Datos cargados en la lista _ingredients ---');
      for (var ing in tempShoppingList) {
        print('Item: ${ing.item}, ImageUrl: ${ing.imageUrl}');
      }
      print('----------------------------------------------------');

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

  void _toggleIngredientCheck(ShoppingIngredientItem ingredient) {
    setState(() {
      ingredient.isChecked = !ingredient.isChecked;
      final uniqueKey = _getIngredientUniqueKey(ingredient);
      _prefs.setBool(uniqueKey, ingredient.isChecked);
    });
  }

  void _removeIngredient(ShoppingIngredientItem ingredientToRemove) {
    setState(() {
      final uniqueKey = _getIngredientUniqueKey(ingredientToRemove);
      _prefs.remove(uniqueKey);
      _ingredients
          .removeWhere((item) => _getIngredientUniqueKey(item) == uniqueKey);
    });
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
        iconTheme: const IconThemeData(color: Colors.black),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Error al cargar ingredientes',
              style: GoogleFonts.lato(
                fontSize: 20,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: FrutiaColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadIngredientsFromPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: FrutiaColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_ingredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: FrutiaColors.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tu lista de compras está vacía.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: FrutiaColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Genera un plan de alimentación para obtener tu lista de ingredientes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: FrutiaColors.secondaryText.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Navegar a la pantalla de generación de plan.'),
                    backgroundColor: FrutiaColors.accent,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FrutiaColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Generar Plan',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final groupedIngredients = groupBy(_ingredients, (item) => item.mealType);
    const orderedCategories = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks'];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: orderedCategories.length,
      itemBuilder: (context, index) {
        final category = orderedCategories[index];
        final categoryItems = groupedIngredients[category];

        if (categoryItems == null || categoryItems.isEmpty) {
          return const SizedBox.shrink();
        }

        categoryItems.sort((a, b) => a.item.compareTo(b.item));

        return _buildCategorySection(category, categoryItems);
      },
    );
  }

  Widget _buildCategorySection(
      String category, List<ShoppingIngredientItem> items) {
    final isExpanded = _isCategoryExpanded[category] ?? true;

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
            children: items.map(_buildIngredientCard).toList(),
          ),
          secondChild: Container(),
          crossFadeState:
              isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeInOut,
          sizeCurve: Curves.easeInOut,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Stack(
              children: [
                Image.asset(
                  _categoryImages[category]!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: FrutiaColors.accent.withOpacity(0.3),
                    child: const Center(
                        child: Icon(Icons.error, color: Colors.white)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              category,
                              style: GoogleFonts.lato(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: FrutiaColors.accent.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '($itemCount)',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
      ),
    );
  }

  Widget _buildIngredientCard(ShoppingIngredientItem ingredient) {
    print('--- [LOG 2] Construyendo Card para: ${ingredient.item} ---');
    print('URL de la imagen recibida: ${ingredient.imageUrl}');
    print('----------------------------------------------------');

    final String imageUrl =
        '$baseUrl/ingredient-image/${Uri.encodeComponent(ingredient.item)}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: FrutiaColors.accent.withOpacity(0.2), width: 1.0),
      ),
      child: Stack(
        children: [
          if (imageUrl != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.40,
                child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) {
                // Este error ahora nos dirá si nuestro propio servidor falla
                print('Error al cargar imagen DESDE NUESTRO SERVIDOR: $url, Error: $error');
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                );
              },
            ),
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: ingredient.isChecked,
                      onChanged: (_) => _toggleIngredientCheck(ingredient),
                      activeColor: FrutiaColors.accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
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
                              ? FrutiaColors.disabledText
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                if (ingredient.prices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 50.0 + 12.0 + 48.0, top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ingredient.prices.map((priceDetail) {
                        return Text(
                          '- ${priceDetail.store}: ${priceDetail.currency} ${priceDetail.price.toStringAsFixed(2)}',
                          style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
