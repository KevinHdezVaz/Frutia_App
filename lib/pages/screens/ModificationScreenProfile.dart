import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/services/RachaProgreso.dart';
import 'package:Frutia/utils/colors.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:Frutia/services/ChatServiceApi.dart'; // Asegúrate de importar tu servicio de chat
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:permission_handler/permission_handler.dart'; // Importa la pantalla del cuestionario

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController _weightController;
  Map<String, dynamic>? _profileData;
  bool _isScreenLoading = true;
  String? _loadingError;

  // ▼▼▼ NUEVA VARIABLE PARA GUARDAR EL PESO INICIAL ▼▼▼
  double _initialWeight = 0.0;

  File? _imageFile;
  Map<String, dynamic>? _analysisResult;
  bool _isAnalyzing = false;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();
  final ChatServiceApi _chatService =
      ChatServiceApi(); // Instancia del servicio

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    try {
      final responseData = await RachaProgresoService.getProgresoWithUser();
      if (mounted) {
        setState(() {
          _profileData = responseData['profile'];
          final currentWeight = _profileData?['weight']?.toString() ?? '0.0';
          _weightController.text = currentWeight;
          // ▼▼▼ GUARDAMOS EL PESO INICIAL PARA COMPARARLO DESPUÉS ▼▼▼
          _initialWeight = double.tryParse(currentWeight) ?? 0.0;
          _isScreenLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingError = "Error al cargar tu perfil: $e";
          _isScreenLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message,
      {bool isError = false, Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.lato(
                color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: backgroundColor ??
            (isError ? Colors.redAccent : FrutiaColors.accent),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

Future<void> _pickAndAnalyzeImage() async {
  // ▼▼▼ 2. LÓGICA DE PERMISOS ▼▼▼
  final status = await Permission.photos.request();

  if (status.isGranted) {
    // Si el permiso fue concedido, continúa con la selección de imagen
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      _showSnackBar('No se seleccionó ninguna imagen.', isError: true);
      return;
    }

    setState(() {
      _imageFile = File(pickedFile.path);
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final result = await _chatService.analyzeBodyImage(File(pickedFile.path));
      if (mounted) setState(() => _analysisResult = result);
    } catch (e) {
      _showSnackBar('Error al analizar la imagen: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }

  } else if (status.isPermanentlyDenied) {
    // Si el usuario denegó permanentemente, lo mandamos a la configuración
    _showSnackBar('Permiso a la galería denegado. Habilítalo en la configuración.', isError: true);
   } else {
    // Si denegó una vez, le informamos
    _showSnackBar('El permiso a la galería es necesario para seleccionar una foto.', isError: true);
  }
  // ▲▲▲ FIN DE LA LÓGICA DE PERMISOS ▲▲▲
}
  Future<void> _saveWeight() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final newWeight = double.tryParse(_weightController.text) ?? 0.0;

    try {
      await RachaProgresoService.updateWeight(_weightController.text);
      _showSnackBar('Peso actualizado correctamente.',
          backgroundColor: Colors.green.shade600);

      // ▼▼▼ LÓGICA PARA VERIFICAR CAMBIO SIGNIFICATIVO ▼▼▼
      if (_initialWeight > 0) {
        final double weightChangePercentage =
            ((_initialWeight - newWeight) / _initialWeight).abs() * 100;

        // Si el cambio es de 5% o más, mostramos el diálogo
        if (weightChangePercentage >= 5) {
          if (mounted) _showUpdateDietDialog();
        }
      }
    } catch (e) {
      _showSnackBar('Error al guardar el peso: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ▼▼▼ NUEVA FUNCIÓN PARA MOSTRAR EL DIÁLOGO ▼▼▼
  Future<void> _showUpdateDietDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe elegir una opción
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('¡Felicidades por tu Progreso!',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Hemos notado un cambio significativo en tu peso.',
                    style: GoogleFonts.lato()),
                const SizedBox(height: 10),
                Text(
                    'Para asegurar que tu plan de alimentación siga siendo efectivo, te recomendamos recalcularlo.',
                    style: GoogleFonts.lato()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Más tarde',
                  style: GoogleFonts.lato(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: FrutiaColors.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text('Actualizar Plan',
                  style: GoogleFonts.lato(color: Colors.white)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
                // Navega a la pantalla del cuestionario para actualizar la dieta
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const QuestionnaireFlow()));
              },
            ),
          ],
        );
      },
    );
  }
  // ▲▲▲ FIN DE LA NUEVA FUNCIÓN ▲▲▲

  @override
  Widget build(BuildContext context) {
    // ... Tu widget build no necesita cambios ...
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Actualizar Perfil',
            style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: FrutiaColors.primaryText)),
        backgroundColor: Colors.white.withOpacity(0.5),
        elevation: 0,
        flexibleSpace: ClipRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent))),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: FrutiaColors.accent),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _isScreenLoading
          ? const Center(
              child: CircularProgressIndicator(color: FrutiaColors.accent))
          : _loadingError != null
              ? Center(
                  child: Text(_loadingError!,
                      style: GoogleFonts.lato(color: Colors.red)))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBodyFatCard()
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                        const SizedBox(height: 24),
                        _buildProgressCard()
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 200.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _isScreenLoading || _loadingError != null
          ? null
          : _buildActionButtons(),
    );
  }

  // ... Tus otros widgets (_buildBodyFatCard, _buildProgressCard, etc.) no necesitan cambios ...
  Widget _buildBodyFatCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: FrutiaColors.accent.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Análisis Corporal',
              style:
                  GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Sube una foto para una estimación de tu % de grasa corporal.',
              style: GoogleFonts.lato(
                  fontSize: 15, color: FrutiaColors.secondaryText)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: FrutiaColors.accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: FrutiaColors.accent.withOpacity(0.7), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Para un mejor resultado: foto de cuerpo completo, con ropa ajustada y buena iluminación.',
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        color: FrutiaColors.secondaryText,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _isAnalyzing ? null : _pickAndAnalyzeImage,
                child: Container(
                  width: 140,
                  height: 210,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: FrutiaColors.accent.withOpacity(0.3),
                        width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ▼▼▼ CAMBIOS AQUÍ ▼▼▼
                      if (_imageFile == null)
                        // 1. Mostramos la imagen de ejemplo como fondo
                        Image.asset(
                          'assets/images/imagenTorso.png', // Ruta a tu imagen
                          fit: BoxFit.cover,
                          color: Colors
                              .grey.shade300, // Le damos un tinte grisáceo
                        )
                      else
                        // Si ya se seleccionó una foto, la mostramos
                        Image.file(_imageFile!, fit: BoxFit.contain),

                      // 2. Superponemos un gradiente oscuro para que el texto resalte
                      if (_imageFile == null)
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                          )),
                        ),

                      // 3. El texto y el ícono van encima de todo
                      if (_imageFile == null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 40),
                            const SizedBox(height: 8),
                            Text('Subir Foto',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                        ),

                      if (_isAnalyzing)
                        Container(
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _analysisResult == null
                    ? Container(
                        height: 210,
                        child: Center(
                            child: Text(
                                'Sube una imagen para ver tu resultado aquí.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    color: FrutiaColors.secondaryText))))
                    : _buildAnalysisResultWidget(_analysisResult!)
                        .animate()
                        .fadeIn(duration: 400.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultWidget(Map<String, dynamic> result) {
    final double percentage = result['percentage']?.toDouble() ?? 0.0;
    final String recommendation = result['recommendation'] ?? 'No disponible.';
    final List<dynamic> observations = result['observations'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.lato(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: FrutiaColors.accent)),
            Text('Grasa Corporal (Estimado)',
                style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FrutiaColors.secondaryText)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: FrutiaColors.accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recomendación:',
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: FrutiaColors.accent)),
              const SizedBox(height: 4),
              Text(recommendation,
                  style: GoogleFonts.lato(
                      fontSize: 12,
                      color: FrutiaColors.secondaryText,
                      height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Observaciones:',
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 4),
            ...observations
                .map((obs) => Text('• $obs',
                    style: GoogleFonts.lato(
                        fontSize: 12,
                        color: FrutiaColors.secondaryText,
                        height: 1.5)))
                .toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: FrutiaColors.accent.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registro de Progreso',
              style:
                  GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Actualiza tu peso para mantener tus métricas al día.',
              style: GoogleFonts.lato(
                  fontSize: 14, color: FrutiaColors.secondaryText)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildWeightControlButton(
                icon: Icons.remove,
                onPressed: () {
                  double currentValue =
                      double.tryParse(_weightController.text) ?? 0.0;
                  setState(() {
                    _weightController.text =
                        (currentValue - 0.1).toStringAsFixed(1);
                  });
                },
              ),
              Container(
                width: 120,
                alignment: Alignment.center,
                child: TextFormField(
                  controller: _weightController,
                  textAlign: TextAlign.center,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.lato(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: FrutiaColors.primaryText),
                  decoration: InputDecoration(
                    suffixText: ' kg',
                    suffixStyle: GoogleFonts.lato(
                        color: FrutiaColors.secondaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              _buildWeightControlButton(
                icon: Icons.add,
                onPressed: () {
                  double currentValue =
                      double.tryParse(_weightController.text) ?? 0.0;
                  setState(() {
                    _weightController.text =
                        (currentValue + 0.1).toStringAsFixed(1);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightControlButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: FrutiaColors.accent.withOpacity(0.1)),
        child: Icon(icon, color: FrutiaColors.accent, size: 24),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveWeight,
        style: ElevatedButton.styleFrom(
          backgroundColor: FrutiaColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: FrutiaColors.accent.withOpacity(0.5),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : Text('Guardar Cambios',
                style: GoogleFonts.lato(
                    fontSize: 18, fontWeight: FontWeight.w800)),
      ).animate().slideY(
          begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }
}
