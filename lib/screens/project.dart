import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Importa tu formulario y pantalla de detalle de proyecto
import '../widgets/formularyProject.dart';
import '../widgets/project_detail_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Map<String, List<Map<String, dynamic>>> groupedProjects = {};
  String _searchQuery = '';
  List<Map<String, dynamic>> _allProjects = [];

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final response = await http.get(
      Uri.parse('https://backend-jcrg.onrender.com/user/getProjects'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List projects = data['projects'];

      Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var project in projects) {
        final String state = project['state'] ?? 'Sin estado';
        if (!grouped.containsKey(state)) {
          grouped[state] = [];
        }
        grouped[state]!.add(Map<String, dynamic>.from(project));
      }
      if (mounted) {
        setState(() {
          groupedProjects = grouped;
          _allProjects = List<Map<String, dynamic>>.from(projects);
        });
      }
    }
  }

  Map<String, List<Map<String, dynamic>>> getFilteredProjects() {
    if (_searchQuery.isEmpty) return groupedProjects;

    Map<String, List<Map<String, dynamic>>> filtered = {};
    for (var entry in groupedProjects.entries) {
      final filteredProjects = entry.value.where((project) {
        final name = (project['name'] ?? '').toString().toLowerCase();
        final manager = (project['manager'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase()) ||
            manager.contains(_searchQuery.toLowerCase());
      }).toList();
      if (filteredProjects.isNotEmpty) {
        filtered[entry.key] = filteredProjects;
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroupedProjects = getFilteredProjects();
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
                    Color(0xFF2196F3),
                    Color(0xFF64B5F6),
                    Color(0xFFBBDEFB),
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
                  hintText: 'Buscar por nombre o encargado',
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
            child: filteredGroupedProjects.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 12,
                      bottom: 80,
                    ),
                    children: filteredGroupedProjects.entries.map((entry) {
                      final state = entry.key;
                      final projects = entry.value;

                      return ExpansionTile(
                        title: Text(
                          state,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        children: projects.map((project) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6),
                            child: GestureDetector(
                              onTap: () async {
                                final changed = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProjectDetailScreen(project: project),
                                  ),
                                );
                                if (changed == true) {
                                  fetchProjects();
                                }
                              },
                              child: Card(
                                color: project['state'] == 'completado'
                                    ? Colors.green[100]
                                    : project['state'] == 'en progreso'
                                        ? Colors.yellow[100]
                                        : project['state'] == 'pendiente'
                                            ? Colors.red[100]
                                            : Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.folder,
                                              color: Colors.blue),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(project['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                )),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text("Estado: ${project['state']}"),
                                      Text(
                                          "Fecha fin: ${project['date_finish']?.toString()?.split('T')[0] ?? ''}"),
                                      Text(
                                          "Encargado: ${project['manager'] ?? ''}"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
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
}