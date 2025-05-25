import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jcrg_phone/screens/navigate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;

 void _login() async {
  setState(() {
    isLoading = true;
    errorMessage = null;
  });

  final url = Uri.parse('https://backend-jcrg.onrender.com/user/login');

  final body = {
    "email": emailController.text.trim(),
    "password": passwordController.text,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', data['name'] ?? '');
      await prefs.setString('userEmail', data['email']);
      await prefs.setInt('department_id', data['department_id']);

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        errorMessage = data['error'] ?? 'Credenciales inválidas';
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = "Error de red: $e";
    });
  }

  setState(() {
    isLoading = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  "Iniciar Sesión",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Ingrese su correo" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Ingrese su contraseña" : null,
                ),
                const SizedBox(height: 24),
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _login();
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text("Ingresar"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text("Registrar"),
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
