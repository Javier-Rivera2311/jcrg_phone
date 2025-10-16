import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProposalsPreparingWidget extends StatefulWidget {
  const ProposalsPreparingWidget({super.key});

  @override
  State<ProposalsPreparingWidget> createState() =>
      _ProposalsPreparingWidgetState();
}

class _ProposalsPreparingWidgetState extends State<ProposalsPreparingWidget> {
  late Future<List<dynamic>> proposalsFuture;
  String _searchQuery = '';

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
      Uri.parse(
          'https://backend-jcrgapp.onrender.com/user/proposals/preparing'),
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
      throw Exception(
          'Error al cargar propuestas preparando (${response.statusCode})');
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

  List<dynamic> getFilteredProposals(List<dynamic> proposals) {
    if (_searchQuery.isEmpty) return proposals;
    final query = _searchQuery.toLowerCase();

    return proposals.where((proposal) {
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
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.orange.withOpacity(0.05),
            ],
          ),
          border: Border(
            left: BorderSide(color: Colors.orange, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado visual
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.build,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Preparando',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${proposal['id'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Título de la propuesta
              Text(
                proposal['title'] ?? 'Sin título',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
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
                      Colors.orange,
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
                Colors.red,
                fullWidth: true,
              ),

              // Descripción detallada
              if ((proposal['description'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description,
                              size: 16, color: Colors.orange.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Descripción',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.orange.shade700,
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
                  Colors.orange,
                  Color.fromARGB(255, 255, 193, 126),
                  Color.fromARGB(255, 255, 234, 207),
                ],
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Propuestas Preparando',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? MediaQuery.of(context).size.width * 0.2 : 16,
              vertical: 16,
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
            child: FutureBuilder<List<dynamic>>(
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
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final allProposals = snapshot.data ?? [];
                final filteredProposals = getFilteredProposals(allProposals);

                if (filteredProposals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.build,
                            size: 64, color: Colors.orange.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No se encontraron propuestas'
                              : 'No hay propuestas preparando',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Las propuestas en estado "preparando" aparecerán aquí',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                // Ordenar por fecha de creación (más reciente primero)
                filteredProposals.sort((a, b) {
                  final aDate = DateTime.tryParse(a['created_at'] ?? '') ??
                      DateTime(1970);
                  final bDate = DateTime.tryParse(b['created_at'] ?? '') ??
                      DateTime(1970);
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
            ),
          ),
        ],
      ),
    );
  }
}
