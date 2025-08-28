import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Map<int, String> _projectNames = {};

  @override
  void initState() {
    super.initState();
    fetchProjectNames();
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No definida';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString.split('T')[0];
    }
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
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

  IconData _getStateIcon(String state) {
    switch (state.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    // Función para refrescar la vista anterior al volver
    void refreshParent() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    }

    final stateColor = _getStateColor(widget.task['state']);
    final stateIcon = _getStateIcon(widget.task['state']);
    final isCompleted = widget.task['state'].toLowerCase() == 'completada';
    final taskDate = widget.task['date_finish'] != null
        ? DateTime.parse(widget.task['date_finish'])
        : null;
    final isOverdue =
        taskDate != null && taskDate.isBefore(DateTime.now()) && !isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task['title'] ?? 'Tarea'),
        backgroundColor: stateColor,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 24 : 16),
            child: Column(
              children: [
                // Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          stateColor.withOpacity(0.1),
                          stateColor.withOpacity(0.2)
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          stateIcon,
                          size: 48,
                          color: stateColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.task['title'] ?? 'Sin título',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: stateColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                stateIcon,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.task['state'] ?? 'Sin estado',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Vencida',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Información General
                _buildInfoSection(
                  'Información General',
                  Icons.info_outline,
                  Colors.blue,
                  [
                    _buildInfoRow(Icons.category, 'Categoría',
                        widget.task['category'] ?? 'Sin categoría'),
                    _buildInfoRow(Icons.work, 'Proyecto',
                        _getProjectName(widget.task['id_project'])),
                    _buildInfoRow(Icons.people, 'Trabajadores',
                        widget.task['workers'] ?? 'No asignados'),
                    _buildInfoRow(Icons.calendar_today, 'Fecha de finalización',
                        _formatDate(widget.task['date_finish'])),
                  ],
                ),

                const SizedBox(height: 16),

                // Descripción
                if (widget.task['description'] != null &&
                    widget.task['description'].toString().isNotEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description,
                                  color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Descripción de la Tarea',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              widget.task['description'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Información del Sistema
                if (widget.task['created_at'] != null || widget.task['updated_at'] != null)
                  _buildInfoSection(
                    'Información del Sistema',
                    Icons.settings,
                    Colors.grey,
                    [
                      if (widget.task['created_at'] != null)
                        _buildInfoRow(Icons.date_range, 'Creada',
                            _formatDate(widget.task['created_at'])),
                      if (widget.task['updated_at'] != null)
                        _buildInfoRow(Icons.update, 'Actualizada',
                            _formatDate(widget.task['updated_at'])),
                    ],
                  ),

                const SizedBox(height: 24),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String? nuevoEstado = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              String? selected = widget.task['state'];
                              return AlertDialog(
                                title: const Text("Cambiar estado"),
                                content: StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RadioListTile<String>(
                                          title: const Text('Pendiente'),
                                          value: 'pendiente',
                                          groupValue: selected,
                                          onChanged: (value) {
                                            setStateDialog(
                                                () => selected = value);
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: const Text('En progreso'),
                                          value: 'en progreso',
                                          groupValue: selected,
                                          onChanged: (value) {
                                            setStateDialog(
                                                () => selected = value);
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: const Text('Completada'),
                                          value: 'completada',
                                          groupValue: selected,
                                          onChanged: (value) {
                                            setStateDialog(
                                                () => selected = value);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, null),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, selected),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: stateColor),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (nuevoEstado != null &&
                              nuevoEstado != widget.task['state']) {
                            final response = await http.put(
                              Uri.parse(
                                  'https://backend-jcrgapp.onrender.com/user/Task/state'),
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode(
                                  {"id": widget.task['ID'], "state": nuevoEstado}),
                            );

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Estado actualizado correctamente')),
                              );
                              refreshParent();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Error al actualizar el estado')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text("Cambiar estado"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: stateColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: const Text(
                                  '¿Estás seguro de que deseas eliminar esta tarea?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            final response = await http.delete(
                              Uri.parse(
                                  'https://backend-jcrgapp.onrender.com/user/Task/${widget.task['ID']}'),
                            );

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Tarea eliminada correctamente')),
                              );
                              refreshParent();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Error al eliminar la tarea')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text("Eliminar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(
      String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
