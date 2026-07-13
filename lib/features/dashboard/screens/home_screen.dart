import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/turno_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/turno_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/turno_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Turno> _turnos = [];
  bool _isLoading = true;
  Map<String, dynamic>? _usuario;

  // Estadísticas
  int get _turnosActivos => _turnos.where((t) => t.estado == 'activo').length;
  int get _turnosProgramados =>
      _turnos.where((t) => t.estado == 'programado').length;
  int get _turnosPerdidos => _turnos.where((t) => t.estado == 'perdido').length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {  
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    // Cargar usuario desde storage
    final userStr = await StorageService.getUserData();
    if (userStr != null) {
      _usuario = jsonDecode(userStr);
    }

    // Cargar turnos
    final turnos = await TurnoService.getTurnos();
    setState(() {
      _turnos = turnos;
      _isLoading = false;
    });
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
                    border: Border(
                      bottom: BorderSide(color: AppColors.bordeColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BLINDSPOT',
                            style: AppTextStyles.hud.copyWith(
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hola, $nombre 👋',
                            style: AppTextStyles.heading2,
                          ),
                          Text(
                            rol.toString().toUpperCase(),
                            style: AppTextStyles.hud,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Acciones rápidas — solo para lider/encargado
              if (rol == 'lider' || rol == 'encargado') ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Acciones', style: AppTextStyles.heading2),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Botón asignar turno
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.go('/turnos/crear'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: AppDecorations.cardGlow,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_circle_outline,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Asignar turno',
                                        style: AppTextStyles.heading3,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Crear y asignar guardia',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Botón calendario
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.go('/calendario'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month_outlined,
                                          color: AppColors.accent,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Calendario',
                                        style: AppTextStyles.heading3,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ver turnos del mes',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              // Stats cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen', style: AppTextStyles.heading2),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                          children: [
                            StatCard(
                              title: 'Activos',
                              value: _turnosActivos.toString(),
                              icon: Icons.play_circle_outline,
                              color: AppColors.success,
                            ),
                            StatCard(
                              title: 'Programados',
                              value: _turnosProgramados.toString(),
                              icon: Icons.schedule_outlined,
                              color: AppColors.info,
                            ),
                            StatCard(
                              title: 'Perdidos',
                              value: _turnosPerdidos.toString(),
                              icon: Icons.warning_amber_outlined,
                              color: AppColors.error,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Lista de turnos
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Turnos', style: AppTextStyles.heading2),
                      GestureDetector(
                        onTap: () => context.go('/turnos'),
                        child: Text('Ver todos', style: AppTextStyles.link),
                      ),
                    ],
                  ),
                ),
              ),

              // Filtros de estado
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: _FiltroEstado(
                    onFiltrar: (estado) async {
                      setState(() => _isLoading = true);
                      final turnos = await TurnoService.getTurnos(
                        estado: estado,
                      );
                      setState(() {
                        _turnos = turnos;
                        _isLoading = false;
                      });
                    },
                  ),
                ),
              ),

              // Lista
              _isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _turnos.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No hay turnos',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => TurnoCard(
                            turno: _turnos[index],
                            onTap: () =>
                                context.go('/turnos/${_turnos[index].id}'),
                          ),
                          childCount: _turnos.length,
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

// Widget de filtros
class _FiltroEstado extends StatefulWidget {
  final Function(String?) onFiltrar;
  const _FiltroEstado({required this.onFiltrar});

  @override
  State<_FiltroEstado> createState() => _FiltroEstadoState();
}

class _FiltroEstadoState extends State<_FiltroEstado> {
  String? _seleccionado;

  final List<Map<String, dynamic>> _filtros = [
    {'label': 'Todos', 'value': null},
    {'label': 'Activos', 'value': 'activo'},
    {'label': 'Programados', 'value': 'programado'},
    {'label': 'Perdidos', 'value': 'perdido'},
    {'label': 'Completados', 'value': 'completado'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filtros.map((f) {
          final isSelected = _seleccionado == f['value'];
          return GestureDetector(
            onTap: () {
              setState(() => _seleccionado = f['value']);
              widget.onFiltrar(f['value']);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.bordeColor,
                ),
              ),
              child: Text(
                f['label'],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
