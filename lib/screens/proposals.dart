import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({super.key});

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  late Future<List<dynamic>> proposalsFuture;
  String _searchQuery = '';
  int _selectedTab =
      0; // 0 para participando, 1 para preparando, 2 para cotizaciones enviadas

  @override
  void initState() {
    super.initState();
    proposalsFuture = fetchProposals();
  }

  Future<List<dynamic>> fetchProposals() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no disponible. Por favor inicie sesión.');
    }

    final response = await http.get(
      Uri.parse('https://backend-jcrgapp.onrender.com/user/proposals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] is List ? data['data'] : [];
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado (403): Token faltante o inválido.');
    } else {
      throw Exception('Error al cargar propuestas (${response.statusCode})');
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
      case 'participando':
        return Colors.blue;
      case 'preparando':
        return Colors.orange;
      case 'cotizaciones enviadas':
      case 'enviadas':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'participando':
        return Icons.groups;
      case 'preparando':
        return Icons.build;
      case 'cotizaciones enviadas':
      case 'enviadas':
        return Icons.send;
      default:
        return Icons.help;
    }
  }

  List<dynamic> getFilteredProposals(List<dynamic> proposals, String status) {
    // Filtrar por estado
    List<dynamic> statusFiltered = proposals.where((proposal) {
      switch (status.toLowerCase()) {
        case 'participando':
          return (proposal['status'] ?? '').toString().toLowerCase() ==
              'participando';
        case 'preparando':
          return (proposal['status'] ?? '').toString().toLowerCase() ==
              'preparando';
        case 'cotizaciones enviadas':
          return (proposal['status'] ?? '').toString().toLowerCase() ==
                  'cotizaciones enviadas' ||
              (proposal['status'] ?? '').toString().toLowerCase() == 'enviadas';
        default:
          return true;
      }
    }).toList();

    // Filtrar por búsqueda si hay query
    if (_searchQuery.isEmpty) return statusFiltered;
    final query = _searchQuery.toLowerCase();

    return statusFiltered.where((proposal) {
      final title = (proposal['title'] ?? '').toString().toLowerCase();
      final client = (proposal['client_name'] ?? '').toString().toLowerCase();
      final description =
          (proposal['description'] ?? '').toString().toLowerCase();
      final id = (proposal['id'] ?? '').toString();

      return title.contains(query) ||
          client.contains(query) ||
          description.contains(query) ||
          id.contains(query);
    }).toList();
  }

  Widget buildProposalCard(Map<String, dynamic> proposal) {
    final statusColor = _getStatusColor(proposal['status']);
    final statusIcon = _getStatusIcon(proposal['status']);

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
              // Header con número de propuesta y título
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${proposal['id'] ?? 'N/A'} - ${proposal['title'] ?? 'Sin título'}',
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

              // Estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  proposal['status'] ?? 'Sin estado',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Información de la propuesta
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.person,
                      'Cliente',
                      proposal['client_name'] ?? 'No asignado',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.attach_money,
                      'Valor',
                      '\$${proposal['value'] ?? '0'}',
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _buildInfoChip(
                Icons.calendar_today,
                'Fecha límite',
                formatDate(proposal['deadline']),
                Colors.orange,
                fullWidth: true,
              ),

              // Descripción detallada
              if ((proposal['description'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description,
                              size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Descripción',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        proposal['description'],
                        style: const TextStyle(fontSize: 14, height: 1.4),
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
                  Color.fromARGB(255, 33, 150, 255),
                  Color.fromARGB(255, 100, 180, 255),
                  Color.fromARGB(255, 180, 220, 255),
                ],
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Propuestas',
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
            child: Column(
              children: [
                // Primera fila de botones
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedTab = 0;
                          });
                        },
                        icon: const Icon(Icons.groups),
                        label: const Text('Participando'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTab == 0
                              ? Colors.blue
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
                        icon: const Icon(Icons.build),
                        label: const Text('Preparando'),
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
                  ],
                ),
                const SizedBox(height: 8),
                // Segunda fila con botón centrado
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 2;
                      });
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Cotizaciones Enviadas'),
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
                  hintText: 'Buscar propuestas por título, cliente...',
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

          // Lista de propuestas
          Expanded(
            child: _buildProposalsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalsList() {
    return FutureBuilder<List<dynamic>>(
      future: proposalsFuture,
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
                  'Error al cargar propuestas',
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

        final allProposals = snapshot.data ?? [];

        // Obtener propuestas filtradas según la pestaña seleccionada
        String currentStatus = '';
        switch (_selectedTab) {
          case 0:
            currentStatus = 'participando';
            break;
          case 1:
            currentStatus = 'preparando';
            break;
          case 2:
            currentStatus = 'cotizaciones enviadas';
            break;
        }

        final filteredProposals =
            getFilteredProposals(allProposals, currentStatus);

        if (filteredProposals.isEmpty) {
          String emptyMessage = '';
          IconData emptyIcon = Icons.assignment;
          Color emptyColor = Colors.grey.shade400;

          switch (_selectedTab) {
            case 0:
              emptyMessage = _searchQuery.isNotEmpty
                  ? 'No se encontraron propuestas participando'
                  : 'No hay propuestas en participación';
              emptyIcon = Icons.groups;
              emptyColor = Colors.blue.shade300;
              break;
            case 1:
              emptyMessage = _searchQuery.isNotEmpty
                  ? 'No se encontraron propuestas preparando'
                  : 'No hay propuestas en preparación';
              emptyIcon = Icons.build;
              emptyColor = Colors.orange.shade300;
              break;
            case 2:
              emptyMessage = _searchQuery.isNotEmpty
                  ? 'No se encontraron cotizaciones enviadas'
                  : 'No hay cotizaciones enviadas';
              emptyIcon = Icons.send;
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
                  'Las propuestas aparecerán aquí cuando estén disponibles',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        // Ordenar por fecha de creación (más reciente primero)
        filteredProposals.sort((a, b) {
          final aDate =
              DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
          final bDate =
              DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: filteredProposals.length,
          itemBuilder: (context, index) {
            final proposal = filteredProposals[index];
            return buildProposalCard(proposal);
          },
        );
      },
    );
  }
}
