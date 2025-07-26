import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jcrg_phone/widgets/contact_selector_dialog.dart';
import 'package:jcrg_phone/widgets/worker_selector_dialog.dart';
import 'package:jcrg_phone/widgets/manager_selector_dialog.dart';

// Ensure that 'contact_selector_dialog.dart', 'worker_selector_dialog.dart' and 'manager_selector_dialog.dart' exist in 'lib/widgets' and contain:
// class ContactSelectorDialog extends StatelessWidget { ... }
// class WorkerSelectorDialog extends StatelessWidget { ... }
// class ManagerSelectorDialog extends StatelessWidget { ... }

class FormularyProject extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? initialData;

  const FormularyProject({super.key, this.isEdit = false, this.initialData});

  @override
  State<FormularyProject> createState() => _FormularyProjectState();
}

class _FormularyProjectState extends State<FormularyProject> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameProjectController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _initDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _dateDeliveriesController =
      TextEditingController();
  final TextEditingController _deliveriesController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  final TextEditingController _localPathController = TextEditingController();
  final TextEditingController _mandateController = TextEditingController();
  final TextEditingController _externalController = TextEditingController();
  final TextEditingController _contractsController = TextEditingController();

  List<String> _workersList = [];
  String? _selectedManager;
  List<String> _selectedWorkers = [];
  List<Map<String, dynamic>> _contactsList = [];
  List<String> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    fetchWorkers();
    fetchContacts();
    if (widget.isEdit && widget.initialData != null) {
      _populateInitialData();
    }
  }

  void _populateInitialData() {
    final data = widget.initialData!;
    _nameProjectController.text = data['Name_project'] ?? '';
    _cityController.text = data['city'] ?? '';
    _initDateController.text = data['init_date'] ?? '';
    _endDateController.text = data['end_date'] ?? '';
    _dateDeliveriesController.text = data['date_deliveries'] ?? '';
    _deliveriesController.text = data['deliveries']?.toString() ?? '';
    _observationsController.text = data['observations'] ?? '';
    _localPathController.text = data['path'] ?? '';
    _mandateController.text = data['mandate']?.toString() ?? '';
    _externalController.text = data['external']?.toString() ?? '';
    _contractsController.text = data['contracts']?.toString() ?? '';
    _selectedManager = data['in_charge'];

    // Convertir string de trabajadores a lista
    if (data['workers'] != null && data['workers'].toString().isNotEmpty) {
      _selectedWorkers = data['workers'].toString().split(', ');
    }

    // Convertir string de contactos externos a lista
    if (data['external'] != null && data['external'].toString().isNotEmpty) {
      _selectedContacts = data['external'].toString().split(', ');
    }
  }

  Future<void> fetchContacts() async {
    try {
      final response = await http
          .get(Uri.parse('https://backend-jcrgapp.onrender.com/user/Contacts'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> usuarios = data['usuarios'];
        usuarios.sort((a, b) => (a['Name'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((b['Name'] ?? '').toString().toLowerCase()));
        if (mounted) {
          setState(() {
            _contactsList = List<Map<String, dynamic>>.from(usuarios);
          });
        }
      } else {
        throw Exception('Error al cargar los contactos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchWorkers() async {
    try {
      final response = await http.get(
          Uri.parse('https://backend-jcrgapp.onrender.com/user/listWorker'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meetings = data['meetings'];
        setState(() {
          _workersList = meetings != null
              ? List<String>.from(meetings.map((w) => w['Name']))
              : [];
        });
      }
    } catch (e) {
      print('Error fetching workers: $e');
    }
  }

  @override
  void dispose() {
    _nameProjectController.dispose();
    _cityController.dispose();
    _initDateController.dispose();
    _endDateController.dispose();
    _dateDeliveriesController.dispose();
    _deliveriesController.dispose();
    _observationsController.dispose();
    _localPathController.dispose();
    _mandateController.dispose();
    _externalController.dispose();
    _contractsController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un trabajador')),
      );
      return;
    }

    String url;
    http.Response response;

    try {
      final body = {
        "Name_project": _nameProjectController.text,
        "city": _cityController.text,
        "init_date": _initDateController.text.isNotEmpty
            ? _initDateController.text
            : null,
        "end_date":
            _endDateController.text.isNotEmpty ? _endDateController.text : null,
        "date_deliveries": _dateDeliveriesController.text.isNotEmpty
            ? _dateDeliveriesController.text
            : null,
        "deliveries": _deliveriesController.text.isNotEmpty
            ? _deliveriesController.text
            : null,
        "observations": _observationsController.text.isNotEmpty
            ? _observationsController.text
            : null,
        "in_charge": _selectedManager,
        "workers":
            _selectedWorkers.isNotEmpty ? _selectedWorkers.join(', ') : null,
        "mandate":
            _mandateController.text.isNotEmpty ? _mandateController.text : null,
        "external":
            _selectedContacts.isNotEmpty ? _selectedContacts.join(', ') : null,
        "local_path": _localPathController.text.isNotEmpty
            ? _localPathController.text
            : null,
        "contracts": _contractsController.text.isNotEmpty
            ? int.tryParse(_contractsController.text)
            : null,
      };

      if (widget.isEdit && widget.initialData != null) {
        // Modo edición: usar PUT
        print('Initial data: ${widget.initialData}'); // Debug
        final projectId = widget.initialData!['id_server'] ??
            widget.initialData!['ID'] ??
            widget.initialData!['id'];
        print('Project ID found: $projectId'); // Debug

        if (projectId == null) {
          print(
              'Available keys in initialData: ${widget.initialData!.keys.toList()}'); // Debug
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error: ID del proyecto no encontrado')),
          );
          return;
        }
        url =
            'https://backend-jcrgapp.onrender.com/user/updateProject/$projectId';
        print('PUT URL: $url'); // Debug
        response = await http.put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        );
      } else {
        // Modo creación: usar POST
        url = 'https://backend-jcrgapp.onrender.com/user/addProject';
        response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        );
      }

      print('Response status: ${response.statusCode}'); // Debug
      print('Response body: ${response.body}'); // Debug

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEdit
                  ? 'Proyecto actualizado correctamente'
                  : 'Proyecto creado correctamente')),
        );
        _clearForm();
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEdit
                  ? 'Error al actualizar el proyecto: ${response.statusCode}'
                  : 'Error al crear el proyecto: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameProjectController.clear();
    _cityController.clear();
    _initDateController.clear();
    _endDateController.clear();
    _dateDeliveriesController.clear();
    _deliveriesController.clear();
    _observationsController.clear();
    _localPathController.clear();
    _mandateController.clear();
    _externalController.clear();
    _contractsController.clear();
    setState(() {
      _selectedManager = null;
      _selectedWorkers = [];
      _selectedContacts = [];
    });
  }

  void _showContactsSelector() async {
    final selectedContacts = await showDialog<List<String>>(
      context: context,
      builder: (context) => ContactSelectorDialog(
        contacts: _contactsList,
        selectedContacts: List.from(_selectedContacts),
      ),
    );

    if (selectedContacts != null) {
      setState(() {
        _selectedContacts = selectedContacts;
      });
    }
  }

  void _showWorkersSelector() async {
    final selectedWorkers = await showDialog<List<String>>(
      context: context,
      builder: (context) => WorkerSelectorDialog(
        workers: _workersList,
        selectedWorkers: List.from(_selectedWorkers),
      ),
    );

    if (selectedWorkers != null) {
      setState(() {
        _selectedWorkers = selectedWorkers;
      });
    }
  }

  void _showManagerSelector() async {
    final selectedManager = await showDialog<String>(
      context: context,
      builder: (context) => ManagerSelectorDialog(
        workers: _workersList,
        selectedManager: _selectedManager,
      ),
    );

    if (selectedManager != null) {
      setState(() {
        _selectedManager = selectedManager;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.isEdit ? 'Editar Proyecto' : 'Formulario de Proyecto')),
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
                    controller: _initDateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de inicio',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
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
                        _initDateController.text =
                            picked.toLocal().toString().split(' ')[0];
                      }
                    },
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
                    controller: _dateDeliveriesController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de entregas (opcional)',
                      prefixIcon: Icon(Icons.local_shipping),
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
                        _dateDeliveriesController.text =
                            picked.toLocal().toString().split(' ')[0];
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _deliveriesController,
                    decoration: const InputDecoration(
                      labelText: 'Url entregas(opcional)',
                      prefixIcon: Icon(Icons.inventory),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _mandateController,
                          decoration: const InputDecoration(
                            labelText: 'Mandante (opcional)',
                            prefixIcon: Icon(Icons.gavel),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _contractsController,
                          decoration: const InputDecoration(
                            labelText: 'Contratos (opcional)',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Selector de contactos externos
                  GestureDetector(
                    onTap: _showContactsSelector,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.public, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Contactos externos (opcional)',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  if (_selectedContacts.isNotEmpty)
                                    Text(
                                      '${_selectedContacts.length} contacto${_selectedContacts.length > 1 ? 's' : ''} seleccionado${_selectedContacts.length > 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedContacts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6.0,
                      children: _selectedContacts.map((contact) {
                        return Chip(
                          label: Text(contact),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedContacts.remove(contact);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _observationsController,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones (opcional)',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  // Selector de encargado de la oficina
                  GestureDetector(
                    onTap: _showManagerSelector,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Encargado en la oficina',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  if (_selectedManager != null)
                                    Text(
                                      _selectedManager!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedManager != null) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(_selectedManager!),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedManager = null;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 14),
                  // Selector de trabajadores
                  GestureDetector(
                    onTap: _showWorkersSelector,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.people, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Trabajadores',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  if (_selectedWorkers.isNotEmpty)
                                    Text(
                                      '${_selectedWorkers.length} trabajador${_selectedWorkers.length > 1 ? 'es' : ''} seleccionado${_selectedWorkers.length > 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedWorkers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6.0,
                      children: _selectedWorkers.map((worker) {
                        return Chip(
                          label: Text(worker),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedWorkers.remove(worker);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _localPathController,
                    decoration: const InputDecoration(
                      labelText: 'Ruta local',
                      prefixIcon: Icon(Icons.folder_open),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: submitForm,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      widget.isEdit ? 'Actualizar' : 'Guardar',
                      style: const TextStyle(
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
