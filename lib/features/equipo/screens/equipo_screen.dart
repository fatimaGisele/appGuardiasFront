import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/estadistica_model.dart';
import '../../../core/services/usuario_service.dart';

class EquipoScreen extends StatefulWidget {
  const EquipoScreen({super.key});

  @override
  State<EquipoScreen> createState() => _EquipoScreenState();
}

class _EquipoScreenState extends State<EquipoScreen> {
  List<EstadisticaUsuario> _estadisticas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() => _isLoading = true);
    final data = await UsuarioService.getEstadisticaEquipo();
    setState(() {
      _estadisticas = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Mi Equipo', style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _cargarEstadisticas,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _estadisticas.length,
                itemBuilder: (context, index) {
                  final u = _estadisticas[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header usuario
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  u.nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${u.nombre} ${u.apellido}',
                                    style: AppTextStyles.heading3,
                                  ),
                                  Text(
                                    u.rol.toUpperCase(),
                                    style: AppTextStyles.hud.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            // Total
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${u.total}',
                                  style: AppTextStyles.heading2.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text('total', style: AppTextStyles.caption),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.bordeColor, height: 1),
                        const SizedBox(height: 16),

                        // Stats
                        Row(
                          children: [
                            _StatChip(
                              label: 'Cubiertas',
                              value: u.cubiertas,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: 'Activas',
                              value: u.activas,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: 'Perdidas',
                              value: u.perdidas,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: 'Programadas',
                              value: u.programadas,
                              color: AppColors.warning,
                            ),
                          ],
                        ),

                        // Barra de progreso
                        if (u.total > 0) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: u.cubiertas / u.total,
                              backgroundColor: AppColors.bordeColor,
                              valueColor: const AlwaysStoppedAnimation(AppColors.success),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${((u.cubiertas / u.total) * 100).toStringAsFixed(0)}% de cumplimiento',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
