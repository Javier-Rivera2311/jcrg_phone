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
      appBar: AppBar(title: const Text("Registrar usuario")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nombre", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? "Ingrese su nombre" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Correo institucional", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? "Ingrese su correo" : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedDepartmentId,
                  decoration: const InputDecoration(labelText: 'Departamento', border: OutlineInputBorder()),
                  items: departments.map<DropdownMenuItem<int>>((dep) {
                    return DropdownMenuItem<int>(
                      value: dep['ID'],
                      child: Text(dep['name_dep']),
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
                  decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? "Ingrese su contraseña" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(labelText: "Confirmar contraseña", border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? "Confirme su contraseña" : null,
                ),
                const SizedBox(height: 20),
                if (errorMessage != null)
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                if (successMessage != null)
                  Text(successMessage!, style: const TextStyle(color: Colors.green)),
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
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text("Registrar"),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("¿Ya tienes cuenta? Inicia sesión"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
