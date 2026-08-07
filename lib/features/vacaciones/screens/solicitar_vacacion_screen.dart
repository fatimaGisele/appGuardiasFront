import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardias_front/core/services/vacaciones_service.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/vacaciones_service.dart';
import '../../../core/services/usuario_service.dart';

class SolicitarVacacionScreen extends StatefulWidget {
  const SolicitarVacacionScreen({super.key});

  @override
  State<SolicitarVacacionScreen> createState() =>
      _SolicitarVacacionScreenState();
}

class _SolicitarVacacionScreenState extends State<SolicitarVacacionScreen> {
  final _motivoCtrl = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _aprobadorId;
  List<Map<String, dynamic>> _aprobadores = [];
  Map<String, dynamic> _misDias = {};
  bool _isLoading = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final todos = await UsuarioService.getUsuarios();
    final aprobadores = todos
        .where((u) =>
            u['rol'] == 1 || u['rol'] == 2) // lider o encargado
        .toList();
    final dias = await VacacionesService.getMisDias();
    setState(() {
      _aprobadores = aprobadores;
      _misDias = dias;
      _loadingData = false;
    });
  }

  Future<void> _seleccionarFecha({required bool esInicio}) async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: ahora,
      firstDate: ahora,
      lastDate: DateTime(ahora.year + 1, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (fecha == null) return;
    setState(() {
      if (esInicio) {
        _fechaInicio = fecha;
        if (_fechaFin != null && _fechaFin!.isBefore(_fechaInicio!)) {
          _fechaFin = null;
        }
      } else {
        _fechaFin = fecha;
      }
    });
  }

  Future<void> _solicitar() async {
    if (_fechaInicio == null || _fechaFin == null) {
      _mostrarError('Seleccioná las fechas');
      return;
    }
    if (_aprobadorId == null) {
      _mostrarError('Seleccioná un aprobador');
      return;
    }

    setState(() => _isLoading = true);

    final formato = DateFormat('yyyy-MM-dd');
    final result = await VacacionesService.solicitar(
      fechaInicio: formato.format(_fechaInicio!),
      fechaFin: formato.format(_fechaFin!),
      aprobadorId: _aprobadorId!,
      motivo: _motivoCtrl.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home');
    } else {
      _mostrarError(result['error'] ?? 'Error al solicitar vacaciones');
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Solicitar Vacaciones', style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _loadingData
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card días disponibles
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.cardGlow,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DiasStat(
                          label: 'Disponibles',
                          value: _misDias['disponibles'] ?? 15,
                          color: AppColors.primary,
                        ),
                        _DiasStat(
                          label: 'Usados',
                          value: _misDias['usados'] ?? 0,
                          color: AppColors.warning,
                        ),
                        _DiasStat(
                          label: 'Restantes',
                          value: _misDias['restantes'] ?? 15,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fechas
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Período', style: AppTextStyles.heading3),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Desde', style: AppTextStyles.label),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () =>
                                        _seleccionarFecha(esInicio: true),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.inputFill,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: AppColors.bordeColor),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.calendar_today_outlined,
                                              color: AppColors.primary,
                                              size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            _fechaInicio != null
                                                ? formato
                                                    .format(_fechaInicio!)
                                                : 'Seleccionar',
                                            style: TextStyle(
                                              color: _fechaInicio != null
                                                  ? AppColors.textPrimary
                                                  : AppColors.textHint,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hasta', style: AppTextStyles.label),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () =>
                                        _seleccionarFecha(esInicio: false),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.inputFill,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: AppColors.bordeColor),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.calendar_today_outlined,
                                              color: AppColors.accent,
                                              size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            _fechaFin != null
                                                ? formato.format(_fechaFin!)
                                                : 'Seleccionar',
                                            style: TextStyle(
                                              color: _fechaFin != null
                                                  ? AppColors.textPrimary
                                                  : AppColors.textHint,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Aprobador
                        Text('Aprobador', style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _aprobadorId,
                          hint: Text('Seleccioná quien aprueba',
                              style: AppTextStyles.bodySecondary),
                          dropdownColor: AppColors.surface,
                          decoration:
                              AppDecorations.inputDecoration(hint: ''),
                          items: _aprobadores.map((u) {
                            return DropdownMenuItem<int>(
                              value: u['idusuario'],
                              child: Text(
                                '${u['nombre']} ${u['apellido']}',
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _aprobadorId = v),
                        ),
                        const SizedBox(height: 16),

                        // Motivo
                        Text('Motivo (opcional)', style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _motivoCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                              color: AppColors.textPrimary),
                          decoration: AppDecorations.inputDecoration(
                            hint: 'Describí el motivo de tu solicitud...',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _solicitar,
                      style: AppDecorations.primaryButton,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Enviar solicitud',
                              style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DiasStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _DiasStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Questrial',
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}