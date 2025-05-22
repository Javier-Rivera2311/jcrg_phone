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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un correo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un teléfono';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: communeController,
                decoration: const InputDecoration(labelText: 'Comuna'),
              ),
              TextFormField(
                controller: jobController,
                decoration: const InputDecoration(labelText: 'Trabajo'),
              ),
              TextFormField(
                controller: projectController,
                decoration: const InputDecoration(labelText: 'Proyecto'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addContact,
                child: const Text('Agregar Contacto'),
              ),
            ],
            
          ),
        ),
      ),
    );
  }
}
