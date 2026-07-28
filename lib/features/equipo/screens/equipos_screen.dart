import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/equipo_service.dart';

class EquiposScreen extends StatefulWidget {
  const EquiposScreen({super.key});

  @override
  State<EquiposScreen> createState() => _EquiposScreenState();
}

class _EquiposScreenState extends State<EquiposScreen> {
  List<Map<String, dynamic>> _grupos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarGrupos();
  }

  Future<void> _cargarGrupos() async {
    setState(() => _isLoading = true);
    final grupos = await EquipoService.getGrupos();
    setState(() {
      _grupos = grupos;
      _isLoading = false;
    });
  }

  Future<void> _mostrarCrearGrupo() async {
    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nuevo Equipo', style: AppTextStyles.heading2),
            const SizedBox(height: 20),
            Text('Nombre', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextFormField(
              controller: nombreCtrl,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: AppDecorations.inputDecoration(hint: 'Ej: Equipo Noche'),
            ),
            const SizedBox(height: 16),
            Text('Descripción', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextFormField(
              controller: descCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: AppDecorations.inputDecoration(hint: 'Descripción opcional'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: AppDecorations.primaryButton,
                onPressed: () async {
                  if (nombreCtrl.text.isEmpty) return;
                  final result = await EquipoService.crearGrupo(
                    nombre: nombreCtrl.text.trim(),
                    descripcion: descCtrl.text.trim(),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (result['success']) {
                    _cargarGrupos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Equipo creado correctamente'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text('Crear equipo', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Mis Equipos', style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _mostrarCrearGrupo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _cargarGrupos,
              color: AppColors.primary,
              child: _grupos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.group_off_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text('No tenés equipos todavía',
                              style: AppTextStyles.bodySecondary),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _mostrarCrearGrupo,
                            style: AppDecorations.primaryButton.copyWith(
                              minimumSize: WidgetStateProperty.all(
                                const Size(200, 46),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: Text('Crear equipo', style: AppTextStyles.button),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _grupos.length,
                      itemBuilder: (context, index) {
                        final grupo = _grupos[index];
                        return GestureDetector(
                          onTap: () => context.go(
                            '/equipos/${grupo['idgrupo_escalamiento']}',
                            extra: grupo,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: AppDecorations.card,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.group_outlined,
                                      color: AppColors.primary, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(grupo['nombre'] ?? '',
                                          style: AppTextStyles.heading3),
                                      if (grupo['descripcion'] != null &&
                                          grupo['descripcion'].toString().isNotEmpty)
                                        Text(grupo['descripcion'],
                                            style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}