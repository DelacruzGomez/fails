import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'result_animation_screen.dart'; // <-- IMPORTANTE: Conectamos la nueva pantalla de efectos

class CameraScreen extends StatefulWidget {
  final int challengeId; 
  final double targetLat; 
  final double targetLng; 

  const CameraScreen({
    super.key, 
    required this.challengeId, 
    required this.targetLat, 
    required this.targetLng,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isNear = false;
  bool _isLoading = true;
  bool _isUploading = false;
  String _message = "Verificando tu ubicación...";
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _message = "Por favor, activa el GPS de tu celular.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _message = "Necesitamos permisos de ubicación para validar el reto.";
        });
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude, position.longitude, widget.targetLat, widget.targetLng
      );

      setState(() {
        _isNear = distanceInMeters <= 500; 
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = "Error al obtener la ubicación. Reintenta.";
      });
    }
  }

  Future<void> _takeAndUploadPicture() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800, 
        maxHeight: 800,
        imageQuality: 80, 
      );

      if (pickedFile == null) return;

      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploading = true;
      });

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) throw Exception("Usuario no autenticado");

      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 1. Subir al Storage
      await supabase.storage.from('fotos_retos').upload(
            fileName,
            _imageFile!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // 2. Obtener URL Pública
      final String publicUrl = supabase.storage.from('fotos_retos').getPublicUrl(fileName);

      // 3. Crear registro vinculando el reto dinámico recibido
      await supabase.from('publicaciones').insert({
        'usuario_id': user.id,
        'reto_id': widget.challengeId, 
        'url_foto': publicUrl,
      });

      if (!mounted) return;

      // CAMBIO: Lanzamos la interfaz de juego con sonido y animación de victoria
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultAnimationScreen(isSuccess: true),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);

      // CAMBIO: Si falla la subida por internet, lanzamos la pantalla de Soldado Caído con sonido de derrota
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultAnimationScreen(isSuccess: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Misión del Día", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        : _isUploading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.purple),
                    SizedBox(height: 20),
                    Text("Subiendo tu reto a la comunidad...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _isNear 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 100),
                          const SizedBox(height: 24),
                          const Text(
                            "¡Estás en la ubicación del reto!",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: _takeAndUploadPicture,
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text("Tomar y Subir Foto", style: TextStyle(fontSize: 16, color: Colors.white)),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off_outlined, color: Colors.redAccent, size: 100),
                          const SizedBox(height: 24),
                          Text(
                            _message == "Verificando tu ubicación..." 
                                ? "Estás muy lejos del punto de la misión comercial." 
                                : _message,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                ),
              ),
    );
  }
}