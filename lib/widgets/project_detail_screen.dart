import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../widgets/openProject.dart';
import '../widgets/formularyProject.dart'; // Agregar esta importación

class ProjectDetailScreen extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectDetailScreen({super.key, required this.project});

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Sin registro';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString.split('T')[0]; // Fallback
    }
  }

  bool _isUrl(String? text) {
    if (text == null || text.isEmpty) return false;
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.');
  }

  bool _isFilePath(String? text) {
    if (text == null || text.isEmpty) return false;
    return text.startsWith(r'\\') ||
        text.contains(':') ||
        text.contains('/') ||
        text.contains('\\');
  }

  Future<void> _openUrl(String url) async {
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }

    final Uri uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget? _buildActionWidget(String? value) {
    if (value == null || value.isEmpty) return null;

    if (_isUrl(value)) {
      return IconButton(
        icon: const Icon(Icons.open_in_browser, size: 20),
        onPressed: () => _openUrl(value),
        tooltip: 'Abrir URL',
      );
    } else if (_isFilePath(value)) {
      return OpenProject(
        windowsPath: value,
        tooltip: 'Abrir archivo/carpeta',
        icon: Icons.open_in_new,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    void refreshParent() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    }

    final isCompleted = project['end_date'] != null
        ? DateTime.parse(project['end_date']).isBefore(DateTime.now())
        : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(project['Name_project'] ?? 'Proyecto'),
        backgroundColor: isCompleted ? Colors.green : Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (project['local_path'] != null)
            OpenProject(
              windowsPath: project['local_path'],
              tooltip: 'Abrir carpeta del proyecto',
            ),
        ],
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
                        colors: isCompleted
                            ? [Colors.green.shade50, Colors.green.shade100]
                            : [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.folder_open,
                          size: 48,
                          color: isCompleted ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          project['Name_project'] ?? 'Sin nombre',
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
                            color: isCompleted ? Colors.green : Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isCompleted
                                ? 'Proyecto Completado'
                                : 'Proyecto Activo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
                    _buildInfoRow(Icons.location_city, 'Ciudad',
                        project['city'] ?? 'Sin registro'),
                    _buildInfoRow(Icons.person, 'Encargado',
                        project['in_charge'] ?? 'Sin registro'),
                    _buildInfoRow(Icons.people, 'Trabajadores',
                        project['workers'] ?? 'Sin registro'),
                  ],
                ),

                const SizedBox(height: 16),

                // Fechas
                _buildInfoSection(
                  'Cronograma',
                  Icons.schedule,
                  Colors.orange,
                  [
                    _buildInfoRow(Icons.calendar_today_outlined,
                        'Fecha de inicio', _formatDate(project['init_date'])),
                    _buildInfoRow(Icons.calendar_today, 'Fecha de finalización',
                        _formatDate(project['end_date'])),
                    _buildInfoRow(Icons.local_shipping, 'Fecha de entregas',
                        _formatDate(project['date_deliveries'])),
                  ],
                ),

                const SizedBox(height: 16),

                // Detalles del Proyecto
                _buildInfoSection(
                  'Detalles del Proyecto',
                  Icons.assignment,
                  Colors.purple,
                  [
                    _buildInfoRowWithAction(
                      Icons.inventory,
                      'URL de entregas',
                      project['deliveries']?.toString() ?? 'Sin registro',
                      _buildActionWidget(project['deliveries']?.toString()),
                    ),
                    _buildInfoRow(Icons.gavel, 'Mandante',
                        project['mandante']?.toString() ?? 'Sin registro'),
                    _buildInfoRow(Icons.public, 'Contactos externos',
                        project['external']?.toString() ?? 'Sin registro'),
                    _buildInfoRowWithAction(
                      Icons.description,
                      'Contratos',
                      project['contracts']?.toString() ?? 'Sin registro',
                      _buildActionWidget(project['contracts']?.toString()),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Observaciones
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
                            Icon(Icons.note, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Observaciones',
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
                            project['observations']?.toString() ??
                                'Sin registro',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Archivos y Rutas
                _buildInfoSection(
                  'Archivos y Rutas',
                  Icons.folder,
                  Colors.amber,
                  [
                    _buildInfoRowWithAction(
                      Icons.folder_open,
                      'Ruta del servidor',
                      project['local_path'] ?? 'Sin registro',
                      project['local_path'] != null
                          ? OpenProject(
                              windowsPath: project['local_path'],
                              tooltip: 'Abrir carpeta',
                              icon: Icons.open_in_new,
                            )
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Información del Sistema
                _buildInfoSection(
                  'Información del Sistema',
                  Icons.settings,
                  Colors.grey,
                  [
                    _buildInfoRow(Icons.date_range, 'Creado',
                        _formatDate(project['created_at'])),
                    _buildInfoRow(Icons.update, 'Actualizado',
                        _formatDate(project['updated_at'])),
                  ],
                ),

                const SizedBox(height: 24),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final changed = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormularyProject(
                                initialData: project,
                                isEdit: true,
                              ),
                            ),
                          );
                          if (changed == true) {
                            refreshParent();
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Editar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
                                  '¿Estás seguro de que deseas eliminar este proyecto?'),
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
                            await http.delete(
                              Uri.parse(
                                  'https://backend-jcrgapp.onrender.com/user/deleteProject/${project['id_server']}'),
                            );
                            refreshParent();
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

  Widget _buildInfoRowWithAction(
      IconData icon, String label, String value, Widget? action) {
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
          if (action != null) ...[
            const SizedBox(width: 8),
            action,
          ],
        ],
      ),
    );
  }
}
