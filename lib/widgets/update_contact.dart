import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditContactForm extends StatefulWidget {
  final Map<String, dynamic> contact;

  const EditContactForm({Key? key, required this.contact}) : super(key: key);

  @override
  State<EditContactForm> createState() => _EditContactFormState();
}

class _EditContactFormState extends State<EditContactForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController communeController;
  late TextEditingController jobController;
  late TextEditingController projectController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.contact['Name']);
    emailController = TextEditingController(text: widget.contact['email']);
    phoneController = TextEditingController(text: widget.contact['Phone']);
    communeController = TextEditingController(text: widget.contact['Commune']);
    jobController = TextEditingController(text: widget.contact['job']);
    projectController = TextEditingController(text: widget.contact['project']);
  }

  Future<void> editContact() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://backend-jcrg.onrender.com/user/updateContact'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id': widget.contact['id'],
            'Name': nameController.text,
            'email': emailController.text,
            'Phone': phoneController.text,
            'Commune': communeController.text,
            'job': jobController.text,
            'project': projectController.text,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contacto actualizado con éxito')),
          );
          Navigator.pop(context, true); // Devuelve true para indicar éxito
        } else {
          throw Exception('Error al actualizar el contacto');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

Future<void> deleteContact(String email) async {
  try {
    final response = await http.post(
      Uri.parse('https://backend-jcrg.onrender.com/user/deleteContact'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacto eliminado con éxito')),
      );
      Navigator.pop(context, true); // Opcional: regresar tras borrar
    } else {
      throw Exception('Error al eliminar el contacto');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Contacto'),
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
                onPressed: editContact,
                child: const Text('Guardar Cambios'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: const Text('¿Estás seguro de que deseas eliminar este contacto?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await deleteContact(emailController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Eliminar Contacto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
