import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormularyMeet extends StatefulWidget {
  final Map<String, dynamic>? meeting;
  const FormularyMeet({Key? key, this.meeting}) : super(key: key);

  @override
  State<FormularyMeet> createState() => _FormularyMeetState();
}

class _FormularyMeetState extends State<FormularyMeet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _urlController;
  late TextEditingController _addressController;

  String _type = 'virtual'; // 'virtual' o 'presencial'
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Corrige el formato de fecha para mostrar solo dd-MM-yyyy en el campo de texto
    String? rawDate = widget.meeting?['date'];
    String formattedDate = '';
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        DateTime date = DateTime.parse(rawDate);
        formattedDate = '${date.day.toString().padLeft(2, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.year}';
      } catch (_) {
        final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(rawDate);
        if (match != null) {
          formattedDate = '${match.group(3)}-${match.group(2)}-${match.group(1)}';
        } else {
          formattedDate = rawDate;
        }
      }
    }
    _titleController = TextEditingController(
        text: widget.meeting?['title'] ?? widget.meeting?['Title'] ?? '');
    _detailsController = TextEditingController(
        text: widget.meeting?['details'] ?? '');
    _dateController = TextEditingController(
        text: formattedDate);
    _timeController = TextEditingController(
        text: widget.meeting?['time'] ?? '');
    _urlController = TextEditingController(
        text: widget.meeting?['url'] ?? '');
    _addressController = TextEditingController(
        text: widget.meeting?['address'] ?? '');
    _type = widget.meeting?['type'] ?? 'virtual';
  }

  Future<void> submitMeet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('https://backend-jcrg.onrender.com/user/addMeeting'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "date": _dateController.text,
        "time": _timeController.text,
        "type": _type,
        "Title": _titleController.text,
        "details": _detailsController.text,
        "url": _type == 'virtual' ? _urlController.text : null,
        "address": _type == 'presencial' ? _addressController.text : null,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reunión creada correctamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la reunión')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _urlController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de Reunión')),
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
                  const Center(
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.groups, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese el título' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _detailsController,
                    decoration: const InputDecoration(
                      labelText: 'Detalles',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese los detalles' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _dateController.text =
                            picked.toLocal().toString().split(' ')[0];
                      }
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Seleccione la fecha' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Hora',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        _timeController.text = picked.format(context);
                      }
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Seleccione la hora' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de reunión',
                      prefixIcon: Icon(Icons.meeting_room),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'presencial',
                        child: Text('Presencial'),
                      ),
                      DropdownMenuItem(
                        value: 'virtual',
                        child: Text('Virtual'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _type = value ?? 'presencial';
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  if (_type == 'virtual')
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL de la reunión',
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => _type == 'virtual'
                          ? (value == null || value.isEmpty
                              ? 'Ingrese la URL de la reunión'
                              : null)
                          : null,
                    ),
                  if (_type == 'virtual') const SizedBox(height: 14),
                  if (_type == 'presencial')
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => _type == 'presencial'
                          ? (value == null || value.isEmpty
                              ? 'Ingrese la dirección'
                              : null)
                          : null,
                    ),
                  if (_type == 'presencial') const SizedBox(height: 14),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: submitMeet,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Guardar',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
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
