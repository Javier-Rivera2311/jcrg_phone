import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskDetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({super.key, required this.task});

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

    final stateColor = _getStateColor(task['state']);
    final stateIcon = _getStateIcon(task['state']);
    final isCompleted = task['state'].toLowerCase() == 'completada';
    final taskDate = task['date_finish'] != null
        ? DateTime.parse(task['date_finish'])
        : null;
    final isOverdue =
        taskDate != null && taskDate.isBefore(DateTime.now()) && !isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(task['title'] ?? 'Tarea'),
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
                          task['title'] ?? 'Sin título',
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
                                task['state'] ?? 'Sin estado',
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
                        task['category'] ?? 'Sin categoría'),
                    _buildInfoRow(Icons.work, 'ID Proyecto',
                        task['id_project']?.toString() ?? 'No asignado'),
                    _buildInfoRow(Icons.people, 'Trabajadores',
                        task['workers'] ?? 'No asignados'),
                    _buildInfoRow(Icons.calendar_today, 'Fecha de finalización',
                        _formatDate(task['date_finish'])),
                  ],
                ),

                const SizedBox(height: 16),

                // Descripción
                if (task['description'] != null &&
                    task['description'].toString().isNotEmpty)
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
                              task['description'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Información del Sistema
                if (task['created_at'] != null || task['updated_at'] != null)
                  _buildInfoSection(
                    'Información del Sistema',
                    Icons.settings,
                    Colors.grey,
                    [
                      if (task['created_at'] != null)
                        _buildInfoRow(Icons.date_range, 'Creada',
                            _formatDate(task['created_at'])),
                      if (task['updated_at'] != null)
                        _buildInfoRow(Icons.update, 'Actualizada',
                            _formatDate(task['updated_at'])),
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
                              String? selected = task['state'];
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
                              nuevoEstado != task['state']) {
                            final response = await http.put(
                              Uri.parse(
                                  'https://backend-jcrgapp.onrender.com/user/Task/state'),
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode(
                                  {"id": task['ID'], "state": nuevoEstado}),
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
                                  'https://backend-jcrgapp.onrender.com/user/Task/${task['ID']}'),
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
