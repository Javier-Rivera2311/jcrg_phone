import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FormularyTicket extends StatefulWidget {
  final int workerId;
  final int departmentId;

  const FormularyTicket({
    super.key,
    required this.workerId,
    required this.departmentId,
  });

  @override
  State<FormularyTicket> createState() => _FormularyTicketState();
}

class _FormularyTicketState extends State<FormularyTicket> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String priority = 'Baja';

  bool isLoading = false;

  Future<void> createTicket(
      String title, String description, String priority) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('https://backend-jcrg.onrender.com/user/createTicket'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'priority': priority,
      }),
    );

    if (response.statusCode == 201) {
      print("Ticket creado");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket creado exitosamente')),
      );
      Navigator.pop(context);
    } else {
      print("Error: ${response.statusCode}");
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear el ticket')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Ticket')),
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
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.confirmation_number,
                          size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese un título'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese una descripción'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      prefixIcon: Icon(Icons.priority_high),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                      DropdownMenuItem(value: 'Media', child: Text('Media')),
                      DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => priority = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              await createTicket(
                                titleController.text,
                                descriptionController.text,
                                priority,
                              );
                              setState(() => isLoading = false);
                            }
                          },
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Crear Ticket',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
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
