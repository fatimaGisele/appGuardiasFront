import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/home_screen.dart';
import '../features/turnos/screens/crear_turno_screen.dart';
import '../features/calendario/screens/calendario_screen.dart';
import '../features/equipo/screens/equipo_screen.dart';
import '../features/equipo/screens/detalle_equipo_screen.dart';
import '../features/equipo/screens/equipos_screen.dart';
import '../features/equipo/screens/crear_usuario_screen.dart';
import '../features/vacaciones/screens/solicitar_vacacion_screen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/storage_service.dart';
import '../features/dashboard/screens/regular_user_home_screen.dart';
import '../features/vacaciones/screens/aprobar_vacaciones_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const _HomeRouter()),
    GoRoute(
      path: '/turnos',
      builder: (context, state) => const CrearTurnoScreen(),
    ),
    GoRoute(
      path: '/turnos/crear',
      builder: (context, state) => const CrearTurnoScreen(),
    ),
    GoRoute(
      path: '/calendario',
      builder: (context, state) => const CalendarioScreen(),
    ),
    GoRoute(path: '/equipo', builder: (context, state) => const EquipoScreen()),
    GoRoute(
      path: '/equipos',
      builder: (context, state) => const EquiposScreen(),
    ),
    GoRoute(
      path: '/equipos/crear-usuario',
      builder: (context, state) => const CrearUsuarioScreen(),
    ),
    GoRoute(
      path: '/equipos/:id',
      builder: (context, state) {
        final grupo = state.extra as Map<String, dynamic>;
        return DetalleEquipoScreen(
          grupoId: int.parse(state.pathParameters['id']!),
          nombreGrupo: grupo['nombre'] ?? 'Equipo',
        );
      },
    ),
    GoRoute(
      path: '/vacaciones/solicitar',
      builder: (context, state) => const SolicitarVacacionScreen(),
    ),
     GoRoute(
      path: '/vacaciones/aprobar',
      builder: (context, state) => const AprobarVacacionesScreen(),
    ),
  ],
);

class _HomeRouter extends StatelessWidget {
  const _HomeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: StorageService.getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        final usuario = jsonDecode(snapshot.data!);
        final rol = usuario['rol'] ?? '';
        if (rol == 'lider' || rol == 'encargado') {
          return const HomeScreen();
        }
        return const RegularUserHomeScreen();
      },
    );
  }
}