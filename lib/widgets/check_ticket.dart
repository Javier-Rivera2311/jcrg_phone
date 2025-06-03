import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckTicketView extends StatefulWidget {
  const CheckTicketView({super.key});

  @override
  State<CheckTicketView> createState() => _CheckTicketViewState();
}

class _CheckTicketViewState extends State<CheckTicketView> {
  late Future<List<dynamic>> ticketsFuture;

  @override
  void initState() {
    super.initState();
    ticketsFuture = fetchTickets();
  }

  Future<List<dynamic>> fetchTickets() async {
    final response = await http.get(
      Uri.parse('https://backend-jcrg.onrender.com/user/tickets'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] is List ? data['data'] : [];
    } else {
      throw Exception('Error al cargar tickets');
    }
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return 'Sin fecha';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  void showTicketDetails(BuildContext context, Map<String, dynamic> ticket) {
    String selectedStatus = ticket['status'] ?? 'Abierto';
    String selectedPriority = ticket['priority'] ?? 'Baja';
    String? selectedResolutionDate = ticket['resolution_date'];

    TextEditingController resolutionDateController = TextEditingController(
      text: selectedResolutionDate != null && selectedResolutionDate != 'null'
          ? formatDate(selectedResolutionDate)
          : '',
    );

    TextEditingController responseController = TextEditingController(
      text: ticket['support_response'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(ticket['title'] ?? 'Sin título'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descripción: ${ticket['description'] ?? ''}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Estado: '),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                            value: 'Abierto', child: Text('Abierto')),
                        DropdownMenuItem(
                            value: 'Cerrado', child: Text('Cerrado')),
                        DropdownMenuItem(
                            value: 'En progreso', child: Text('En Progreso')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Prioridad: '),
                    DropdownButton<String>(
                      value: selectedPriority,
                      items: const [
                        DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                        DropdownMenuItem(value: 'Media', child: Text('Media')),
                        DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            selectedPriority = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: responseController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Respuesta de soporte',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: resolutionDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de resolución',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime initialDate = DateTime.now();
                    if (selectedResolutionDate != null &&
                        selectedResolutionDate != 'null' &&
                        selectedResolutionDate?.isNotEmpty == true) {
                      try {
                        initialDate = DateTime.parse(selectedResolutionDate!);
                      } catch (_) {}
                    }
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      // Convertir a formato timestamp (ISO8601)
                      final pickedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                      );
                      final pickedDateString = pickedDate.toIso8601String();
                      setStateDialog(() {
                        selectedResolutionDate = pickedDateString;
                        resolutionDateController.text =
                            formatDate(pickedDateString);
                      });
                    }
                  },
                ),
                Text(
                    'Fecha de creación: ${formatDate(ticket['creation_date'])}'),
                Text('Trabajador: ${ticket['worker_name'] ?? ''}'),
                Text('Departamento: ${ticket['department_name'] ?? ''}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await updateTicketStatusPriority(
                  ticket,
                  selectedStatus,
                  selectedPriority,
                  selectedResolutionDate,
                  responseController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateTicketStatusPriority(
    Map<String, dynamic> ticket,
    String status,
    String priority,
    String? resolutionDate,
    String supportResponse,
  ) async {
    final response = await http.put(
      Uri.parse(
          'https://backend-jcrg.onrender.com/user/updateTicket/${ticket['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': ticket['title'],
        'status': status,
        'priority': priority,
        'resolution_date': resolutionDate,
        'support_response': supportResponse,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        ticketsFuture = fetchTickets();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el ticket')),
      );
    }
  }

  Widget buildTicketTile(Map<String, dynamic> ticket) {
    return ListTile(
      leading: Icon(
        ticket['status'] == 'Cerrado'
            ? Icons.check_circle
            : ticket['status'] == 'En progreso'
                ? Icons.autorenew
                : Icons.error_outline,
        color: ticket['status'] == 'Cerrado'
            ? Colors.green
            : ticket['status'] == 'En progreso'
                ? Colors.orange
                : Colors.red,
      ),
      title: Text(ticket['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prioridad: ${ticket['priority'] ?? ''}'),
          Text('Estado: ${ticket['status'] ?? ''}'),
          Text('Departamento: ${ticket['department_name'] ?? ''}'),
          Text('Trabajador: ${ticket['worker_name'] ?? ''}'),
          Text('Creado: ${formatDate(ticket['creation_date'])}'),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => showTicketDetails(context, ticket),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
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
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0), // Bordes redondeados en la esquina inferior izquierda
              bottomRight: Radius.circular(20.0), // Bordes redondeados en la esquina inferior derecha
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Verificar Ticket'),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('No hay tickets disponibles.'));
          }
          // Ordenar de más reciente a más vieja por 'creation_date'
          tickets.sort((a, b) {
            final aDate =
                DateTime.tryParse(a['creation_date'] ?? '') ?? DateTime(1970);
            final bDate =
                DateTime.tryParse(b['creation_date'] ?? '') ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
          return ListView.separated(
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return buildTicketTile(ticket);
            },
          );
        },
      ),
    );
  }
}
