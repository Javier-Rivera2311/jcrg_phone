import 'package:flutter/material.dart';

class FormularyTask extends StatefulWidget {
  const FormularyTask({super.key});

  @override
  State<FormularyTask> createState() => _FormularyTaskState();
}

class _FormularyTaskState extends State<FormularyTask> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateFinishController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedState;
  List<String> _selectedWorkers = [];
  String? _selectedCategoryId;

  final List<String> departments = ['1', '2', '3', '4', '5'];
  final List<String> states = ['pendiente', 'en progreso', 'completada'];
  final List<String> workers = [
    'Trabajador 1', 'Trabajador 2', 'Trabajador 3', 'Trabajador 4', 'Trabajador 5'
  ];
  final List<String> categories = [
    '1', '2', '3', '4', '5'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el ID' : null,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el título' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(labelText: 'Departamento'),
                items: departments.map((dep) => DropdownMenuItem(value: dep, child: Text('Departamento $dep'))).toList(),
                onChanged: (value) => setState(() => _selectedDepartment = value),
                validator: (value) => value == null ? 'Seleccione un departamento' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
                onChanged: (value) => setState(() => _selectedState = value),
                validator: (value) => value == null ? 'Seleccione un estado' : null,
              ),
              TextFormField(
                controller: _dateFinishController,
                decoration: const InputDecoration(labelText: 'Fecha de finalización'),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _dateFinishController.text = picked.toLocal().toString().split(' ')[0];
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Seleccione la fecha' : null,
              ),
              GestureDetector(
                onTap: () async {
                  final List<String> result = await showDialog(
                    context: context,
                    builder: (context) {
                      List<String> tempSelected = List.from(_selectedWorkers);
                      return AlertDialog(
                        title: const Text('Selecciona trabajadores'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView(
                            shrinkWrap: true,
                            children: workers.map((worker) {
                              return CheckboxListTile(
                                value: tempSelected.contains(worker),
                                title: Text(worker),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      tempSelected.add(worker);
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
                            onPressed: () => Navigator.pop(context, _selectedWorkers),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, tempSelected),
                            child: const Text('Aceptar'),
                          ),
                        ],
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
                    decoration: InputDecoration(
                      labelText: 'Trabajadores',
                      hintText: 'Selecciona uno o más',
                    ),
                    controller: TextEditingController(
                      text: _selectedWorkers.isEmpty ? '' : _selectedWorkers.join(', '),
                    ),
                    validator: (value) => _selectedWorkers.isEmpty ? 'Seleccione al menos un trabajador' : null,
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Categoría (ID)'),
                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text('Categoría $cat'))).toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
                validator: (value) => value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Procesar datos del formulario
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Formulario válido')));
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
