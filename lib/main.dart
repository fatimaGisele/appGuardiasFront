import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'core/constants/app_theme.dart';

void main() {
  runApp(const GuardiasApp());
}

class GuardiasApp extends StatelessWidget {
  const GuardiasApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Guardias Demo',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.theme,
    );
  }
}
