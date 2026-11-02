import 'package:flutter/material.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: Center(
        child: Text("➕ Crear Nueva Misión", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
