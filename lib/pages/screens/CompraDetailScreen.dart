import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart'; // Para agrupar
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/model/MealPlanData.dart'; // Importamos los modelos canónicos
import 'package:shared_preferences/shared_preferences.dart'; // Importamos shared_preferences

// --- Modelos de datos para la lista de compras ---
// Estos modelos asumen que MealPlanData.dart ya contiene las clases Ingredient y PriceDetail.
// NO DUPLICAR PriceDetail e Ingredient aquí.

// Modelo para un ingrediente en la lista de compras, que envuelve el modelo Ingredient original
// y añade propiedades específicas de la UI como 'isChecked' y 'mealType'.
class ShoppingIngredientItem {
  final Ingredient ingredientData;
  bool isChecked;
  final String mealType; // E.g., "Desayuno", "Almuerzo", "Cena", "Snacks"

  ShoppingIngredientItem({
    required this.ingredientData,
    this.isChecked = false,
    required this.mealType,
  });

  // Getters para acceder fácilmente a las propiedades del ingrediente subyacente
  String get item => ingredientData.item;
  String get quantity => ingredientData.quantity;
  List<PriceDetail> get prices => ingredientData.prices;
}

// --- PANTALLA PRINCIPAL DE COMPRAS ---
class ComprasScreen extends StatelessWidget {
  const ComprasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1, // Solo un tab: "Mi Lista"
      child: Scaffold(
        backgroundColor: FrutiaColors.primaryBackground,
        appBar: AppBar(
          title: Text(
            'Lista de Compras',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: FrutiaColors.primaryText,
            ),
          ),
          backgroundColor: FrutiaColors.primaryBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: FrutiaColors.accent),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            indicatorColor: FrutiaColors.accent,
            labelColor: FrutiaColors.accent,
            unselectedLabelColor: FrutiaColors.secondaryText,
            tabs: [
              Tab(icon: Icon(Icons.list_alt_rounded), text: 'Mi Lista'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MyListTab(), // Solo la pestaña de Mi Lista
          ],
        ),
      ),
    );
  }
}

// --- PESTAÑA 1: MI LISTA DE COMPRAS ---
class _MyListTab extends StatefulWidget {
  @override
  _MyListTabState createState() => _MyListTabState();
}

class _MyListTabState extends State<_MyListTab> {
  List<ShoppingIngredientItem> _ingredients = [];
  bool _isLoading = true;
  String? _error;
  final PlanService _planService = PlanService();
  late SharedPreferences _prefs; // Instancia de SharedPreferences

  @override
  void initState() {
    super.initState();
    _initAndLoadIngredients(); // Inicia la carga de preferencias y luego los ingredientes
  }

  // Inicializa SharedPreferences y luego carga los ingredientes del plan
  Future<void> _initAndLoadIngredients() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadIngredientsFromPlan();
  }

  // Genera una clave única para guardar/recuperar el estado del ingrediente en SharedPreferences
  String _getIngredientUniqueKey(ShoppingIngredientItem ingredient) {
    return 'shopping_item_${ingredient.mealType.replaceAll(' ', '_').toLowerCase()}_${ingredient.item.replaceAll(' ', '_').toLowerCase()}_${ingredient.quantity.replaceAll(' ', '_').toLowerCase()}';
  }

  // Carga los ingredientes del plan de alimentación y les asigna su categoría
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

      // Función auxiliar para procesar una lista de comidas y añadir ingredientes a la lista principal
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

      // Añadir ingredientes de cada tipo de comida
      addMealIngredients(mealPlanData.desayunos, 'Desayuno');
      addMealIngredients(mealPlanData.almuerzos, 'Almuerzo');
      addMealIngredients(mealPlanData.cenas, 'Cena');
      addMealIngredients(mealPlanData.snacks, 'Snacks');

      // Cargar el estado guardado de shared_preferences para cada ingrediente
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

  // Maneja el cambio de estado del checkbox de un ingrediente
  void _toggleIngredientCheck(int index) {
    setState(() {
      _ingredients[index].isChecked = !_ingredients[index].isChecked;
      final ingredient = _ingredients[index];
      final uniqueKey = _getIngredientUniqueKey(ingredient);
      _prefs.setBool(uniqueKey, ingredient.isChecked);
    });
  }

  // Elimina un ingrediente de la lista y de shared_preferences
  void _removeIngredient(int index) {
    setState(() {
      final uniqueKey = _getIngredientUniqueKey(_ingredients[index]);
      _prefs.remove(uniqueKey);
      _ingredients.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: FrutiaColors.accent));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error al cargar ingredientes',
              style: GoogleFonts.lato(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  fontSize: 14, color: FrutiaColors.secondaryText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadIngredientsFromPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: FrutiaColors.accent,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.lato(fontSize: 16),
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
            Icon(Icons.shopping_cart_outlined,
                size: 48, color: FrutiaColors.secondaryText.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Tu lista de compras está vacía.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FrutiaColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Genera un plan de alimentación para obtener tu lista de ingredientes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: FrutiaColors.secondaryText.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Navegar a la pantalla de generación de plan.'),
                    backgroundColor: FrutiaColors.accent,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FrutiaColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Generar Plan',
                style:
                    GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final groupedIngredients = groupBy(_ingredients, (item) => item.mealType);
    final List<String> orderedCategories = [
      'Desayuno',
      'Almuerzo',
      'Cena',
      'Snacks'
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderedCategories.length,
      itemBuilder: (context, categoryIndex) {
        final category = orderedCategories[categoryIndex];
        final List<ShoppingIngredientItem>? categoryItems =
            groupedIngredients[category];

        if (categoryItems == null || categoryItems.isEmpty) {
          return const SizedBox.shrink();
        }

        categoryItems.sort((a, b) => a.item.compareTo(b.item));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                category,
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.accent,
                ),
              ),
            ),
            ...categoryItems.map((ingredient) {
              final originalIndex = _ingredients.indexOf(ingredient);
              return _buildIngredientCard(ingredient, originalIndex);
            }).toList(),
            const Divider(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildIngredientCard(ShoppingIngredientItem ingredient, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black.withOpacity(0.4), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: ingredient.isChecked,
                  onChanged: (_) => _toggleIngredientCheck(index),
                  activeColor: FrutiaColors.accent,
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
                          : FrutiaColors.primaryText,
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _removeIngredient(index),
                ),
              ],
            ),
            if (ingredient.prices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 48.0, top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ingredient.prices.map((priceDetail) {
                    return Text(
                      '- ${priceDetail.store}: ${priceDetail.currency} ${priceDetail.price.toStringAsFixed(2)}',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: FrutiaColors.secondaryText,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
