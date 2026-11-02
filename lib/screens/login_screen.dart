import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'feed_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEntering = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _enterApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isEntering = true;
    });

    final supabase = Supabase.instance.client;
    final usernameClean = _usernameController.text.trim().toLowerCase();

    try {
      // 1. Verificar si el nombre de usuario ya está tomado en Supabase
      final List<dynamic> response = await supabase
          .from('usuarios')
          .select()
          .eq('username', usernameClean);

      String usuarioId;

      if (response.isNotEmpty) {
        // Si el usuario ya existe, tomamos su ID para iniciar sesión
        usuarioId = response[0]['id'];
      } else {
        // 2. Si es nuevo, registramos una cuenta anónima temporal en Auth de Supabase
        final authResponse = await supabase.auth.signUp(
          email: '$usernameClean@failquest.com',
          password: 'Password123!', // Contraseña genérica interna para el MVP
        );

        if (authResponse.user == null) throw Exception("Error al crear credenciales.");
        usuarioId = authResponse.user!.id;

        // 3. Insertamos el perfil público en nuestra tabla de usuarios creada
        await supabase.from('usuarios').insert({
          'id': usuarioId,
          'username': usernameClean,
        });
      }

      if (!mounted) return;

      // Navegamos al feed de la aplicación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FeedScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de conexión: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isEntering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: const Icon(Icons.local_fire_department, color: Colors.purple, size: 60),
                ),
                const SizedBox(height: 24),
                const Text(
                  "FAILQUEST",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  "El club de los retos y misiones fallidas",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  enabled: !_isEntering,
                  decoration: InputDecoration(
                    labelText: "Elige tu nombre de usuario",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixText: "@ ",
                    prefixStyle: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.purple, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Por favor ingresa un nombre para continuar";
                    }
                    if (value.trim().length < 3) {
                      return "El nombre debe tener al menos 3 caracteres";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isEntering ? null : _enterApp,
                    child: _isEntering
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Comenzar Desafío",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
