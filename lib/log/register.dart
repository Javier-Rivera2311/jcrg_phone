import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  List<dynamic> departments = [];
  int? selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    try {
      final response = await http.get(Uri.parse('https://backend-jcrg.onrender.com/user/ingresar'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            departments = data['departments'];
          });
        } else {
          setState(() {
            errorMessage = 'Error al cargar departamentos';
          });
        }
      } else {
        setState(() {
          errorMessage = 'No se pudo conectar con el servidor';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de red: $e';
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    final url = Uri.parse('https://backend-jcrg.onrender.com/user/ingresar');

    final body = {
      "name": nameController.text.trim(),
      "mail": emailController.text.trim(),
      "password": passwordController.text,
      "confirmPassword": confirmPasswordController.text,
      "department_id": selectedDepartmentId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          successMessage = "Usuario registrado correctamente";
        });
        // Puedes redirigir al login si quieres:
        // Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = data['error'] ?? 'Error al registrar usuario';
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
      // Fondo azul degradado
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2), // Azul fuerte
              Color(0xFF42A5F5), // Azul medio
              Color(0xFFBBDEFB), // Azul claro
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.person_add, size: 80, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    "Registrar usuario",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black26,
                          offset: Offset(1, 2),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nombre",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) => v == null || v.isEmpty ? "Ingrese su nombre" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Correo institucional",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty ? "Ingrese su correo" : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedDepartmentId,
                    decoration: InputDecoration(
                      labelText: 'Departamento',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.apartment, color: Colors.white),
                    ),
                    dropdownColor: const Color(0xFF42A5F5),
                    iconEnabledColor: Colors.white,
                    items: departments.map<DropdownMenuItem<int>>((dep) {
                      return DropdownMenuItem<int>(
                        value: dep['ID'],
                        child: Text(dep['name_dep'], style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartmentId = value!;
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione un departamento' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty ? "Ingrese su contraseña" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: "Confirmar contraseña",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty ? "Confirme su contraseña" : null,
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage != null)
                    Text(errorMessage!, style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
                  if (successMessage != null)
                    Text(successMessage!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _register();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        elevation: 4,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              "Registrar",
                              style: TextStyle(
                                color: Colors.white, // Fuerza el color blanco para el texto
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        "Volver",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text("¿Ya tienes cuenta? Inicia sesión"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
