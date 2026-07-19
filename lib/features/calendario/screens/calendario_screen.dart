import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/turno_model.dart';
import '../../../core/services/turno_service.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Turno> _todosTurnos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTurnos();
  }

  Future<void> _cargarTurnos() async {
    setState(() => _isLoading = true);
    final turnos = await TurnoService.getTurnos();
    setState(() {
      _todosTurnos = turnos;
      _isLoading = false;
    });
  }

  // Turnos del día seleccionado
  List<Turno> _turnosDelDia(DateTime dia) {
    return _todosTurnos.where((t) {
      return t.fechaInicio.year == dia.year &&
          t.fechaInicio.month == dia.month &&
          t.fechaInicio.day == dia.day;
    }).toList();
  }

  // Turnos de la semana actual
  List<DateTime> _diasDeLaSemana(DateTime dia) {
    final lunes = dia.subtract(Duration(days: dia.weekday - 1));
    return List.generate(7, (i) => lunes.add(Duration(days: i)));
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'activo': return AppColors.success;
      case 'perdido': return AppColors.error;
      case 'completado': return AppColors.textSecondary;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diasSemana = _diasDeLaSemana(_focusedDay);
    final formato = DateFormat('HH:mm');
    final formatoFecha = DateFormat('dd/MM');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Calendario', style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: AppColors.primary),
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [

                // Navegación semanal
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                        onPressed: () => setState(() {
                          _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                        }),
                      ),
                      Text(
                        '${formatoFecha.format(diasSemana.first)} — ${formatoFecha.format(diasSemana.last)}',
                        style: AppTextStyles.heading3,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                        onPressed: () => setState(() {
                          _focusedDay = _focusedDay.add(const Duration(days: 7));
                        }),
                      ),
                    ],
                  ),
                ),

                // Header días de la semana
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: diasSemana.map((dia) {
                      final esHoy = dia.year == DateTime.now().year &&
                          dia.month == DateTime.now().month &&
                          dia.day == DateTime.now().day;
                      final esSeleccionado = dia.year == _selectedDay.year &&
                          dia.month == _selectedDay.month &&
                          dia.day == _selectedDay.day;
                      final tieneTurnos = _turnosDelDia(dia).isNotEmpty;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDay = dia),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('EEE', 'es').format(dia).toUpperCase(),
                                style: AppTextStyles.caption.copyWith(
                                  color: esSeleccionado
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: esSeleccionado
                                      ? AppColors.primary
                                      : esHoy
                                          ? AppColors.primary.withValues(alpha: 0.15)
                                          : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${dia.day}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: esSeleccionado
                                          ? Colors.white
                                          : esHoy
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Punto indicador de turnos
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: tieneTurnos
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Divider(height: 1, color: AppColors.bordeColor),

                // Turnos del día seleccionado
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('EEEE d \'de\' MMMM', 'es').format(_selectedDay),
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _turnosDelDia(_selectedDay).isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.event_available_outlined,
                                        size: 40, color: AppColors.textSecondary),
                                    const SizedBox(height: 12),
                                    Text('Sin turnos este día',
                                        style: AppTextStyles.bodySecondary),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: _turnosDelDia(_selectedDay).length,
                                itemBuilder: (context, index) {
                                  final turno = _turnosDelDia(_selectedDay)[index];
                                  final color = _colorEstado(turno.estado);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: color.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(turno.nombre,
                                                  style: AppTextStyles.heading3),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${formato.format(turno.fechaInicio)} - ${formato.format(turno.fechaFin)}',
                                                style: AppTextStyles.caption,
                                              ),
                                              if (turno.usuarioNombre != null)
                                                Text(turno.usuarioNombre!,
                                                    style: AppTextStyles.bodySecondary),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            turno.estado.toUpperCase(),
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

