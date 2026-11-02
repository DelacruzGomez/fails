import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  final double targetLat; 
  final double targetLng; 

  const CameraScreen({super.key, required this.targetLat, required this.targetLng});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isNear = false;
  bool _isLoading = true;
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
        _isNear = distanceInMeters <= 150; 
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = "Error al obtener la ubicación. Reintenta.";
      });
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080, 
        maxHeight: 1080,
        imageQuality: 85, 
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Foto capturada con éxito! Lista para subir."),
            backgroundColor: Colors.purple,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al abrir la cámara: $e"),
          backgroundColor: Colors.redAccent,
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
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isNear 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_imageFile == null) ...[
                        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 100),
                        const SizedBox(height: 24),
                        const Text(
                          "¡Estás en la ubicación del reto!",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_imageFile!, height: 300, width: 300, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Reto completado",
                          style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _takePicture,
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: Text(
                          _imageFile == null ? "Tomar Foto de la Misión" : "Tomar otra Foto",
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
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
