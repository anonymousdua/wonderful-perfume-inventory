import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'routes/route_generator.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  runApp(const WonderfulPerfumesApp());
}

class WonderfulPerfumesApp extends StatelessWidget {
  const WonderfulPerfumesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wonderful Perfumes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: RouteGenerator.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
