import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Cambiamos la importación al Login

void main() {
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
      home: const LoginScreen(), // Ahora la app inicia en el Login
    );
  }
}
