import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/turno_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/turno_service.dart';
import '../../../core/services/relevo_service.dart';

class RegularUserHomeScreen extends StatefulWidget {
  const RegularUserHomeScreen({super.key});

  @override
  State<RegularUserHomeScreen> createState() => _RegularUserHomeScreenState();
}

class _RegularUserHomeScreenState extends State<RegularUserHomeScreen> {
  List<Turno> _misTurnos = [];
  List<Map<String, dynamic>> _relevosPendientes = [];
  bool _isLoading = true;
  Map<String, dynamic>? _usuario;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    final userStr = await StorageService.getUserData();
    if (userStr != null) _usuario = jsonDecode(userStr);

    final turnos = await TurnoService.getTurnos();
    final relevos = await RelevoService.getMisRelevosPendientes();

    setState(() {
      _misTurnos = turnos;
      _relevosPendientes = relevos;
      _isLoading = false;
    });
  }

  Future<void> _hacerCheckin(int turnoId) async {
    final ok = await TurnoService.checkin(turnoId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Check-in realizado ✅' : 'Error al hacer check-in'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok) _cargarDatos();
  }

  Future<void> _responderRelevo(int relevoId, bool aceptar) async {
    if (!aceptar) {
      // Pedir motivo
      final motivoCtrl = TextEditingController();
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Rechazar turno', style: AppTextStyles.heading3),
          content: TextField(
            controller: motivoCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: AppDecorations.inputDecoration(hint: 'Motivo (opcional)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar', style: AppTextStyles.link),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Rechazar',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      if (confirmar != true) return;
      await RelevoService.rechazar(relevoId, motivo: motivoCtrl.text);
    } else {
      await RelevoService.aceptar(relevoId);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(aceptar ? 'Turno aceptado ✅' : 'Turno rechazado'),
        backgroundColor: aceptar ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _cargarDatos();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario?['nombre'] ?? 'Usuario';
    final rol = _usuario?['rol'] ?? '';
    final formato = DateFormat('dd/MM HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarDatos,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.bordeColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BLINDSPOT',
                              style: AppTextStyles.hud.copyWith(
                                  fontSize: 13, color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text('Hola, $nombre 👋',
                              style: AppTextStyles.heading2),
                          Text(rol.toString().toUpperCase(),
                              style: AppTextStyles.hud),
                        ],
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              // Relevos pendientes
              if (_relevosPendientes.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active_outlined,
                                color: AppColors.warning, size: 20),
                            const SizedBox(width: 8),
                            Text('Relevos pendientes',
                                style: AppTextStyles.heading2),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._relevosPendientes.map((r) {
                          final inicio = DateTime.parse(r['fecha_inicio']);
                          final fin = DateTime.parse(r['fecha_fin']);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      AppColors.warning.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r['turno_nombre'] ?? '',
                                    style: AppTextStyles.heading3),
                                const SizedBox(height: 4),
                                Text(
                                  '${formato.format(inicio)} - ${formato.format(fin)}',
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _responderRelevo(
                                            r['idrelevo'], true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          elevation: 0,
                                        ),
                                        child: const Text('Aceptar'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _responderRelevo(
                                            r['idrelevo'], false),
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
                        }),
                      ],
                    ),
                  ),
                ),
              ],

              // Mis turnos
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Text('Mis Turnos', style: AppTextStyles.heading2),
                ),
              ),

              _isLoading
                  ? const SliverFillRemaining(
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                    )
                  : _misTurnos.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inbox_outlined,
                                    size: 48,
                                    color: AppColors.textSecondary),
                                const SizedBox(height: 12),
                                Text('No tenés turnos asignados',
                                    style: AppTextStyles.bodySecondary),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding:
                              const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final turno = _misTurnos[index];
                                final color = turno.estado == 'activo'
                                    ? AppColors.success
                                    : turno.estado == 'perdido'
                                        ? AppColors.error
                                        : turno.estado == 'completado'
                                            ? AppColors.textSecondary
                                            : AppColors.primary;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: color.withValues(alpha: 0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(turno.nombre,
                                              style: AppTextStyles.heading3),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6),
                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                  alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                      const SizedBox(height: 6),
                                      Text(
                                        '${formato.format(turno.fechaInicio)} - ${formato.format(turno.fechaFin)}',
                                        style: AppTextStyles.caption,
                                      ),
                                      // Botón check-in solo si está programado
                                      if (turno.estado == 'programado') ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () =>
                                                _hacerCheckin(turno.id),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.success,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              elevation: 0,
                                            ),
                                            icon: const Icon(
                                                Icons.check_circle_outline,
                                                size: 18),
                                            label:
                                                const Text('Hacer Check-in'),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                              childCount: _misTurnos.length,
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}