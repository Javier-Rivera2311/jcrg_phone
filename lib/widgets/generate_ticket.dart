import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'formularyTicket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateTicketView extends StatefulWidget {
  const GenerateTicketView({super.key});

  @override
  State<GenerateTicketView> createState() => _GenerateTicketViewState();
}

class _GenerateTicketViewState extends State<GenerateTicketView> {
  late Future<List<dynamic>> myTicketsFuture;
  String _searchQuery = '';
  int _selectedTab = 0; // 0 para abiertos, 1 para en progreso, 2 para cerrados

  @override
  void initState() {
    super.initState();
    myTicketsFuture = fetchMyTickets();
  }

  Future<List<dynamic>> fetchMyTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no disponible. Por favor inicie sesión.');
    }

    final response = await http.get(
      Uri.parse('https://backend-jcrgapp.onrender.com/user/myTickets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // <- clave para autenticación
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // DEBUG: imprime la respuesta para ver la estructura real
      print('Respuesta myTickets: $data');
      // Intenta encontrar la lista de tickets en diferentes claves posibles
      if (data is List) {
        return data;
      } else if (data['data'] is List) {
        return data['data'];
      } else if (data['tickets'] is List) {
        return data['tickets'];
      } else if (data['data'] is Map) {
        return [data['data']];
      } else if (data['ticket'] != null) {
        return [data['ticket']];
      } else {
        return [];
      }
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado (403): Token faltante o inválido.');
    } else {
      throw Exception('Error al cargar tus tickets (${response.statusCode})');
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

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'publico':
        return Colors.blue;
      case 'privado':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'publico':
        return Icons.public;
      case 'privado':
        return Icons.lock;
      default:
        return Icons.help;
    }
  }

  List<dynamic> getFilteredTickets(List<dynamic> tickets, String status) {
    // Filtrar por estado
    List<dynamic> statusFiltered = tickets.where((ticket) {
      switch (status.toLowerCase()) {
        case 'abierto':
          return (ticket['status'] ?? '').toString().toLowerCase() == 'abierto';
        case 'en progreso':
          return (ticket['status'] ?? '').toString().toLowerCase() ==
              'en progreso';
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
      final status = (ticket['status'] ?? '').toString().toLowerCase();
      final priority = (ticket['priority'] ?? '').toString().toLowerCase();
      final department =
          (ticket['department_name'] ?? '').toString().toLowerCase();
      final type = (ticket['type'] ?? '').toString().toLowerCase();

      return title.contains(query) ||
          status.contains(query) ||
          priority.contains(query) ||
          department.contains(query) ||
          type.contains(query);
    }).toList();
  }

  Widget buildTicketCard(Map<String, dynamic> ticket) {
    final statusColor = _getStatusColor(ticket['status']);
    final statusIcon = _getStatusIcon(ticket['status']);
    final priorityColor = _getPriorityColor(ticket['priority']);
    final typeColor = _getTypeColor(ticket['type']);
    final typeIcon = _getTypeIcon(ticket['type']);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
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
                ],
              ),

              const SizedBox(height: 8),

              // Estado, prioridad y tipo
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          typeIcon,
                          size: 12,
                          color: typeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket['type'] ?? 'Sin tipo',
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

              // Respuesta de soporte si existe
              if ((ticket['support_response'] ?? '').toString().isNotEmpty) ...[
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
                          Icon(Icons.support,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Respuesta de Soporte',
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
                        ticket['support_response'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value, Color color,
      {bool fullWidth = false}) {
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

  void openCreateTicketForm() async {
    const workerId = 1;
    const departmentId = 1;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FormularyTicket(workerId: workerId, departmentId: departmentId),
      ),
    );
    if (result == true) {
      setState(() {
        myTicketsFuture = fetchMyTickets();
      });
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
                'Reportar Problemas',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                      backgroundColor:
                          _selectedTab == 0 ? Colors.red : Colors.grey[300],
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
                      backgroundColor:
                          _selectedTab == 1 ? Colors.orange : Colors.grey[300],
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
                      backgroundColor:
                          _selectedTab == 2 ? Colors.green : Colors.grey[300],
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
                  hintText: 'Buscar tickets',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateTicketForm,
        backgroundColor: const Color.fromARGB(255, 255, 33, 33),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Crear Ticket',
      ),
    );
  }

  Widget _buildTicketList() {
    return FutureBuilder<List<dynamic>>(
      future: myTicketsFuture,
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
              emptyMessage = _searchQuery.isNotEmpty
                  ? 'No se encontraron tickets abiertos'
                  : 'No tienes tickets abiertos';
              emptyIcon = Icons.error_outline;
              emptyColor = Colors.red.shade300;
              break;
            case 1:
              emptyMessage = _searchQuery.isNotEmpty
                  ? 'No se encontraron tickets en progreso'
                  : 'No tienes tickets en progreso';
              emptyIcon = Icons.autorenew;
              emptyColor = Colors.orange.shade300;
              break;
            case 2:
              emptyMessage = _searchQuery.isNotEmpty
                  ? 'No se encontraron tickets cerrados'
                  : 'No tienes tickets cerrados';
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
                  'Toca el botón + para crear tu ticket',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
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
