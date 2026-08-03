import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/widgets/auth_text_field.dart';

class CrearUsuarioScreen extends StatefulWidget {
  const CrearUsuarioScreen({super.key});

  @override
  State<CrearUsuarioScreen> createState() => _CrearUsuarioScreenState();
}

class _CrearUsuarioScreenState extends State<CrearUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _password2Ctrl = TextEditingController();
  bool _isLoading = false;
  int? _rolSeleccionado;

  final List<Map<String, dynamic>> _roles = [
    {'id': 1, 'nombre': 'Lider'},
    {'id': 2, 'nombre': 'Encargado'},
    {'id': 3, 'nombre': 'Guardia'},
    {'id': 4, 'nombre': 'Relevo'},
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rolSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioná un rol'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      password: _passwordCtrl.text,
      password2: _password2Ctrl.text,
      rolId: _rolSeleccionado!,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/equipos');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['errors'].toString()),
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
        title: Text('Crear Usuario', style: AppTextStyles.heading2),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.card,
                child: Column(
                  children: [
                    AuthTextField(
                      label: 'Nombre',
                      hint: 'Juan',
                      controller: _nombreCtrl,
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Ingresá el nombre' : null,
                    ),
                    AuthTextField(
                      label: 'Apellido',
                      hint: 'Pérez',
                      controller: _apellidoCtrl,
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Ingresá el apellido' : null,
                    ),
                    AuthTextField(
                      label: 'Email',
                      hint: 'usuario@email.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (v) {
                        if (v!.isEmpty) return 'Ingresá el email';
                        if (!v.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    AuthTextField(
                      label: 'Teléfono',
                      hint: '5491112345678',
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: (v) => v!.isEmpty ? 'Ingresá el teléfono' : null,
                    ),
                    AuthTextField(
                      label: 'Contraseña',
                      hint: '••••••••',
                      controller: _passwordCtrl,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (v) {
                        if (v!.isEmpty) return 'Ingresá la contraseña';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    AuthTextField(
                      label: 'Confirmar contraseña',
                      hint: '••••••••',
                      controller: _password2Ctrl,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (v) {
                        if (v!.isEmpty) return 'Confirmá la contraseña';
                        if (v != _passwordCtrl.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),

                    // Selector de rol
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rol', style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _rolSeleccionado,
                          hint: Text('Seleccioná un rol',
                              style: AppTextStyles.bodySecondary),
                          dropdownColor: AppColors.surface,
                          decoration: AppDecorations.inputDecoration(hint: ''),
                          items: _roles.map((rol) {
                            return DropdownMenuItem<int>(
                              value: rol['id'],
                              child: Text(
                                rol['nombre'],
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _rolSeleccionado = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _crear,
                  style: AppDecorations.primaryButton,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Crear usuario', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}