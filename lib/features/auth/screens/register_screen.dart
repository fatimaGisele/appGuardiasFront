import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/auth_text_field.dart';

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
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['errors'].toString()),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3748)),
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
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completá tus datos para registrarte',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: _rolSeleccionado,
                            hint: const Text('Seleccioná un rol'),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF7FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF4A90D9), width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90D9),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                      style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      'Iniciá sesión',
                      style: TextStyle(
                        color: Color(0xFF4A90D9),
                        fontWeight: FontWeight.w600,
                      ),
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