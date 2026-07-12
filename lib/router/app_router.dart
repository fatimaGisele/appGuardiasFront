import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/home_screen.dart';
import '../features/turnos/screens/crear_turno_screen.dart';
import '../features/calendario/screens/calendario_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register',builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/turnos',builder: (context, state) => const CrearTurnoScreen()),
    GoRoute(path: '/turnos/crear',builder: (context, state) => const CrearTurnoScreen()),
    GoRoute(path: '/calendario',builder: (context, state) => const CalendarioScreen()),
  ],
);
