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
  String status = 'Abierto';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese una descripción'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Abierto', child: Text('Abierto')),
                  DropdownMenuItem(value: 'Cerrado', child: Text('Cerrado')),
                  DropdownMenuItem(
                      value: 'En progreso', child: Text('En Progreso')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => status = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
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
                  : ElevatedButton(
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
                      child: const Text('Crear Ticket'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
