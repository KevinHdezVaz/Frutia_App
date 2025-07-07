// lib/pages/history_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PlanService _planService = PlanService();
  late Future<List<MealLog>> _historyFuture;

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga de datos una sola vez
    _historyFuture = _planService.getHistory();
  }

  // Función para agrupar los logs por fecha
  Map<String, List<MealLog>> _groupLogsByDate(List<MealLog> logs) {
    final Map<String, List<MealLog>> groupedLogs = {};
    for (var log in logs) {
      // La fecha viene como 'YYYY-MM-DD'
      groupedLogs.putIfAbsent(log.date, () => []).add(log);
    }
    return groupedLogs;
  }

  // Formateador para mostrar fechas amigables
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d \'de\' MMMM \'de\' yyyy', 'es_ES').format(date);
    } catch (e) {
      return dateStr; // Devuelve la fecha original si hay error de formato
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      appBar: AppBar(
        title: Text('Historial de Comidas',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: FrutiaColors.accent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<MealLog>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          // --- ESTADO DE CARGA ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: FrutiaColors.accent));
          }

          // --- ESTADO DE ERROR ---
          if (snapshot.hasError) {
            return Center(
                child: Text("Error al cargar el historial: ${snapshot.error}",
                    style: TextStyle(color: Colors.red)));
          }

          // --- ESTADO SIN DATOS ---
          final logs = snapshot.data;
          if (logs == null || logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("Aún no tienes registros",
                      style: GoogleFonts.lato(
                          fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          // --- ESTADO CON DATOS (ÉXITO) ---
          final groupedLogs = _groupLogsByDate(logs);
          final dates = groupedLogs.keys.toList();

          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final logsForDate = groupedLogs[date]!;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado con la fecha
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        _formatDate(date),
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: FrutiaColors.primaryText),
                      ),
                    ).animate().fadeIn(delay: (200 * index).ms),

                    // Tarjetas de comida para esa fecha
                    ...logsForDate
                        .map((log) => _MealLogCard(log: log))
                        .toList()
                        .animate(interval: 100.ms)
                        .fadeIn()
                        .slideX(begin: 0.2),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- WIDGET PARA MOSTRAR CADA COMIDA REGISTRADA ---
class _MealLogCard extends StatelessWidget {
  final MealLog log;

  const _MealLogCard({required this.log});

  IconData _getIconForMeal(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'almuerzo':
        return Icons.restaurant;
      case 'cena':
        return Icons.dinner_dining;
      case 'shake':
        return Icons.blender;
      case 'desayuno':
        return Icons.free_breakfast;
      default:
        return Icons.lunch_dining;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de la comida (ej. Almuerzo)
            Row(
              children: [
                Icon(_getIconForMeal(log.mealType), color: FrutiaColors.accent),
                const SizedBox(width: 8),
                Text(
                  log.mealType,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(height: 20),
            // Lista de ingredientes seleccionados
            Text(
              "Seleccionaste:",
              style: GoogleFonts.lato(
                  color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            ...log.selections
                .map((option) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                      child: Text("• ${option.name}"),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
