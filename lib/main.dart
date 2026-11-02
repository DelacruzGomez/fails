import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de iniciar Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase con tus credenciales reales
  await Supabase.initialize(
    url: 'https://hrxldynbmgoayjjutqkp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhyeGxkeW5ibWdvYXlqanV0cWtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM0NjQ1OTQsImV4cCI6MjEwOTA0MDU5NH0.YE-ojr9sABokwk5NoQYdVEVtqJGqoNIe2C5zXIREmrc', // Reemplaza esto con tu clave copiada del paso 2
  );

  runApp(const FailQuestApp());
}

class FailQuestApp extends StatelessWidget {
  const FailQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FailQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}
