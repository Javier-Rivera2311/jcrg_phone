import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jcrg_phone/widgets/formularyTask.dart';
import '../widgets/task_detail_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Map<String, List<Map<String, dynamic>>> groupedTasks = {};
  String _searchQuery = '';
  List<Map<String, dynamic>> _allTasks = [];
  String _selectedCategory = '';
  Map<int, String> _projectNames = {}; // Nuevo mapa para nombres de proyectos

  @override
  void initState() {
    super.initState();
    fetchTasks();
    fetchProjectNames(); // Nueva llamada
  }

  Future<void> fetchTasks() async {
    final response = await http
        .get(Uri.parse('https://backend-jcrgapp.onrender.com/user/getTasks'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List tasks = data['tasks'];

      Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var task in tasks) {
        final String category = task['category'] ?? 'Sin categoría';
        if (!grouped.containsKey(category)) {
          grouped[category] = [];
        }
        grouped[category]!.add(Map<String, dynamic>.from(task));
      }
      if (mounted) {
        setState(() {
          groupedTasks = grouped;
          _allTasks = List<Map<String, dynamic>>.from(tasks);
        });
      }
    }
  }

  Future<void> fetchProjectNames() async {
    try {
      final response = await http.get(
          Uri.parse('https://backend-jcrgapp.onrender.com/user/NameProjects'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List projects = data['projects'];
          Map<int, String> projectMap = {};
          
          for (var project in projects) {
            final int id = project['id'];
            final String name = project['Name_project'] ?? 'Sin nombre';
            projectMap[id] = name;
          }
          
          if (mounted) {
            setState(() {
              _projectNames = projectMap;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching project names: $e');
    }
  }

  String _getProjectName(dynamic projectId) {
    if (projectId == null) return 'No asignado';
    
    int? id;
    if (projectId is int) {
      id = projectId;
    } else if (projectId is String) {
      id = int.tryParse(projectId);
    }
    
    if (id == null) return 'No asignado';
    return _projectNames[id] ?? 'Proyecto ID: $id';
  }

  Map<String, List<Map<String, dynamic>>> getFilteredTasks() {
    if (_searchQuery.isEmpty) return groupedTasks;

    Map<String, List<Map<String, dynamic>>> filtered = {};
    for (var entry in groupedTasks.entries) {
      final filteredTasks = entry.value.where((task) {
        final title = (task['title'] ?? '').toString().toLowerCase();
        final workers = (task['workers'] ?? '').toString().toLowerCase();
        return title.contains(_searchQuery.toLowerCase()) ||
            workers.contains(_searchQuery.toLowerCase());
      }).toList();
      if (filteredTasks.isNotEmpty) {
        filtered[entry.key] = filteredTasks;
      }
    }
    return filtered;
  }

  List<String> getAvailableCategories() {
    return groupedTasks.keys.toList()..sort();
  }

  List<Map<String, dynamic>> getFilteredTasksByCategory() {
    if (_selectedCategory.isEmpty) return [];

    List<Map<String, dynamic>> filtered = _allTasks.where((task) {
      // Filtrar por categoría
      final taskCategory = task['category'] ?? 'Sin categoría';
      if (taskCategory != _selectedCategory) return false;

      // Filtrar por búsqueda si hay query
      if (_searchQuery.isNotEmpty) {
        final title = (task['title'] ?? '').toString().toLowerCase();
        final workers = (task['workers'] ?? '').toString().toLowerCase();
        return title.contains(_searchQuery.toLowerCase()) ||
            workers.contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    return filtered;
  }

  Color _getCategoryColor(String category) {
    // Generar color basado en el hash de la categoría
    final hash = category.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.red,
      Colors.cyan,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final categories = getAvailableCategories();
    final filteredTasks = getFilteredTasksByCategory();
    final isWide = MediaQuery.of(context).size.width > 600;

    // Seleccionar primera categoría si no hay ninguna seleccionada
    if (_selectedCategory.isEmpty && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }

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
                  'Tareas',
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
          // Botones de navegación por categoría
          if (categories.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  final categoryColor = _getCategoryColor(category);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      icon: Icon(Icons.category),
                      label: Text(category),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? categoryColor : Colors.grey[300],
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black54,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
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
                  hintText: 'Buscar por título o trabajador',
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
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory.isEmpty
                              ? 'No hay categorías disponibles'
                              : 'No hay tareas en $_selectedCategory',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 12,
                      bottom: 80,
                    ),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final categoryColor =
                          _getCategoryColor(_selectedCategory);
                      final stateColor = _getTaskStateColor(task['state']);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: GestureDetector(
                          onTap: () async {
                            final changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(task: task),
                              ),
                            );
                            if (changed == true) {
                              fetchTasks();
                            }
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: categoryColor.withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color:
                                    _getTaskStateBackgroundColor(task['state']),
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
                                            color:
                                                categoryColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getTaskStateIcon(task['state']),
                                            color: stateColor,
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
                                                task['title'] ?? 'Sin título',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: stateColor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  task['state'] ?? 'Sin estado',
                                                  style: TextStyle(
                                                    color: stateColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoChip(
                                            Icons.calendar_today,
                                            'Fecha límite',
                                            _formatDate(task['date_finish']),
                                            Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildInfoChip(
                                            Icons.people,
                                            'Trabajadores',
                                            task['workers'] ?? 'No asignados',
                                            Colors.purple,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoChip(
                                            Icons.work,
                                            'Proyecto',
                                            _getProjectName(task['id_project']),
                                            Colors.teal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (task['description'] != null &&
                                        task['description']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.description,
                                                    size: 16,
                                                    color: Colors.grey),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Descripción',
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
                                              task['description'],
                                              style:
                                                  const TextStyle(fontSize: 13),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularyTask()),
          );
          if (changed == true) {
            fetchTasks();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar tarea',
      ),
    );
  }

  Color _getTaskStateColor(String? state) {
    switch (state?.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en progreso':
        return Colors.blue;
      case 'completada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskStateIcon(String? state) {
    switch (state?.toLowerCase()) {
      case 'pendiente':
        return Icons.schedule;
      case 'en progreso':
        return Icons.play_circle;
      case 'completada':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Color _getTaskStateBackgroundColor(String? state) {
    switch (state?.toLowerCase()) {
      case 'pendiente':
        return Colors.orange.withOpacity(0.1);
      case 'en progreso':
        return Colors.blue.withOpacity(0.1);
      case 'completada':
        return Colors.green.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No definida';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString.split('T')[0];
    }
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
