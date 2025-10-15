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
  String type = 'publico'; // Nuevo campo type

  bool isLoading = false;

  Future<void> createTicket(
      String title, String description, String priority, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('https://backend-jcrgapp.onrender.com/user/createTicket'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'priority': priority,
        'type': type, // Nuevo campo type
        'worker_id': widget.workerId,
        'department_id': widget.departmentId,
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return Icons.priority_high;
      case 'media':
        return Icons.remove;
      case 'baja':
        return Icons.low_priority;
      default:
        return Icons.help;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'publico':
        return Colors.blue;
      case 'privado':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'publico':
        return Icons.public;
      case 'privado':
        return Icons.lock;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isWide ? 70 : 80),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 33, 33),
                  Color.fromARGB(255, 255, 100, 100),
                  Color.fromARGB(255, 255, 180, 180),
                ],
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Crear Ticket de Soporte',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 600 : double.infinity,
                ),
                child: Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(
                      horizontal: isWide ? 40 : 16, vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.red.shade50.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isWide ? 40 : 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header con icono y título
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.support_agent,
                                size: 48,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Reportar Problema',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Describe tu problema para que nuestro equipo pueda ayudarte',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Campo Título
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: 'Título del problema',
                                  hintText: 'Ej: No puedo acceder al sistema',
                                  prefixIcon: Icon(Icons.title,
                                      color: Colors.red.shade600),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                        color: Colors.red.shade400, width: 2),
                                  ),
                                  labelStyle:
                                      TextStyle(color: Colors.grey.shade700),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Por favor ingrese un título'
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo Descripción
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Descripción detallada',
                                  hintText:
                                      'Describe el problema con el mayor detalle posible...',
                                  prefixIcon: Icon(Icons.description,
                                      color: Colors.red.shade600),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                        color: Colors.red.shade400, width: 2),
                                  ),
                                  labelStyle:
                                      TextStyle(color: Colors.grey.shade700),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                                minLines: 3,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Por favor describe el problema'
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo Tipo con diseño mejorado
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: DropdownButtonFormField<String>(
                                  value: type,
                                  decoration: InputDecoration(
                                    labelText: 'Tipo de ticket',
                                    prefixIcon: Icon(
                                      _getTypeIcon(type),
                                      color: _getTypeColor(type),
                                    ),
                                    border: InputBorder.none,
                                    labelStyle:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'publico',
                                      child: Row(
                                        children: [
                                          Icon(Icons.public,
                                              color: Colors.blue, size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                              'Público - Visible para todos'),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'privado',
                                      child: Row(
                                        children: [
                                          Icon(Icons.lock,
                                              color: Colors.orange, size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                              'Privado - Solo para administradores'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null)
                                      setState(() => type = value);
                                  },
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo Prioridad con diseño mejorado
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: DropdownButtonFormField<String>(
                                  value: priority,
                                  decoration: InputDecoration(
                                    labelText: 'Nivel de prioridad',
                                    prefixIcon: Icon(
                                      _getPriorityIcon(priority),
                                      color: _getPriorityColor(priority),
                                    ),
                                    border: InputBorder.none,
                                    labelStyle:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'Baja',
                                      child: Row(
                                        children: [
                                          Icon(Icons.low_priority,
                                              color: Colors.green, size: 20),
                                          const SizedBox(width: 8),
                                          const Text('Baja - No es urgente'),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Media',
                                      child: Row(
                                        children: [
                                          Icon(Icons.remove,
                                              color: Colors.orange, size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                              'Media - Moderadamente urgente'),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Alta',
                                      child: Row(
                                        children: [
                                          Icon(Icons.priority_high,
                                              color: Colors.red, size: 20),
                                          const SizedBox(width: 8),
                                          const Text('Alta - Muy urgente'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null)
                                      setState(() => priority = value);
                                  },
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Información adicional
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info, color: Colors.blue.shade600),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Nuestro equipo de soporte revisará tu ticket y te contactará pronto.',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Botón de envío
                            isLoading
                                ? Container(
                                    height: 56,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.red,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.shade600,
                                          Colors.red.shade400,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => isLoading = true);
                                          await createTicket(
                                            titleController.text,
                                            descriptionController.text,
                                            priority,
                                            type,
                                          );
                                          if (mounted) {
                                            setState(() => isLoading = false);
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.send,
                                          color: Colors.white),
                                      label: const Text(
                                        'Enviar Ticket de Soporte',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
