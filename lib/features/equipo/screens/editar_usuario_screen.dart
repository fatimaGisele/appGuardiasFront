import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/widgets/auth_text_field.dart';
import 'dart:convert';

class EditarUsuarioScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const EditarUsuarioScreen({super.key, required this.usuario});

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidoCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _observacionesCtrl;
  TimeOfDay? _horaEntrada;
  TimeOfDay? _horaSalida;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {'id': 1, 'nombre': 'Lider'},
    {'id': 2, 'nombre': 'Encargado'},
    {'id': 3, 'nombre': 'Guardia'},
    {'id': 4, 'nombre': 'Relevo'},
  ];
  int? _rolSeleccionado;

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    _nombreCtrl = TextEditingController(text: u['nombre'] ?? '');
    _apellidoCtrl = TextEditingController(text: u['apellido'] ?? '');
    _telefonoCtrl = TextEditingController(text: u['telefono'] ?? '');
    _observacionesCtrl =
        TextEditingController(text: u['observaciones_jornada'] ?? '');
    _rolSeleccionado = u['rol'];

    // Cargar horarios existentes
    if (u['hora_entrada'] != null) {
      final parts = u['hora_entrada'].split(':');
      _horaEntrada = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    if (u['hora_salida'] != null) {
      final parts = u['hora_salida'].split(':');
      _horaSalida = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHora({required bool esEntrada}) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: esEntrada
          ? (_horaEntrada ?? const TimeOfDay(hour: 8, minute: 0))
          : (_horaSalida ?? const TimeOfDay(hour: 17, minute: 0)),
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
    setState(() {
      if (esEntrada) {
        _horaEntrada = hora;
      } else {
        _horaSalida = hora;
      }
    });
  }

  String _formatoHora(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final body = {
      'nombre': _nombreCtrl.text.trim(),
      'apellido': _apellidoCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'rol': _rolSeleccionado,
      'observaciones_jornada': _observacionesCtrl.text.trim(),
      if (_horaEntrada != null) 'hora_entrada': _formatoHora(_horaEntrada!),
      if (_horaSalida != null) 'hora_salida': _formatoHora(_horaSalida!),
    };

    final response = await ApiCliente.put(
      '${ApiConstants.usuarios}${widget.usuario['idusuario']}/',
      body,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario actualizado correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/equipos');
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Editar Usuario', style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/equipos'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Datos personales
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Datos personales', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Nombre',
                      hint: 'Nombre',
                      controller: _nombreCtrl,
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),Text(
                        'Actual: ${widget.usuario['nombre']}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                    AuthTextField(
                      label: 'Apellido',
                      hint: 'Apellido',
                      controller: _apellidoCtrl,
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    Text(
                      'Actual: ${widget.usuario['apellido']}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthTextField(
                      label: 'Teléfono',
                      hint: '5491112345678',
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    Text(
                      'Actual: ${widget.usuario['telefono']}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rol
                    Text('Rol', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: _rolSeleccionado,
                      dropdownColor: AppColors.surface,
                      decoration:
                          AppDecorations.inputDecoration(hint: ''),
                      items: _roles.map((r) {
                        return DropdownMenuItem<int>(
                          value: r['id'],
                          child: Text(r['nombre'],
                              style: const TextStyle(
                                  color: AppColors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => _rolSeleccionado = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Jornada laboral
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jornada laboral', style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text('Lunes a viernes — francos: sábado y domingo',
                        style: AppTextStyles.caption),
                    const SizedBox(height: 16),

                    // Horarios
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Entrada', style: AppTextStyles.label),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () =>
                                    _seleccionarHora(esEntrada: true),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.bordeColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.login_outlined,
                                          color: AppColors.primary,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        _horaEntrada != null
                                            ? _formatoHora(_horaEntrada!)
                                            : 'Seleccionar',
                                        style: TextStyle(
                                          color: _horaEntrada != null
                                              ? AppColors.textPrimary
                                              : AppColors.textHint,
                                          fontSize: 14,
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
                              Text('Salida', style: AppTextStyles.label),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () =>
                                    _seleccionarHora(esEntrada: false),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.bordeColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.logout_outlined,
                                          color: AppColors.accent,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        _horaSalida != null
                                            ? _formatoHora(_horaSalida!)
                                            : 'Seleccionar',
                                        style: TextStyle(
                                          color: _horaSalida != null
                                              ? AppColors.textPrimary
                                              : AppColors.textHint,
                                          fontSize: 14,
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

                    // Observaciones
                    Text('Observaciones', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _observacionesCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppDecorations.inputDecoration(
                        hint: 'Ej: Horario especial los viernes...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardar,
                  style: AppDecorations.primaryButton,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Guardar cambios', style: AppTextStyles.button),
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