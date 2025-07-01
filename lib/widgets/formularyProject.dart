import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormularyProject extends StatefulWidget {
  const FormularyProject({super.key});

  @override
  State<FormularyProject> createState() => _FormularyProjectState();
}

class _FormularyProjectState extends State<FormularyProject> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameProjectController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  final TextEditingController _workersController = TextEditingController();
  final TextEditingController _localPathController = TextEditingController();

  List<String> _workersList = [];
  String? _selectedManager;

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    final response = await http
        .get(Uri.parse('https://backend-jcrg.onrender.com/user/listWorker'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meetings = data['meetings'];
      setState(() {
        _workersList = meetings != null
            ? List<String>.from(meetings.map((w) => w['Name']))
            : [];
      });
    }
  }

  @override
  void dispose() {
    _nameProjectController.dispose();
    _urlController.dispose();
    _cityController.dispose();
    _endDateController.dispose();
    _observationsController.dispose();
    _workersController.dispose();
    _localPathController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    final url = Uri.parse('https://backend-jcrg.onrender.com/user/addProject');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "Name_project": _nameProjectController.text,
        "url": _urlController.text,
        "city": _cityController.text,
        "end_date": _endDateController.text,
        "observations": _observationsController.text,
        "workers": _workersController.text,
        "local_path": _localPathController.text,
        "manager": _selectedManager,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto creado correctamente')),
      );
      _formKey.currentState?.reset();
      _nameProjectController.clear();
      _urlController.clear();
      _cityController.clear();
      _endDateController.clear();
      _observationsController.clear();
      _workersController.clear();
      _localPathController.clear();
      setState(() {
        _selectedManager = null;
      });
      Navigator.pop(context, true); // Para recargar la lista al volver
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear el proyecto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de Proyecto')),
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
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.folder, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameProjectController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del proyecto',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese el nombre'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese la URL'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese la ciudad'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _endDateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de finalización',
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
                        _endDateController.text =
                            picked.toLocal().toString().split(' ')[0];
                      }
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Seleccione la fecha'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _observationsController,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _workersController,
                    decoration: const InputDecoration(
                      labelText: 'Trabajadores',
                      prefixIcon: Icon(Icons.people),
                      border: OutlineInputBorder(),
                      hintText: 'Separados por coma',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese al menos un trabajador'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _localPathController,
                    decoration: const InputDecoration(
                      labelText: 'Ruta local',
                      prefixIcon: Icon(Icons.folder_open),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedManager,
                    decoration: const InputDecoration(
                      labelText: 'Encargado',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: _workersList.map((worker) {
                      return DropdownMenuItem<String>(
                        value: worker,
                        child: Text(worker),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedManager = value),
                    validator: (value) =>
                        value == null ? 'Seleccione un encargado' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        submitForm();
                      }
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Guardar',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
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