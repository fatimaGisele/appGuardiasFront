import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../../../core/constants/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  bool _isLoading = false;
  int? _rolSeleccionado;

  // Roles disponibles — deben coincidir con los ids de la BD
  final List<Map<String, dynamic>> _roles = [
    {'id': 1, 'nombre': 'Lider'},
    {'id': 2, 'nombre': 'Encargado'},
    {'id': 3, 'nombre': 'Guardia'},
    {'id': 4, 'nombre': 'Relevo'},
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rolSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná un rol')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      password: _passwordController.text,
      password2: _password2Controller.text,
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
      context.go('/login');
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Text(
                'Crear cuenta',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                'Completá tus datos para registrarte',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppDecorations.card,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'Nombre',
                        hint: 'Juan',
                        controller: _nombreController,
                        prefixIcon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Ingresá tu nombre' : null,
                      ),
                      AuthTextField(
                        label: 'Apellido',
                        hint: 'Pérez',
                        controller: _apellidoController,
                        prefixIcon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Ingresá tu apellido' : null,
                      ),
                      AuthTextField(
                        label: 'Email',
                        hint: 'tu@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) {
                          if (v!.isEmpty) return 'Ingresá tu email';
                          if (!v.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),
                      AuthTextField(
                        label: 'Teléfono',
                        hint: '5491112345678',
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: (v) => v!.isEmpty ? 'Ingresá tu teléfono' : null,
                      ),
                      AuthTextField(
                        label: 'Contraseña',
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (v) {
                          if (v!.isEmpty) return 'Ingresá tu contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      AuthTextField(
                        label: 'Confirmar contraseña',
                        hint: '••••••••',
                        controller: _password2Controller,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (v) {
                          if (v!.isEmpty) return 'Confirmá tu contraseña';
                          if (v != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),

                      // Selector de rol
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rol',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: _rolSeleccionado,
                            hint: const Text('Seleccioná un rol', style: AppTextStyles.bodySecondary),
                            decoration: AppDecorations.inputDecoration(hint: ''),
                            items: _roles.map((rol) {
                              return DropdownMenuItem<int>(
                                value: rol['id'],
                                child: Text(rol['nombre']),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _rolSeleccionado = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Botón registrar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
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
                              : const Text(
                                  'Crear cuenta',
                                  style: AppTextStyles.button,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿Ya tenés cuenta? ',
                      style: AppTextStyles.bodySecondary),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      'Iniciá sesión',
                      style: AppTextStyles.link,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}