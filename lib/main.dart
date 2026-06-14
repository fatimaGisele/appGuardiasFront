import 'package:flutter/material.dart';
import 'router/app_router.dart';

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
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90D9),),
        useMaterial3: true,)
    );
  }
}


