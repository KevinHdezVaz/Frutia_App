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

    final imagePath = details['image_url'] as String?;

    final imageUrl = details['image_url'] as String? ??
        'https://placehold.co/600x400/cccccc/ffffff?text=Imagen+No Disponible';
    final description =
        details['description'] as String? ?? 'Sin descripción disponible.';
    final calories = details['calories'] ?? 0;
    final prepTime = details['prep_time_minutes'] ?? 0;

    // *** LA PARTE CRÍTICA: EXTRACCIÓN SÚPER ROBUSTA DE INGREDIENTES ***
    final List<Map<String, dynamic>> ingredients = [];
    final dynamic rawIngredients =
        details['ingredients']; // Obtenemos como dynamic
    print('MyPlanDetailsScreen: Raw ingredients data = $rawIngredients');

    if (rawIngredients is List) {
      for (var item in rawIngredients) {
        if (item is Map<String, dynamic>) {
          ingredients.add(item); // Ya es un Map, lo añadimos directamente
        } else if (item is String) {
          if (item.isNotEmpty) {
            ingredients.add({'item': item, 'quantity': '', 'prices': []});
          }
        } else if (item == null) {
          ingredients.add({
            'item': 'Ingrediente no especificado',
            'quantity': '',
            'prices': []
          });
        }
        // Cualquier otro tipo inesperado será ignorado con un mensaje de depuración
        else {
          print('MyPlanDetailsScreen: Tipo inesperado en ingredients: $item');
        }
      }
    } else {
      print(
          'MyPlanDetailsScreen: ingredients no es una lista, es: $rawIngredients');
    }

    final instructions = List<String>.from(details['instructions'] ?? []);

    print(
        'MyPlanDetailsScreen: Datos extraídos - title=$title, imageUrl=$imageUrl, ingredients=${ingredients.length}, instructions=${instructions.length}');

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          // LÍNEA NUEVA
          _buildSliverAppBar(context, title, imagePath),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(calories, prepTime),
                  const SizedBox(height: 20),
                  Text(description,
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          color: FrutiaColors.secondaryText,
                          height: 1.5)),
                  const Divider(height: 40),
                  _buildSectionTitle('Ingredientes'),
                  const SizedBox(height: 16),
                  if (ingredients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text('No se especificaron ingredientes.',
                          style: GoogleFonts.lato(
                              fontSize: 14, color: FrutiaColors.secondaryText)),
                    ),
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

  void _showFullScreenImageFromUrl(BuildContext context, String imageUrl) {
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
              // Visor interactivo para zoom y paneo
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  // Muestra un indicador de carga mientras la imagen se descarga
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child:
                        Icon(Icons.broken_image, color: Colors.white, size: 50),
                  ),
                ),
              ),
              // Botón para cerrar
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// --- [MÉTODO MODIFICADO] ---
  Widget _buildSliverAppBar(
      BuildContext context, String title, String? imagePath) {
    // Parámetro de context añadido
    print('MyPlanDetailsScreen: Construyendo SliverAppBar para $title');

    const String baseUrlApp = "https://frutia.aftconta.mx";

    final String? fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? baseUrlApp + imagePath
        : null;

    print('MyPlanDetailsScreen: URL completa construida: $fullImageUrl');

    // Widget para la imagen de fondo, ahora interactivo
    Widget backgroundImageWidget;
    if (fullImageUrl != null) {
      backgroundImageWidget = GestureDetector(
        // --- NUEVO: GestureDetector para hacer la imagen tappable
        onTap: () => _showFullScreenImageFromUrl(context,
            fullImageUrl), // --- NUEVO: Llama a la función de pantalla completa
        child: Stack(
          // --- NUEVO: Stack para superponer el icono
          fit: StackFit.expand,
          children: [
            Image.network(
              fullImageUrl,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) {
                print(
                    'MyPlanDetailsScreen: Error cargando imagen desde $fullImageUrl: $error');
                return Container(
                  color: Colors.grey,
                  child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white, size: 50)),
                );
              },
            ),
            // --- NUEVO: Icono de pantalla completa para dar una pista visual
            const Positioned(
              bottom: 10,
              right: 10,
              child: Icon(Icons.fullscreen, color: Colors.white70, size: 28),
            ),
          ],
        ),
      );
    } else {
      // Si no hay URL, el placeholder no es interactivo
      backgroundImageWidget = Container(
        color: Colors.grey,
        child: const Center(
            child:
                Icon(Icons.image_not_supported, color: Colors.white, size: 50)),
      );
    }

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
        // --- MODIFICADO: Se usa el nuevo widget interactivo
        background: backgroundImageWidget,
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
