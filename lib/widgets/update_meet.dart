import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateMeetScreen extends StatefulWidget {
  final Map<String, dynamic> meeting;

  const UpdateMeetScreen({Key? key, required this.meeting}) : super(key: key);

  @override
  State<UpdateMeetScreen> createState() => _UpdateMeetScreenState();
}

class _UpdateMeetScreenState extends State<UpdateMeetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController typeController;
  late TextEditingController urlController;
  late TextEditingController addressController;
  late TextEditingController detailsController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.meeting['title'] ?? widget.meeting['Title'] ?? '');
    dateController = TextEditingController(text: widget.meeting['date'] ?? '');
    timeController = TextEditingController(text: widget.meeting['time'] ?? '');
    typeController = TextEditingController(text: widget.meeting['type'] ?? '');
    urlController = TextEditingController(text: widget.meeting['url'] ?? '');
    addressController = TextEditingController(text: widget.meeting['address'] ?? '');
    detailsController = TextEditingController(text: widget.meeting['details'] ?? '');
  }

  Future<void> updateMeeting() async {
    if (_formKey.currentState!.validate()) {
      try {
        final id = widget.meeting['id'] ?? widget.meeting['ID'];
        final response = await http.put(
          Uri.parse('https://backend-jcrg.onrender.com/user/updateMeeting/$id'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'title': titleController.text,
            'date': dateController.text,
            'time': timeController.text,
            'type': typeController.text,
            'url': urlController.text,
            'address': addressController.text,
            'details': detailsController.text,
          }),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reunión actualizada con éxito')),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Error al actualizar la reunión');
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
        title: const Text('Editar Reunión'),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa un título' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha (YYYY-MM-DD)',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa una fecha' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: 'Hora (HH:MM)',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa una hora' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo (virtual/presencial)',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa el tipo' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL (si es virtual)',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección (si es presencial)',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: detailsController,
                    decoration: const InputDecoration(
                      labelText: 'Detalles',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: updateMeeting,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
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
