import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardias_front/core/services/vacaciones_service.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/vacaciones_service.dart';

class AprobarVacacionesScreen extends StatefulWidget {
  const AprobarVacacionesScreen({super.key});

  @override
  State<AprobarVacacionesScreen> createState() =>
      _AprobarVacacionesScreenState();
}

class _AprobarVacacionesScreenState extends State<AprobarVacacionesScreen> {
  List<Map<String, dynamic>> _pendientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPendientes();
  }

  Future<void> _cargarPendientes() async {
    setState(() => _isLoading = true);
    final data = await VacacionesService.getPendientes();
    setState(() {
      _pendientes = data;
      _isLoading = false;
    });
  }

  Future<void> _responder(int vacacionId, bool aprobar) async {
    final notaCtrl = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          aprobar ? 'Aprobar vacaciones' : 'Rechazar vacaciones',
          style: AppTextStyles.heading3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              aprobar
                  ? '¿Confirmás la aprobación?'
                  : '¿Confirmás el rechazo?',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notaCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: AppDecorations.inputDecoration(
                hint: 'Nota opcional...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: AppTextStyles.link),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              aprobar ? 'Aprobar' : 'Rechazar',
              style: TextStyle(
                color: aprobar ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    bool ok;
    if (aprobar) {
      ok = await VacacionesService.aprobar(vacacionId, nota: notaCtrl.text);
    } else {
      ok = await VacacionesService.rechazar(vacacionId, nota: notaCtrl.text);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? aprobar
                ? 'Vacaciones aprobadas'
                : 'Vacaciones rechazadas'
            : 'Error al procesar'),
        backgroundColor: ok
            ? aprobar
                ? AppColors.success
                : AppColors.warning
            : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok) _cargarPendientes();
  }

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Solicitudes de Vacaciones', style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _cargarPendientes,
              color: AppColors.primary,
              child: _pendientes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 48, color: AppColors.success),
                          const SizedBox(height: 12),
                          Text('No hay solicitudes pendientes',
                              style: AppTextStyles.bodySecondary),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _pendientes.length,
                      itemBuilder: (context, index) {
                        final v = _pendientes[index];
                        final inicio =
                            DateTime.parse(v['fecha_inicio']);
                        final fin = DateTime.parse(v['fecha_fin']);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  AppColors.warning.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Usuario
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        (v['usuario_nombre'] ?? 'U')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v['usuario_nombre'] ?? '',
                                          style: AppTextStyles.heading3,
                                        ),
                                        Text(
                                          '${v['dias_habiles']} días hábiles',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'PENDIENTE',
                                      style: TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                  color: AppColors.bordeColor, height: 1),
                              const SizedBox(height: 12),

                              // Fechas
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      color: AppColors.primary, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${formato.format(inicio)} → ${formato.format(fin)}',
                                    style: AppTextStyles.body,
                                  ),
                                ],
                              ),

                              // Motivo
                              if (v['motivo'] != null &&
                                  v['motivo'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.notes_outlined,
                                        color: AppColors.textSecondary,
                                        size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(v['motivo'],
                                          style:
                                              AppTextStyles.bodySecondary),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),

                              // Botones
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _responder(
                                          v['idvacacion'], true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        elevation: 0,
                                      ),
                                      child: const Text('Aprobar'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _responder(
                                          v['idvacacion'], false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(
                                            color: AppColors.error),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      child: const Text('Rechazar'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}