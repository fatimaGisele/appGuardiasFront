import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardias_front/core/constants/api_constants.dart';
import 'package:guardias_front/core/services/api_client.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/equipo_service.dart';
import '../../../core/services/usuario_service.dart';

class DetalleEquipoScreen extends StatefulWidget {
  final int grupoId;
  final String nombreGrupo;

  const DetalleEquipoScreen({
    super.key,
    required this.grupoId,
    required this.nombreGrupo,
  });

  @override
  State<DetalleEquipoScreen> createState() => _DetalleEquipoScreenState();
}

class _DetalleEquipoScreenState extends State<DetalleEquipoScreen> {
  List<Map<String, dynamic>> _miembros = [];
  List<Map<String, dynamic>> _todosUsuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    final miembros = await EquipoService.getMiembros(widget.grupoId);
    final usuarios = await UsuarioService.getUsuarios();
    setState(() {
      _miembros = miembros;
      _todosUsuarios = usuarios;
      _isLoading = false;
    });
  }

  // Usuarios que NO están en el grupo todavía
  List<Map<String, dynamic>> get _usuariosDisponibles {
    final idsEnGrupo = _miembros
        .map((m) => m['usuario'] as int)
        .toSet();
    return _todosUsuarios
        .where((u) => !idsEnGrupo.contains(u['idusuario']))
        .toList();
  }

  Future<void> _mostrarAgregarMiembro() async {
    if (_usuariosDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los usuarios ya están en el equipo'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    int? usuarioSeleccionado;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar miembro', style: AppTextStyles.heading2),
              const SizedBox(height: 20),
              Text('Seleccioná un usuario', style: AppTextStyles.label),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: usuarioSeleccionado,
                hint: Text('Elegí un usuario', style: AppTextStyles.bodySecondary),
                dropdownColor: AppColors.surface,
                decoration: AppDecorations.inputDecoration(hint: ''),
                items: _usuariosDisponibles.map((u) {
                  return DropdownMenuItem<int>(
                    value: u['idusuario'],
                    child: Text(
                      '${u['nombre']} ${u['apellido']}',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setModalState(() => usuarioSeleccionado = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: AppDecorations.primaryButton,
                  onPressed: usuarioSeleccionado == null
                      ? null
                      : () async {
                          final ok = await EquipoService.agregarMiembro(
                            usuarioId: usuarioSeleccionado!,
                            grupoId: widget.grupoId,
                            prioridad: _miembros.length + 1,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          if (ok) {
                            _cargarDatos();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Miembro agregado'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  child: Text('Agregar', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _quitarMiembro(int usuarioGrupoId, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Quitar miembro', style: AppTextStyles.heading3),
        content: Text('¿Querés quitar a $nombre del equipo?',
            style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: AppTextStyles.link),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final ok = await EquipoService.quitarMiembro(usuarioGrupoId);
      if (ok) _cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(widget.nombreGrupo, style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/equipos'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
            onPressed: _mostrarAgregarMiembro,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              color: AppColors.primary,
              child: _miembros.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_off_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text('El equipo no tiene miembros',
                              style: AppTextStyles.bodySecondary),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _mostrarAgregarMiembro,
                            style: AppDecorations.primaryButton.copyWith(
                              minimumSize: WidgetStateProperty.all(
                                const Size(200, 46),
                              ),
                            ),
                            icon: const Icon(Icons.person_add_outlined),
                            label: Text('Agregar miembro',
                                style: AppTextStyles.button),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _miembros.length,
                      itemBuilder: (context, index) {
                        final m = _miembros[index];
                        final detalle = m['usuario_detalle'] as Map<String, dynamic>?;
                        final nombre = detalle != null
                            ? '${detalle['nombre']} ${detalle['apellido']}'
                            : 'Usuario ${m['usuario']}';
                        final rol = detalle?['rol']?.toString() ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: AppDecorations.card,
                          child: Row(
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
                                    nombre[0].toUpperCase(),
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
                                    Text(nombre, style: AppTextStyles.heading3),
                                    Text(rol.toUpperCase(),
                                        style: AppTextStyles.hud.copyWith(
                                            fontSize: 10)),
                                  ],
                                ),
                              ),
                              // Prioridad
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '#${m['prioridad']}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: AppColors.error, size: 20),
                                onPressed: () => _quitarMiembro(
                                  m['idusuario_grupo'],
                                  nombre,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: AppColors.primary, size: 20),
                                onPressed: () async {
                                  final detalle = m['usuario_detalle'] as Map<String, dynamic>?;
                                  if (detalle != null) {
                                    context.go('/equipo/editar_usuario', extra: detalle);
                                  }
                                  // Cargar datos completos del usuario
                 
                                  //   final response = await ApiCliente.get(
                                  //   '${ApiConstants.usuarios}${m['usuario']}/',
                                  // );
                                  // if (!context.mounted) return;
                                  // if (response.statusCode == 200) {
                                  //   final usuario = jsonDecode(response.body);
                                  //   context.go('/equipo/editar_usuario', extra: usuario);
                                  // }
                                },
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