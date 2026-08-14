import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'dart:convert';

class MiEquipoScreen extends StatefulWidget {
  const MiEquipoScreen({super.key});

  @override
  State<MiEquipoScreen> createState() => _MiEquipoScreenState();
}

class _MiEquipoScreenState extends State<MiEquipoScreen> {
  List<Map<String, dynamic>> _equipos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    setState(() => _isLoading = true);
    final response = await ApiCliente.get(ApiConstants.misEquipos);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _equipos = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Color _colorRol(String rol) {
    switch (rol) {
      case 'lider': return AppColors.primary;
      case 'encargado': return AppColors.accent;
      case 'guardia': return AppColors.success;
      default: return AppColors.warning;
    }
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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _equipos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_off_outlined,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text('No pertenecés a ningún equipo',
                          style: AppTextStyles.bodySecondary),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarEquipos,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _equipos.length,
                    itemBuilder: (context, index) {
                      final equipo = _equipos[index];
                      final miembros = (equipo['miembros'] as List)
                          .cast<Map<String, dynamic>>();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: AppDecorations.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header equipo
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.group_outlined,
                                        color: AppColors.primary, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(equipo['nombre'] ?? '',
                                            style: AppTextStyles.heading3),
                                        if (equipo['descripcion'] != null &&
                                            equipo['descripcion']
                                                .toString()
                                                .isNotEmpty)
                                          Text(equipo['descripcion'],
                                              style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${miembros.length} miembros',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Lista de miembros
                            ...miembros.map((m) {
                              final color = _colorRol(m['rol'] ?? '');
                              return Column(
                                children: [
                                  const Divider(
                                      color: AppColors.bordeColor, height: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (m['nombre'] ?? 'U')[0]
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${m['nombre']} ${m['apellido']}',
                                                style: AppTextStyles.heading3,
                                              ),
                                              Text(
                                                m['email'] ?? '',
                                                style: AppTextStyles.caption,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Badge rol
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            (m['rol'] ?? '').toUpperCase(),
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}