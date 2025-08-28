import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/task_detail_screen.dart';

class ProjectTasksScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectTasksScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectTasksScreen> createState() => _ProjectTasksScreenState();
}

class _ProjectTasksScreenState extends State<ProjectTasksScreen> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProjectTasks();
  }

  Future<void> fetchProjectTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://backend-jcrgapp.onrender.com/user/Project/${widget.projectId}/tasks'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['tasks'] != null) {
          setState(() {
            _tasks = List<Map<String, dynamic>>.from(data['tasks']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _tasks = [];
            _isLoading = false;
            _errorMessage = 'No se encontraron tareas para este proyecto';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar las tareas: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error de conexión: $e';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas - ${widget.projectName}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchProjectTasks,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando tareas...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchProjectTasks,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay tareas para este proyecto',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
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
                                fetchProjectTasks();
                              }
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.green.withOpacity(0.6),
                                  width: 2,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: _getTaskStateBackgroundColor(
                                      task['state']),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.1),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: stateColor
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    task['state'] ??
                                                        'Sin estado',
                                                    style: TextStyle(
                                                      color: stateColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                              Icons.category,
                                              'Categoría',
                                              task['category'] ??
                                                  'Sin categoría',
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
                                            color:
                                                Colors.white.withOpacity(0.7),
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                task['description'],
                                                style: const TextStyle(
                                                    fontSize: 13),
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
    );
  }
}
