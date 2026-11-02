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
    final emailGen = '$usernameClean@failquest.com';
    const passwordGen = 'Password123!';

    try {
      // 1. Intentar iniciar sesión directamente con el usuario
      try {
        await supabase.auth.signInWithPassword(
          email: emailGen,
          password: passwordGen,
        );
      } on AuthException catch (_) {
        // 2. Si el inicio falla, significa que el usuario es nuevo: lo registramos
        await supabase.auth.signUp(
          email: emailGen,
          password: passwordGen,
        );

        final user = supabase.auth.currentUser;
        if (user != null) {
          // 3. Guardamos su perfil público en la tabla de usuarios
          await supabase.from('usuarios').insert({
            'id': user.id,
            'username': usernameClean,
          });
        }
      }

      if (!mounted) return;

      // Navegamos al feed manteniendo la sesión activa en segundo plano
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FeedScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de ingreso: ${e.toString()}"),
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
