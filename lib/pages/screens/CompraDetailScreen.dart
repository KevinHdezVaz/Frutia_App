import 'package:Frutia/pages/screens/ProductDetailScreen.dart';
import 'package:Frutia/providers/ShoppingProvider.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

// --- PESTAÑA 1: MI LISTA ---
class _MyListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingProvider>();
    final list = provider.userShoppingList;

    if (list.isEmpty) {
      return const Center(
          child: Text(
              'Tu lista está vacía. Ve a "Explorar" para añadir productos.'));
    }

    // Agrupar por categoría
    final groupedList =
        groupBy(list, (UserShoppingListItem item) => item.item.category);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedList.keys.length,
      itemBuilder: (context, index) {
        String category = groupedList.keys.elementAt(index);
        List<UserShoppingListItem> items = groupedList[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(category,
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...items
                .map((userItem) => _UserListItemCard(userItem: userItem))
                .toList(),
          ],
        );
      },
    );
  }
}

// --- PESTAÑA 2: EXPLORAR PRODUCTOS ---
class _ExploreTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingProvider>();
    final masterList = provider.masterProductList;
    final groupedList =
        groupBy(masterList, (ShoppingItem item) => item.category);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedList.keys.length,
      itemBuilder: (context, index) {
        String category = groupedList.keys.elementAt(index);
        List<ShoppingItem> items = groupedList[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(category,
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...items.map((item) => _MasterProductCard(item: item)).toList(),
          ],
        );
      },
    );
  }
}

// --- WIDGETS DE ITEMS ---

class _UserListItemCard extends StatelessWidget {
  final UserShoppingListItem userItem;
  const _UserListItemCard({required this.userItem});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ShoppingProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            Checkbox(
              value: userItem.isChecked,
              onChanged: (_) => provider.toggleCheck(userItem.item.id),
              activeColor: FrutiaColors.accent,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(userItem.item.image,
                  width: 50, height: 50, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userItem.item.name,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  decoration: userItem.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: userItem.isChecked
                      ? FrutiaColors.disabledText
                      : FrutiaColors.primaryText,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.redAccent),
                    onPressed: () =>
                        provider.decrementQuantity(userItem.item.id)),
                Text('${userItem.quantity}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: FrutiaColors.accent),
                    onPressed: () =>
                        provider.incrementQuantity(userItem.item.id)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _MasterProductCard extends StatelessWidget {
  final ShoppingItem item;
  const _MasterProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ShoppingProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProductDetailScreen(item: item))),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(item.image,
                    width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(item.name,
                      style: GoogleFonts.lato(fontWeight: FontWeight.w600))),
              IconButton(
                icon: const Icon(Icons.add_shopping_cart,
                    color: FrutiaColors.accent),
                onPressed: () {
                  provider.addItemToUserList(item);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${item.name} añadido a tu lista')));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
