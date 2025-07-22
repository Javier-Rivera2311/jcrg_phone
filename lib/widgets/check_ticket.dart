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
  String _searchQuery = '';
  int _selectedTab = 0; // 0 para abiertos, 1 para en progreso, 2 para cerrados

  @override
  void initState() {
    super.initState();
    ticketsFuture = fetchTickets();
  }

  Future<List<dynamic>> fetchTickets() async {
    final response = await http.get(
      Uri.parse('https://backend-jcrgapp.onrender.com/user/tickets'),
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
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'cerrado':
        return Colors.green;
      case 'en progreso':
        return Colors.orange;
      case 'abierto':
      case 'pendiente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'cerrado':
        return Icons.check_circle;
      case 'en progreso':
        return Icons.autorenew;
      case 'abierto':
      case 'pendiente':
        return Icons.error_outline;
      default:
        return Icons.help;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
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

  List<dynamic> getFilteredTickets(List<dynamic> tickets, String status) {
    // Filtrar por estado
    List<dynamic> statusFiltered = tickets.where((ticket) {
      switch (status.toLowerCase()) {
        case 'abierto':
          return (ticket['status'] ?? '').toString().toLowerCase() == 'abierto';
        case 'en progreso':
          return (ticket['status'] ?? '').toString().toLowerCase() == 'en progreso';
        case 'cerrado':
          return (ticket['status'] ?? '').toString().toLowerCase() == 'cerrado';
        default:
          return true;
      }
    }).toList();

    // Filtrar por búsqueda si hay query
    if (_searchQuery.isEmpty) return statusFiltered;
    final query = _searchQuery.toLowerCase();

    return statusFiltered.where((ticket) {
      final title = (ticket['title'] ?? '').toString().toLowerCase();
      final priority = (ticket['priority'] ?? '').toString().toLowerCase();
      final department = (ticket['department_name'] ?? '').toString().toLowerCase();
      final worker = (ticket['worker_name'] ?? '').toString().toLowerCase();

      return title.contains(query) ||
          priority.contains(query) ||
          department.contains(query) ||
          worker.contains(query);
    }).toList();
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
          'https://backend-jcrgapp.onrender.com/user/updateTicket/${ticket['id']}'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket actualizado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el ticket')),
      );
    }
  }

  Widget buildTicketCard(Map<String, dynamic> ticket) {
    final statusColor = _getStatusColor(ticket['status']);
    final statusIcon = _getStatusIcon(ticket['status']);
    final priorityColor = _getPriorityColor(ticket['priority']);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => showTicketDetails(context, ticket),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: statusColor.withOpacity(0.02),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con número de ticket y título
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${ticket['id'] ?? 'N/A'} - ${ticket['title'] ?? 'Sin título'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
                
                const SizedBox(height: 8),

                // Estado y prioridad (movido aquí después del título)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ticket['status'] ?? 'Sin estado',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ticket['priority'] ?? 'Sin prioridad',
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Información del ticket
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        Icons.business,
                        'Departamento',
                        ticket['department_name'] ?? 'No asignado',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.person,
                        'Trabajador',
                        ticket['worker_name'] ?? 'No asignado',
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                _buildInfoChip(
                  Icons.calendar_today,
                  'Creado',
                  formatDate(ticket['creation_date']),
                  Colors.orange,
                  fullWidth: true,
                ),

                // Descripción si existe
                if ((ticket['description'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Descripción',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket['description'],
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],

                // Respuesta de soporte si existe
                if ((ticket['support_response'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.support, size: 16, color: Colors.blue.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Respuesta de Soporte',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket['support_response'],
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13),
            maxLines: fullWidth ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
                'Verificar Tickets',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Botones de navegación por estado
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    icon: const Icon(Icons.error_outline),
                    label: const Text('Abiertos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 0
                          ? Colors.red
                          : Colors.grey[300],
                      foregroundColor:
                          _selectedTab == 0 ? Colors.white : Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    icon: const Icon(Icons.autorenew),
                    label: const Text('En Progreso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 1
                          ? Colors.orange
                          : Colors.grey[300],
                      foregroundColor:
                          _selectedTab == 1 ? Colors.white : Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 2;
                      });
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Cerrados'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 2
                          ? Colors.green
                          : Colors.grey[300],
                      foregroundColor:
                          _selectedTab == 2 ? Colors.white : Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? MediaQuery.of(context).size.width * 0.2 : 16,
              vertical: 12,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar tickets por título, estado, trabajador...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // Lista de tickets
          Expanded(
            child: _buildTicketList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList() {
    return FutureBuilder<List<dynamic>>(
      future: ticketsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar tickets',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final allTickets = snapshot.data ?? [];
        
        // Obtener tickets filtrados según la pestaña seleccionada
        String currentStatus = '';
        switch (_selectedTab) {
          case 0:
            currentStatus = 'abierto';
            break;
          case 1:
            currentStatus = 'en progreso';
            break;
          case 2:
            currentStatus = 'cerrado';
            break;
        }

        final filteredTickets = getFilteredTickets(allTickets, currentStatus);

        if (filteredTickets.isEmpty) {
          String emptyMessage = '';
          IconData emptyIcon = Icons.assignment;
          Color emptyColor = Colors.grey.shade400;
          
          switch (_selectedTab) {
            case 0:
              emptyMessage = _searchQuery.isNotEmpty ? 'No se encontraron tickets abiertos' : 'No hay tickets abiertos';
              emptyIcon = Icons.error_outline;
              emptyColor = Colors.red.shade300;
              break;
            case 1:
              emptyMessage = _searchQuery.isNotEmpty ? 'No se encontraron tickets en progreso' : 'No hay tickets en progreso';
              emptyIcon = Icons.autorenew;
              emptyColor = Colors.orange.shade300;
              break;
            case 2:
              emptyMessage = _searchQuery.isNotEmpty ? 'No se encontraron tickets cerrados' : 'No hay tickets cerrados';
              emptyIcon = Icons.check_circle;
              emptyColor = Colors.green.shade300;
              break;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(emptyIcon, size: 64, color: emptyColor),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los tickets aparecerán aquí cuando estén disponibles',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        // Ordenar por fecha de creación (más reciente primero)
        filteredTickets.sort((a, b) {
          final aDate = DateTime.tryParse(a['creation_date'] ?? '') ?? DateTime(1970);
          final bDate = DateTime.tryParse(b['creation_date'] ?? '') ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: filteredTickets.length,
          itemBuilder: (context, index) {
            final ticket = filteredTickets[index];
            return buildTicketCard(ticket);
          },
        );
      },
    );
  }
}
