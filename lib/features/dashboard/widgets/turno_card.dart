import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/turno_model.dart';

class TurnoCard extends StatelessWidget {
  final Turno turno;
  final VoidCallback? onTap;

  const TurnoCard({super.key, required this.turno, this.onTap});

  Color get _estadoColor {
    switch (turno.estado) {
      case 'activo':
        return AppColors.success;
      case 'perdido':
        return AppColors.error;
      case 'completado':
        return AppColors.textSecondary;
      default:
        return AppColors.info;
    }
  }

  String get _estadoLabel {
    switch (turno.estado) {
      case 'programado':
        return 'Programado';
      case 'activo':
        return 'Activo';
      case 'completado':
        return 'Completado';
      case 'perdido':
        return 'Perdido';
      default:
        return turno.estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('dd/MM HH:mm');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: _estadoColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(turno.nombre, style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(
                    '${formato.format(turno.fechaInicio)} - ${formato.format(turno.fechaFin)}',
                    style: AppTextStyles.caption,
                  ),
                  if (turno.usuarioNombre != null) ...[
                    const SizedBox(height: 2),
                    Text(turno.usuarioNombre!, style: AppTextStyles.bodySecondary),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _estadoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _estadoLabel,
                style: TextStyle(
                  color: _estadoColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}