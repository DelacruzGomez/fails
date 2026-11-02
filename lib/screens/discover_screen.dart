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

  Future<void> _loadTodayChallenges() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('retos_diarios')
          .select()
          .order('created_at', ascending: false);

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
        title: const Text("MISIONES VIGENTES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
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
                    final String tag = challenge['etiqueta'] ?? 'global';
                    final bool requiresGps = challenge['requiere_gps'] ?? false;

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Hashtag estilo TikTok/Filtro geográfico
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "#$tag",
                                  style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              // Indicador de tipo de reto
                              Row(
                                children: [
                                  Icon(
                                    requiresGps ? Icons.location_on : Icons.bolt,
                                    color: requiresGps ? Colors.redAccent : Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    requiresGps ? "Zona Específica" : "Acción Libre",
                                    style: TextStyle(
                                      color: requiresGps ? Colors.redAccent : Colors.amber, 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            challenge['titulo'],
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            requiresGps 
                                ? "📍 Debes trasladarte al punto de encuentro para desbloquear." 
                                : "📱 ¡Puedes cumplir esta misión desde cualquier lugar ahora mismo!",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CameraScreen(
                                      challengeId: challenge['id'],
                                      targetLat: challenge['latitud'],
                                      targetLng: challenge['longitud'],
                                      requiresGps: requiresGps, // Pasamos el nuevo parámetro
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.center_focus_strong, color: Colors.white, size: 18),
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
