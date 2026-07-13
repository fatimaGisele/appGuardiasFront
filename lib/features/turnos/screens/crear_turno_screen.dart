import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/turno_service.dart';
import '../../../core/services/usuario_service.dart';
import '../../../core/services/calendario_service.dart';

class CrearTurnoScreen extends StatefulWidget {
  const CrearTurnoScreen({super.key});

  @override
  State<CrearTurnoScreen> createState() => _CrearTurnoScreenState();
}

class _CrearTurnoScreenState extends State<CrearTurnoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _usuarioAsignadoId;
  int? _usuarioRalevoId;
  int? _calendarioId;

  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _calendarios = [];
  bool _isLoading = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final usuarios = await UsuarioService.getUsuarios();
    final calendarios = await CalendarioService.getCalendarios();
    setState(() {
      _usuarios = usuarios;
      _calendarios = calendarios;
      _loadingData = false;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha({required bool esInicio}) async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: ahora,
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 365)),
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
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    if (hora == null) return;

    final fechaHora = DateTime(
      fecha.year, fecha.month, fecha.day, hora.hour, hora.minute,
    );

    setState(() {
      if (esInicio) {
        _fechaInicio = fechaHora;
      } else {
        _fechaFin = fechaHora;
      }
    });
  }

  Future<void> _crearTurno() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaInicio == null || _fechaFin == null) {
      _mostrarError('Seleccioná la fecha de inicio y fin');
      return;
    }
    if (_fechaFin!.isBefore(_fechaInicio!)) {
      _mostrarError('La fecha de fin debe ser posterior al inicio');
      return;
    }
    if (_usuarioAsignadoId == null || _usuarioRalevoId == null) {
      _mostrarError('Seleccioná el guardia y el relevo');
      return;
    }
    if (_usuarioAsignadoId == _usuarioRalevoId) {
      _mostrarError('El guardia y el relevo no pueden ser el mismo usuario');
      return;
    }
    if (_calendarioId == null) {
      _mostrarError('Seleccioná un calendario');
      return;
    }

    setState(() => _isLoading = true);

    final result = await TurnoService.crearTurno(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin!,
      usuarioAsignadoId: _usuarioAsignadoId!,
      usuarioRalevoId: _usuarioRalevoId!,
      calendarioId: _calendarioId!,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turno creado correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home');
    } else {
      _mostrarError(result['error'] ?? 'Error al crear el turno');
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
    final formato = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Asignar Turno', style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _loadingData
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Nombre del turno
                    Text('Nombre del turno', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nombreController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppDecorations.inputDecoration(
                        hint: 'Ej: Turno Noche A',
                        prefixIcon: Icons.badge_outlined,
                      ),
                      validator: (v) => v!.isEmpty ? 'Ingresá el nombre' : null,
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    Text('Descripción', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 2,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppDecorations.inputDecoration(
                        hint: 'Descripción opcional del turno',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fechas
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Inicio', style: AppTextStyles.label),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _seleccionarFecha(esInicio: true),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.bordeColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          color: AppColors.primary, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        _fechaInicio != null
                                            ? formato.format(_fechaInicio!)
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
                              Text('Fin', style: AppTextStyles.label),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _seleccionarFecha(esInicio: false),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.bordeColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          color: AppColors.accent, size: 18),
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

                    // Guardia asignado
                    Text('Guardia asignado', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: _usuarioAsignadoId,
                      hint: Text('Seleccioná el guardia',
                          style: AppTextStyles.bodySecondary),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppDecorations.inputDecoration(
                        hint: '',
                        prefixIcon: Icons.person_outline,
                      ),
                      items: _usuarios.map((u) {
                        return DropdownMenuItem<int>(
                          value: u['idusuario'],
                          child: Text(
                            '${u['nombre']} ${u['apellido']}',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _usuarioAsignadoId = v),
                    ),
                    const SizedBox(height: 16),

                    // Relevo
                    Text('Relevo', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: _usuarioRalevoId,
                      hint: Text('Seleccioná el relevo',
                          style: AppTextStyles.bodySecondary),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppDecorations.inputDecoration(
                        hint: '',
                        prefixIcon: Icons.people_outline,
                      ),
                      items: _usuarios.map((u) {
                        return DropdownMenuItem<int>(
                          value: u['idusuario'],
                          child: Text(
                            '${u['nombre']} ${u['apellido']}',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _usuarioRalevoId = v),
                    ),
                    const SizedBox(height: 16),

                    // Calendario
                    Text('Calendario', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: _calendarioId,
                      hint: Text('Seleccioná el calendario',
                          style: AppTextStyles.bodySecondary),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppDecorations.inputDecoration(
                        hint: '',
                        prefixIcon: Icons.calendar_month_outlined,
                      ),
                      items: _calendarios.map((c) {
                        return DropdownMenuItem<int>(
                          value: c['idcalendario'],
                          child: Text(
                            c['nombre'],
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _calendarioId = v),
                    ),
                    const SizedBox(height: 32),

                    // Botón crear
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _crearTurno,
                        style: AppDecorations.primaryButton,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Crear turno', style: AppTextStyles.button),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}