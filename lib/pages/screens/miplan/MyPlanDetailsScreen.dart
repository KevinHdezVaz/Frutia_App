import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyPlanDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> recipeData;

  const MyPlanDetailsScreen({super.key, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    print('MyPlanDetailsScreen: Construyendo UI para recipeData=$recipeData');

    // --- EXTRACCIÓN SEGURA DE DATOS ---
    final details = recipeData['details'] as Map<String, dynamic>? ?? {};
    final title = recipeData['opcion'] as String? ?? 'Receta sin título';

    final imageUrl = details['image_url'] as String? ??
        'https://placehold.co/600x400/cccccc/ffffff?text=Imagen+No Disponible';
    final description =
        details['description'] as String? ?? 'Sin descripción disponible.';
    final calories = details['calories'] ?? 0;
    final prepTime = details['prep_time_minutes'] ?? 0;

    // *** LA PARTE CRÍTICA: EXTRACCIÓN SÚPER ROBUSTA DE INGREDIENTES ***
    // Obtener la lista de ingredientes de forma segura.
    // Usamos `whereType<T>()` para filtrar solo elementos del tipo esperado.
    // Aunque el backend intente normalizar, si el JSON llega corrupto o mal formado
    // en este punto, esto asegura que solo Maps sean procesados, y los Strings serán ignorados
    // o transformados si aún existieran.
    final List<Map<String, dynamic>> ingredients = [];
    final dynamic rawIngredients =
        details['ingredients']; // Obtenemos como dynamic

    if (rawIngredients is List) {
      for (var item in rawIngredients) {
        if (item is Map<String, dynamic>) {
          ingredients.add(item); // Ya es un Map, lo añadimos directamente
        } else if (item is String) {
          // Si es un String inesperado, lo convertimos a un Map simulado
          ingredients.add({'item': item, 'quantity': '', 'prices': []});
        }
        // Cualquier otro tipo inesperado será ignorado.
      }
    }

    final instructions = List<String>.from(details['instructions'] ?? []);

    print(
        'MyPlanDetailsScreen: Datos extraídos - title=$title, imageUrl=$imageUrl, ingredients=${ingredients.length}, instructions=${instructions.length}');

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(title, imageUrl),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(calories, prepTime),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    style: GoogleFonts.lato(
                        fontSize: 16,
                        color: FrutiaColors.secondaryText,
                        height: 1.5),
                  ),
                  const Divider(height: 40),
                  _buildSectionTitle('Ingredientes'),
                  const SizedBox(height: 16),
                  // Pasa cada Map de ingrediente al _buildIngredientTile
                  ...ingredients
                      .map((itemData) => _buildIngredientTile(itemData))
                      .toList(),
                  const Divider(height: 40),
                  _buildSectionTitle('Preparación'),
                  const SizedBox(height: 16),
                  ...instructions.asMap().entries.map((entry) {
                    return _buildInstructionStep(entry.key + 1, entry.value);
                  }).toList(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(String title, String imageUrl) {
    print('MyPlanDetailsScreen: Construyendo SliverAppBar para $title');
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      backgroundColor: FrutiaColors.accent,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
        title: Text(
          title,
          style: GoogleFonts.lato(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        background: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.4),
          colorBlendMode: BlendMode.darken,
          errorBuilder: (context, error, stackTrace) {
            print('MyPlanDetailsScreen: Error cargando imagen: $error');
            return Container(
              color: Colors.grey,
              child: const Center(
                  child: Icon(Icons.image_not_supported,
                      color: Colors.white, size: 50)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(int calories, int prepTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _InfoChip(
            icon: Icons.local_fire_department, text: '$calories calorías'),
        _InfoChip(icon: Icons.timer, text: '$prepTime min'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lato(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: FrutiaColors.primaryText),
    );
  }

  Widget _buildIngredientTile(Map<String, dynamic> ingredientData) {
    // Extracción segura de los datos del ingrediente
    final item = ingredientData['item'] as String? ?? 'Ingrediente Desconocido';
    final quantity = ingredientData['quantity'] as String? ?? '';

    // --- EXTRACCIÓN SÚPER ROBUSTA DE PRECIOS ---
    // Aseguramos que 'prices' es una lista, y que cada elemento de esa lista es un Map.
    final List<Map<String, dynamic>> prices = [];
    final dynamic rawPrices = ingredientData['prices'];
    if (rawPrices is List) {
      for (var priceItem in rawPrices) {
        if (priceItem is Map<String, dynamic>) {
          prices.add(priceItem);
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Icon(Icons.check_circle_outline,
                    color: FrutiaColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  // Muestra el item y la cantidad (si existe)
                  '$item ${quantity.isNotEmpty ? '($quantity)' : ''}',
                  style: const TextStyle(
                      fontSize: 16,
                      color: FrutiaColors.primaryText,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          // Solo muestra los precios si hay alguno presente
          if (prices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 36.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: prices.map((priceData) {
                  final store = priceData['store'] as String? ?? 'Tienda';
                  final price = (priceData['price'] as num?)?.toDouble() ?? 0.0;
                  final currency = priceData['currency'] as String? ?? '';
                  return Text(
                    '- $store: $currency ${price.toStringAsFixed(2)}',
                    style: GoogleFonts.lato(
                        fontSize: 14, color: FrutiaColors.secondaryText),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int stepNumber, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: FrutiaColors.accent,
            child: Text('$stepNumber',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                  fontSize: 16, height: 1.5, color: FrutiaColors.primaryText),
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
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: FrutiaColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: FrutiaColors.accent, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
