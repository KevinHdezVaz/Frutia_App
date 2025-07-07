import 'package:flutter/material.dart';

// --- Modelos de Datos (Reutilizados y Adaptados con Iconos) ---

class MealOption {
  final String name;
  final String? subtitle;
  const MealOption(this.name, {this.subtitle});
}

class MealCategory {
  final String title;
  final String description;
  final IconData icon; // <-- Añadido para el diseño
  final Color color; // <-- Añadido para el diseño
  final List<MealOption> options;

  const MealCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.options,
  });
}

class Formula {
  final String title;
  final String description;
  final String imageUrl;
  final List<MealCategory> categories;

  const Formula({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.categories,
  });
}

// --- Pantalla de Detalles (Premium) ---
class PremiumFormulaDetailsScreen extends StatelessWidget {
  final Formula formula;

  const PremiumFormulaDetailsScreen({Key? key, required this.formula})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: CustomScrollView(
        slivers: [
          // --- Cabecera con Imagen Mejorada ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.green,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                formula.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ]),
              ),
              background: Image.network(
                formula.imageUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),

          // --- Contenido de la Fórmula con Diseño Mejorado ---
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // --- Descripción de la Fórmula ---
                Text(
                  'Componentes de la Fórmula',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  formula.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 24),

                // --- Lista de Categorías con Tarjetas Rediseñadas ---
                ...formula.categories
                    .map((category) => _CategoryDetailCard(category: category))
                    .toList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widgets Componentes Re-diseñados ---

class _CategoryDetailCard extends StatelessWidget {
  final MealCategory category;

  const _CategoryDetailCard({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Encabezado de la Tarjeta de Categoría ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(category.icon, color: category.color, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red),
                    ),
                    Text(
                      category.description,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Contenido con Opciones en forma de Chips ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0, // Espacio horizontal entre chips
              runSpacing: 8.0, // Espacio vertical entre filas de chips
              children: category.options.map((option) {
                return Chip(
                  avatar: option.subtitle != null
                      ? const Icon(Icons.scale_outlined, size: 16)
                      : null,
                  label: Text(option.name),
                  labelStyle: TextStyle(fontWeight: FontWeight.w500),
                  backgroundColor: Colors.grey[100],
                  side: BorderSide(color: Colors.grey[300]!),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Para Probar la Pantalla (Ejecutar este archivo) ---

// Datos genéricos para la "Fórmula de Almuerzo" con nuevos campos de diseño
final formulaDeAlmuerzo = Formula(
  title: 'Fórmula de Almuerzo',
  description:
      'Construye tu almuerzo ideal eligiendo una opción de cada categoría para un balance perfecto de nutrientes.',
  imageUrl:
      'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  categories: const [
    MealCategory(
      title: 'Proteínas',
      description: 'Elige una fuente de proteína',
      icon: Icons.egg_alt_outlined,
      color: Colors.blue,
      options: [
        MealOption('Pollo o Pavita', subtitle: 'Pesar 200g en crudo'),
        MealOption('Carne roja o Pescado', subtitle: 'Pesar 230g en crudo'),
      ],
    ),
    MealCategory(
      title: 'Carbohidratos',
      description: 'Elige una fuente de energía',
      icon: Icons.local_fire_department_outlined,
      color: Colors.orange,
      options: [
        MealOption('Papa, lentejas o frejoles',
            subtitle: 'Pesar 300g en cocido'),
        MealOption('Arroz, quinua o fideos', subtitle: 'Pesar 200g en cocido'),
      ],
    ),
    MealCategory(
      title: 'Grasas Saludables',
      description: 'Añade una grasa a tu plato',
      icon: Icons.spa_outlined,
      color: Colors.purple,
      options: [
        MealOption('Palta', subtitle: '100g (media unidad aprox.)'),
        MealOption('Aceite de Oliva', subtitle: '2 cucharaditas (10ml)'),
      ],
    ),
    MealCategory(
      title: 'Vegetales Libres',
      description: 'Acompaña sin límites',
      icon: Icons.eco_outlined,
      color: Colors.green,
      options: [
        MealOption('Ensalada Fresca', subtitle: 'Lechuga, tomate, etc.'),
      ],
    ),
  ],
);
