import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

// Pantalla de detalles de un ítem de compra (placeholder)
class CompraDetailScreen extends StatelessWidget {
  final String itemName;

  const CompraDetailScreen({required this.itemName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          itemName,
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FrutiaColors.secondaryBackground,
              FrutiaColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Text(
              'Detalles del ítem: $itemName',
              style: GoogleFonts.lato(fontSize: 24, color: FrutiaColors.primaryText),
            ),
          ),
        ),
      ),
    );
  }
}

// Pantalla principal de compras
class ComprasScreen extends StatefulWidget {
  const ComprasScreen({Key? key}) : super(key: key);

  @override
  _ComprasScreenState createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  // Lista de ítems de compra favoritos
  late List<String> favoriteItems;

  // Lista de ítems de compra disponibles
  final List<Map<String, dynamic>> shoppingItems = const [
    {
      'name': 'Huevos (12 unidades)',
      'quantity': '1 docena',
      'image': 'assets/eggs.jpg',
      'route': '/compra/eggs',
    },
    {
      'name': 'Proteína en polvo',
      'quantity': '1 kg',
      'image': 'assets/protein_powder.jpg',
      'route': '/compra/protein_powder',
    },
    {
      'name': 'Plátanos',
      'quantity': '1 manojo',
      'image': 'assets/bananas.jpg',
      'route': '/compra/bananas',
    },
    {
      'name': 'Camote',
      'quantity': '2 kg',
      'image': 'assets/sweet_potato.jpg',
      'route': '/compra/sweet_potato',
    },
    {
      'name': 'Atún en agua',
      'quantity': '3 latas',
      'image': 'assets/tuna_cans.jpg',
      'route': '/compra/tuna_cans',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar lista de favoritos
    favoriteItems = [];
  }

  // Método para agregar o quitar un ítem de favoritos
  void _toggleFavorite(String itemName) {
    setState(() {
      if (favoriteItems.contains(itemName)) {
        favoriteItems.remove(itemName);
        _showSnackBar('$itemName eliminado de favoritos');
      } else {
        favoriteItems.add(itemName);
        _showSnackBar('$itemName añadido a favoritos');
      }
    });
  }

  // Método para mostrar un SnackBar con mensaje
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: FrutiaColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con título y botón de retroceso
      appBar: AppBar(
        title: Text(
          'Compras',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Cuerpo con gradiente y lista de ítems
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FrutiaColors.secondaryBackground,
              FrutiaColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lista de ítems de compra
                Expanded(
                  child: ListView.builder(
                    itemCount: shoppingItems.length,
                    itemBuilder: (context, index) {
                      final item = shoppingItems[index];
                      return _buildShoppingItemCard(item, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para construir una card de ítem de compra
  Widget _buildShoppingItemCard(Map<String, dynamic> item, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompraDetailScreen(itemName: item['name']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen del ítem
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: FrutiaColors.secondaryBackground,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: FrutiaColors.disabledText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nombre y cantidad del ítem
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item['name'],
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FrutiaColors.primaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['quantity'],
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: FrutiaColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Botón de favorito
              IconButton(
                icon: Icon(
                  favoriteItems.contains(item['name'])
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favoriteItems.contains(item['name'])
                      ? FrutiaColors.accent
                      : FrutiaColors.disabledText,
                ),
                onPressed: () => _toggleFavorite(item['name']),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: (200 + index * 200).ms).slideY(
          begin: 0.3,
          end: 0.0,
          duration: 800.ms,
          curve: Curves.easeOut,
        );
  }
}