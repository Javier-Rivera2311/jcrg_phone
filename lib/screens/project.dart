import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Importa tu formulario y pantalla de detalle de proyecto
import '../widgets/formularyProject.dart';
import '../widgets/project_detail_screen.dart';
import '../widgets/openProject.dart'; // ← NUEVA IMPORTACIÓN

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Map<String, List<Map<String, dynamic>>> groupedProjects = {};
  String _searchQuery = '';
  int _selectedTab = 0; // 0 para en curso, 1 para finalizados, 2 para atrasados

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final response = await http.get(
      Uri.parse('https://backend-jcrgapp.onrender.com/user/Project'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List projects = data['proyectos'];

      print('Raw projects data: $projects'); // Debug - para ver la estructura

      Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var project in projects) {
        print('Project: $project'); // Debug - para ver cada proyecto individual
        final String city = project['city'] ?? 'Sin ciudad';
        if (!grouped.containsKey(city)) {
          grouped[city] = [];
        }
        grouped[city]!.add(Map<String, dynamic>.from(project));
      }
      if (mounted) {
        setState(() {
          groupedProjects = grouped;
        });
      }
    }
  }

  Map<String, List<Map<String, dynamic>>> getFilteredProjects(int tabIndex) {
    Map<String, List<Map<String, dynamic>>> filtered = {};

    for (var entry in groupedProjects.entries) {
      final city = entry.key.toLowerCase();
      final filteredProjects = entry.value.where((project) {
        // Filtrar por estado del proyecto según la pestaña
        final projectState = project['state']?.toString() ?? 'Sin empezar';
        bool matchesTab = false;

        switch (tabIndex) {
          case 0: // En curso (Sin empezar + Comenzado)
            matchesTab = projectState == 'Sin empezar' || projectState == 'Comenzado';
            break;
          case 1: // Finalizados
            matchesTab = projectState == 'Finalizado';
            break;
          case 2: // Atrasados
            matchesTab = projectState == 'Atrasado';
            break;
        }

        if (!matchesTab) return false;

        // Filtrar por búsqueda si hay query
        if (_searchQuery.isNotEmpty) {
          final name = (project['Name_project'] ?? '').toString().toLowerCase();
          final inCharge = (project['in_charge'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery.toLowerCase()) ||
              inCharge.contains(_searchQuery.toLowerCase()) ||
              city.contains(_searchQuery.toLowerCase());
        }
        return true;
      }).toList();

      if (filteredProjects.isNotEmpty) {
        filtered[entry.key] = filteredProjects;
      }
    }
    return filtered;
  }

  Color _getProjectStatusColor(Map<String, dynamic> project) {
    final state = project['state']?.toString() ?? 'Sin empezar';

    switch (state) {
      case 'Sin empezar':
        return Colors.grey;
      case 'Comenzado':
        return Colors.blue;
      case 'Finalizado':
        return Colors.green;
      case 'Atrasado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getProjectStatusText(Map<String, dynamic> project) {
    return project['state']?.toString() ?? 'Sin empezar';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No definida';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isWide ? 60 : 80),
        child: SafeArea(
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
                    Color.fromARGB(255, 116, 169, 255),
                    Color(0xFF82B1FF),
                    Color.fromARGB(255, 193, 215, 251),
                  ],
                ),
              ),
              child: AppBar(
                title: const Text(
                  'Proyectos',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Botones de navegación personalizados para 3 pestañas
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
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('En Curso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 0
                          ? const Color.fromARGB(255, 116, 169, 255)
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
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Finalizados'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedTab == 1 ? Colors.green : Colors.grey[300],
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
                    icon: const Icon(Icons.warning),
                    label: const Text('Atrasados'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedTab == 2 ? Colors.red : Colors.grey[300],
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
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, encargado o ciudad',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: _buildProjectList(_selectedTab),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularyProject()),
          );
          if (changed == true) {
            fetchProjects();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar proyecto',
      ),
    );
  }

  Widget _buildProjectList(int tabIndex) {
    final filteredGroupedProjects = getFilteredProjects(tabIndex);

    if (filteredGroupedProjects.isEmpty) {
      String emptyMessage;
      IconData emptyIcon;

      switch (tabIndex) {
        case 0:
          emptyMessage = 'No hay proyectos en curso';
          emptyIcon = Icons.play_arrow;
          break;
        case 1:
          emptyMessage = 'No hay proyectos finalizados';
          emptyIcon = Icons.check_circle_outline;
          break;
        case 2:
          emptyMessage = 'No hay proyectos atrasados';
          emptyIcon = Icons.warning_amber_outlined;
          break;
        default:
          emptyMessage = 'No hay proyectos';
          emptyIcon = Icons.folder_open;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: 80,
      ),
      children: filteredGroupedProjects.entries.map((entry) {
        final city = entry.key;
        final projects = entry.value;

        Color sectionColor;
        String sectionLabel;

        switch (tabIndex) {
          case 0:
            sectionColor = Colors.blueAccent;
            sectionLabel = 'en curso';
            break;
          case 1:
            sectionColor = Colors.green;
            sectionLabel = 'finalizados';
            break;
          case 2:
            sectionColor = Colors.red;
            sectionLabel = 'atrasados';
            break;
          default:
            sectionColor = Colors.blueAccent;
            sectionLabel = 'activos';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sectionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_city,
                color: sectionColor,
              ),
            ),
            title: Text(
              city,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: sectionColor,
              ),
            ),
            subtitle: Text(
              '${projects.length} proyecto${projects.length != 1 ? 's' : ''} $sectionLabel',
              style: const TextStyle(color: Colors.grey),
            ),
            children: projects.map((project) {
              final statusColor = _getProjectStatusColor(project);
              final statusText = _getProjectStatusText(project);

              return Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: GestureDetector(
                  onTap: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(project: project),
                      ),
                    );
                    if (changed == true) {
                      fetchProjects();
                    }
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: sectionColor.withOpacity(0.02),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    tabIndex == 1 ? Icons.check_circle :
                                    tabIndex == 2 ? Icons.warning : Icons.folder,
                                    color: statusColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project['Name_project'] ?? 'Sin nombre',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (project['local_path'] != null || project['path'] != null)
                                  OpenProject(
                                    windowsPath: project['local_path'] ?? project['path'],
                                    tooltip: 'Abrir carpeta del proyecto',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoChip(
                                    Icons.calendar_today,
                                    'Fecha inicio',
                                    _formatDate(project['init_date']),
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildInfoChip(
                                    Icons.calendar_month,
                                    'Fecha fin',
                                    _formatDate(project['end_date']),
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoChip(
                                    Icons.person,
                                    'Encargado',
                                    project['in_charge'] ?? 'No asignado',
                                    Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildInfoChip(
                                    Icons.group,
                                    'Trabajadores',
                                    project['workers']?.toString() ?? '0',
                                    Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                            if (project['date_deliveries'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoChip(
                                      Icons.local_shipping,
                                      'Fecha entrega',
                                      _formatDate(project['date_deliveries']),
                                      Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInfoChip(
                                      Icons.inventory,
                                      'URL Entregas',
                                      project['deliveries']?.toString() ?? 'No definida',
                                      Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (project['mandante'] != null ||
                                project['external'] != null ||
                                project['contracts'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (project['mandante'] != null)
                                    Expanded(
                                      child: _buildInfoChip(
                                        Icons.gavel,
                                        'Mandante',
                                        project['mandante'].toString(),
                                        Colors.brown,
                                      ),
                                    ),
                                  if (project['mandante'] != null &&
                                      (project['external'] != null ||
                                          project['contracts'] != null))
                                    const SizedBox(width: 8),
                                  if (project['external'] != null)
                                    Expanded(
                                      child: _buildInfoChip(
                                        Icons.public,
                                        'Externo',
                                        project['external'].toString(),
                                        Colors.cyan,
                                      ),
                                    ),
                                  if (project['external'] != null &&
                                      project['contracts'] != null)
                                    const SizedBox(width: 8),
                                  if (project['contracts'] != null)
                                    Expanded(
                                      child: _buildInfoChip(
                                        Icons.description,
                                        'Contratos',
                                        project['contracts'].toString(),
                                        Colors.deepOrange,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            if (project['observations'] != null) ...[
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
                                    const Row(
                                      children: [
                                        Icon(Icons.note,
                                            size: 16, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          'Observaciones',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      project['observations'],
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
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoChip(
      IconData icon, String label, String value, Color color) {
    return Container(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
