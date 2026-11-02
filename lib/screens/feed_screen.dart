import 'dart:async';
import 'package:flutter/material.dart';
import 'camera_screen.dart'; // Importamos la pantalla de validación GPS

class DummyPost {
  final String username;
  final String imageUrl;
  final DateTime createdAt;
  int heroesCount;
  int failsCount;

  DummyPost({
    required this.username,
    required this.imageUrl,
    required this.createdAt,
    this.heroesCount = 0,
    this.failsCount = 0,
  });
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Timer _timer;
  
  final List<DummyPost> _posts = [
    DummyPost(
      username: "Carlos_Dev",
      imageUrl: "https://unsplash.com",
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      heroesCount: 24,
      failsCount: 5,
    ),
    DummyPost(
      username: "Maria_Lima",
      imageUrl: "https://unsplash.com",
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      heroesCount: 12,
      failsCount: 45,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getRemainingTime(DateTime createdAt) {
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
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final timeRemaining = _getRemainingTime(post.createdAt);

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
                        "@${post.username}",
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
                    post.imageUrl,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 350,
                        color: Colors.grey,
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
                        onPressed: () {
                          setState(() => post.heroesCount++);
                        },
                        icon: const Icon(Icons.emoji_events, color: Colors.green),
                        label: Text("Héroe (${post.heroesCount})", style: const TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.withValues(alpha: 0.2),
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          setState(() => post.failsCount++);
                        },
                        icon: const Icon(Icons.shield, color: Colors.orange),
                        label: Text("Fallo (${post.failsCount})", style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      // BOTÓN FLOTANTE: Lleva al usuario a validar su ubicación
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraScreen(
                // Mandamos coordenadas de prueba (Plaza de Armas de Lima)
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
