import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: Center(
        child: Text("🔍 Descubrir Retos Cerca", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
