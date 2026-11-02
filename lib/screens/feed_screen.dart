import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'camera_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Timer _timer;
  List<dynamic> _realPosts = [];
  bool _isLoadingFeed = true;

  @override
  void initState() {
    super.initState();
    _fetchRealPosts();
    // Actualiza los contadores de tiempo en pantalla cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Descarga las publicaciones reales de la base de datos de Supabase
  Future<void> _fetchRealPosts() async {
    try {
      final supabase = Supabase.instance.client;
      // Descargamos las publicaciones ordenadas por fecha
      final data = await supabase
          .from('publicaciones')
          .select('*, usuarios(username)') // Hace un "JOIN" para traer el nombre de usuario
          .order('created_at', ascending: false);

      setState(() {
        _realPosts = data;
        _isLoadingFeed = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFeed = false;
      });
    }
  }

  String _getRemainingTime(String createdAtString) {
    final createdAt = DateTime.parse(createdAtString).toLocal();
    final expiresAt = createdAt.add(const Duration(hours: 24));
    final difference = expiresAt.difference(DateTime.now());

    if (difference.isNegative) {
      return "Expirado";
    }

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }

  Future<void> _vote(int postId, String column, int currentCount, int index) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase
          .from('publicaciones')
          .update({column: currentCount + 1})
          .eq('id', postId);
      
      setState(() {
        _realPosts[index][column] = currentCount + 1;
      });
    } catch (e) {
      // Error silencioso de votación
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("FAILQUEST", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoadingFeed
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _realPosts.isEmpty
              ? const Center(
                  child: Text(
                    "No hay retos subidos hoy.\n¡Sé el primero!",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchRealPosts,
                  color: Colors.purple,
                  child: ListView.builder(
                    itemCount: _realPosts.length,
                    itemBuilder: (context, index) {
                      final post = _realPosts[index];
                      final timeRemaining = _getRemainingTime(post['created_at']);
                      final username = post['usuarios'] != null ? post['usuarios']['username'] : 'anonimo';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "@$username",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.redAccent),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.timer, color: Colors.redAccent, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          timeRemaining,
                                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.zero,
                              child: Image.network(
                                post['url_foto'],
                                height: 350,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 350,
                                    color: const Color(0xFF2D2D2D),
                                    child: const Center(child: Icon(Icons.broken_image, color: Colors.white30, size: 50)),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.withValues(alpha: 0.2),
                                      side: const BorderSide(color: Colors.green),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    onPressed: () => _vote(post['id'], 'votos_heroe', post['votos_heroe'], index),
                                    icon: const Icon(Icons.emoji_events, color: Colors.green),
                                    label: Text("Héroe (${post['votos_heroe']})", style: const TextStyle(color: Colors.white)),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange.withValues(alpha: 0.2),
                                      side: const BorderSide(color: Colors.orange),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    onPressed: () => _vote(post['id'], 'votos_fallo', post['votos_fallo'], index),
                                    icon: const Icon(Icons.shield, color: Colors.orange),
                                    label: Text("Fallo (${post['votos_fallo']})", style: const TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraScreen(
                targetLat: -12.0463,
                targetLng: -77.0310,
              ),
            ),
          );
        },
        icon: const Icon(Icons.location_on, color: Colors.white),
        label: const Text("Ir al Reto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
