import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: Center(
        child: Text("👤 Tu Perfil de Héroe", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
