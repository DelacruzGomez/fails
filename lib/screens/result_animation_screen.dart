import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class ResultAnimationScreen extends StatefulWidget {
  final bool isSuccess; // true si cumplió la misión, false si falló/expiró

  const ResultAnimationScreen({super.key, required this.isSuccess});

  @override
  State<ResultAnimationScreen> createState() => _ResultAnimationScreenState();
}

class _ResultAnimationScreenState extends State<ResultAnimationScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playFeedbackSystem();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Activa el sistema de sonido según el resultado obtenido
  Future<void> _playFeedbackSystem() async {
    try {
      if (widget.isSuccess) {
        // Sonido de victoria / subida de nivel (Cargado directo de internet para pruebas rápidas)
        await _audioPlayer.play(UrlSource('https://mixkit.co'));
      } else {
        // Sonido de derrota / soldado caído
        await _audioPlayer.play(UrlSource('https://mixkit.co'));
      }
    } catch (e) {
      // Manejo silencioso de errores de audio
    }

    // Espera 3.5 segundos reproduciendo el efecto antes de regresar al menú automáticamente
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      Navigator.pop(context); // Cierra la pantalla de recompensa
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // RENDERIZADO DE LAS ANIMACIONES LOTTIE CON MOVIMIENTO FLUIDO
              widget.isSuccess
                  ? Lottie.network(
                      'https://lottiefiles.com', // Animación de trofeo brillante
                      height: 250,
                      repeat: false,
                    )
                  : Lottie.network(
                      'https://lottiefiles.com', // Animación de calavera / alerta de fallo
                      height: 250,
                      repeat: false,
                    ),
              const SizedBox(height: 30),
              
              // Texto del estatus con tipografía arcade llamativa
              Text(
                widget.isSuccess ? "¡MISIÓN CUMPLIDA! 🏆" : "¡SOLDADO CAÍDO! 🛡️",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: widget.isSuccess ? Colors.greenAccent : Colors.redAccent,
                  shadows: [
                    Shadow(
                      color: widget.isSuccess ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5),
                      blurRadius: 15,
                    )
                  ]
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.isSuccess 
                    ? "Tu foto ha sido enviada al feed global. Sumaste +50 Puntos."
                    : "No lograste validar las coordenadas a tiempo o cancelaste el reto.",
                style: const TextStyle(color: Colors.grey, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
