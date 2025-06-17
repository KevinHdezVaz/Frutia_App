import 'package:Frutia/pages/screens/ProductDetailScreen.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';

class ComprasScreen extends StatelessWidget {
  const ComprasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: FrutiaColors.primaryBackground,
        appBar: AppBar(
          title: Text('Lista de Compras',
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primaryText)),
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
              Tab(icon: Icon(Icons.search_rounded), text: 'Explorar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MyListTab(),
            _ExploreTab(),
          ],
        ),
      ),
    );
  }
}

class _MyListTab extends StatefulWidget {
  @override
  _MyListTabState createState() => _MyListTabState();
}

class IngredientItem {
  final String name;
  bool isChecked;
  final String category;

  IngredientItem({
    required this.name,
    this.isChecked = false,
    required this.category,
  });
}

class _MyListTabState extends State<_MyListTab> {
  List<IngredientItem> _ingredients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  // Función para determinar la categoría basada en el nombre del ingrediente
  String _determineCategory(String ingredient) {
    final lowerIngredient = ingredient.toLowerCase();

    if (lowerIngredient.contains('leche') ||
        lowerIngredient.contains('queso') ||
        lowerIngredient.contains('yogur')) {
      return 'Lácteos';
    } else if (lowerIngredient.contains('pollo') ||
        lowerIngredient.contains('carne') ||
        lowerIngredient.contains('pescado')) {
      return 'Carnes';
    } else if (lowerIngredient.contains('manzana') ||
        lowerIngredient.contains('banana') ||
        lowerIngredient.contains('fruta')) {
      return 'Frutas';
    } else if (lowerIngredient.contains('espinaca') ||
        lowerIngredient.contains('lechuga') ||
        lowerIngredient.contains('vegetal')) {
      return 'Vegetales';
    } else if (lowerIngredient.contains('arroz') ||
        lowerIngredient.contains('pasta') ||
        lowerIngredient.contains('pan')) {
      return 'Granos';
    } else if (lowerIngredient.contains('aceite') ||
        lowerIngredient.contains('vinagre') ||
        lowerIngredient.contains('especia')) {
      return 'Condimentos';
    } else {
      return 'Otros';
    }
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await PlanService().getShoppingListIngredients();
      setState(() {
        _ingredients = ingredients
            .map((ing) => IngredientItem(
                  name: ing,
                  category: _determineCategory(ing),
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleIngredientCheck(int index) {
    setState(() {
      _ingredients[index].isChecked = !_ingredients[index].isChecked;
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error al cargar ingredientes',
                style: TextStyle(color: Colors.red)),
            Text(_error!),
            ElevatedButton(
              onPressed: _loadIngredients,
              child: Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FrutiaColors.accent,
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
            Text('No hay ingredientes en tu plan actual'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar a generación de plan o mostrar diálogo
              },
              child: Text('Generar Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FrutiaColors.accent,
              ),
            ),
          ],
        ),
      );
    }

    // Agrupar ingredientes por categoría
    final groupedIngredients = groupBy(_ingredients, (item) => item.category);
    final categories = groupedIngredients.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, categoryIndex) {
        final category = categories[categoryIndex];
        final categoryItems = groupedIngredients[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                category,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.accent,
                ),
              ),
            ),
            ...categoryItems
                .map((ingredient) => _buildIngredientCard(ingredient))
                .toList(),
          ],
        );
      },
    );
  }

  Widget _buildIngredientCard(IngredientItem ingredient) {
    final index = _ingredients.indexOf(ingredient);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Checkbox(
              value: ingredient.isChecked,
              onChanged: (_) => _toggleIngredientCheck(index),
              activeColor: FrutiaColors.accent,
            ),
            Expanded(
              child: Text(
                ingredient.name,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
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
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _removeIngredient(index),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PESTAÑA 2: EXPLORAR PRODUCTOS ---
class _ExploreTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implementación existente de la pestaña Explorar
    return Center(child: Text('Pestaña de Explorar'));
  }
}
