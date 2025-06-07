import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnterContactForm extends StatefulWidget {
  const EnterContactForm({Key? key}) : super(key: key);

  @override
  State<EnterContactForm> createState() => _EnterContactFormState();
}

class _EnterContactFormState extends State<EnterContactForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController communeController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController projectController = TextEditingController();

  Future<void> addContact() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://backend-jcrg.onrender.com/user/addContact'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'Name': nameController.text,
            'email': emailController.text,
            'Phone': phoneController.text,
            'Commune': communeController.text,
            'job': jobController.text,
            'project': projectController.text,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contacto agregado con éxito')),
          );
          Navigator.pop(context, true); // Devuelve true para indicar éxito
        } else {
          throw Exception('Error al agregar el contacto');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Contacto'),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un correo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un teléfono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: communeController,
                    decoration: const InputDecoration(
                      labelText: 'Comuna',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: jobController,
                    decoration: const InputDecoration(
                      labelText: 'Trabajo',
                      prefixIcon: Icon(Icons.work),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: projectController,
                    decoration: const InputDecoration(
                      labelText: 'Proyecto',
                      prefixIcon: Icon(Icons.assignment),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: addContact,
                    icon: const Icon(Icons.save),
                    label: const Text('Agregar Contacto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
