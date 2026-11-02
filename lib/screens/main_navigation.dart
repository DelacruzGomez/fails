import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'feed_screen.dart';
import 'discover_screen.dart';
import 'camera_screen.dart'; // Importamos la pantalla de la cámara
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const DiscoverScreen(),
    const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.purple))), // Pantalla temporal de carga
    const ProfileScreen(),
  ];

  // Función que controla los clics en la barra inferior
  void _onItemTapped(int index) async {
    // Si presiona la pestaña del centro (Misión - Índice 2), abrimos el validador GPS directamente
    if (index == 2) {
      _openChallengeCamera();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  // Descarga el último reto e inicia la validación geográfica
  Future<void> _openChallengeCamera() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.purple)),
    );

    try {
      final supabase = Supabase.instance.client;
      final List<dynamic> challenges = await supabase
          .from('retos_diarios')
          .select()
          .order('id', ascending: false)
          .limit(1);

      if (!mounted) return;
      Navigator.pop(context); // Cierra el indicador de carga

      if (challenges.isNotEmpty) {
        final latestChallenge = challenges.first;
        
        // Abre el validador nativo de tu cámara
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraScreen(
              challengeId: latestChallenge['id'],
              targetLat: latestChallenge['latitud'],
              targetLng: latestChallenge['longitud'],
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar misión: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.purpleAccent,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Retos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 32, color: Colors.purple),
              label: 'Misión',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
