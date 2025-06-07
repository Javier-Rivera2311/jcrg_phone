import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormularyTask extends StatefulWidget {
  const FormularyTask({super.key});

  @override
  State<FormularyTask> createState() => _FormularyTaskState();
}

class _FormularyTaskState extends State<FormularyTask> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateFinishController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<String> _workersList = [];
  List<Map<String, dynamic>> _categoriesList = [];

  String? _selectedCategoryId;
  List<String> _selectedWorkers = [];

  @override
  void initState() {
    super.initState();
    fetchWorkers();
    fetchCategories();
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

  Future<void> fetchCategories() async {
    final response = await http
        .get(Uri.parse('https://backend-jcrg.onrender.com/user/Category'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meetings = data['meetings'];
      setState(() {
        _categoriesList =
            meetings != null ? List<Map<String, dynamic>>.from(meetings) : [];
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateFinishController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    final url = Uri.parse('https://backend-jcrg.onrender.com/user/addTask');
    // Buscar el nombre de la categoría seleccionada
    final selectedCategory = _categoriesList.firstWhere(
      (cat) => cat['id'].toString() == _selectedCategoryId,
      orElse: () => {},
    );
    final selectedCategoryName = selectedCategory['name'] ?? '';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "title": _titleController.text,
        "description": _descriptionController.text,
        "date_finish": _dateFinishController.text,
        "workers": _selectedWorkers.join(', '),
        "category_name": selectedCategoryName,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea creada correctamente')),
      );
      _formKey.currentState?.reset();
      _titleController.clear();
      _descriptionController.clear();
      _dateFinishController.clear();
      setState(() {
        _selectedCategoryId = null;
        _selectedWorkers = [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la tarea')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de Tarea')),
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
                      child:
                          Icon(Icons.assignment, size: 40, color: Colors.white),
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
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese el título'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese la descripción'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _dateFinishController,
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
                        _dateFinishController.text =
                            picked.toLocal().toString().split(' ')[0];
                      }
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Seleccione la fecha'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final List<String>? result = await showDialog(
                        context: context,
                        builder: (context) {
                          List<String> tempSelected =
                              List.from(_selectedWorkers);
                          return StatefulBuilder(
                            builder: (context, setStateDialog) {
                              return AlertDialog(
                                title: const Text('Selecciona trabajadores'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: _workersList.map((worker) {
                                      return CheckboxListTile(
                                        value: tempSelected.contains(worker),
                                        title: Text(worker),
                                        onChanged: (checked) {
                                          setStateDialog(() {
                                            if (checked == true) {
                                              if (!tempSelected
                                                  .contains(worker)) {
                                                tempSelected.add(worker);
                                              }
                                            } else {
                                              tempSelected.remove(worker);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                        context, _selectedWorkers),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(
                                        context, tempSelected.toSet().toList()),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                      if (result != null) {
                        setState(() {
                          _selectedWorkers = result;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Trabajadores',
                          hintText: 'Selecciona uno o más',
                          prefixIcon: Icon(Icons.people),
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(
                          text: _selectedWorkers.isEmpty
                              ? ''
                              : _selectedWorkers.join(', '),
                        ),
                        validator: (value) => _selectedWorkers.isEmpty
                            ? 'Seleccione al menos un trabajador'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: _categoriesList.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: Text(cat['name']),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategoryId = value),
                    validator: (value) =>
                        value == null ? 'Seleccione una categoría' : null,
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
