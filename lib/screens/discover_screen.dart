import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'camera_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<dynamic> _activeChallenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayChallenges();
  }

  // Descarga todos los retos creados en las últimas 24 horas
  Future<void> _loadTodayChallenges() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('retos_diarios')
          .select()
          .order('created_at', ascending: false); // En producción usar filtro de 24h

      setState(() {
        _activeChallenges = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("MISIONES DISPONIBLES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _activeChallenges.isEmpty
              ? const Center(child: Text("No hay más misiones por hoy.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: _activeChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = _activeChallenges[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars, color: Colors.amber, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                "Reto #${challenge['id']}",
                                style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            challenge['titulo'],
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                // Navega a la cámara mandando los datos específicos del reto elegido
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CameraScreen(
                                      challengeId: challenge['id'],
                                      targetLat: challenge['latitud'],
                                      targetLng: challenge['longitud'],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.gps_fixed, color: Colors.white, size: 18),
                              label: const Text("Cumplir Reto ahora", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
