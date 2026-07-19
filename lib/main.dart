import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'core/constants/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const GuardiasApp());
}

class GuardiasApp extends StatelessWidget {
  const GuardiasApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Guardias',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.theme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
    );
  }
}
