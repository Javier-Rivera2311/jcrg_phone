import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/openProject.dart';
import '../widgets/formularyProject.dart'; // Agregar esta importación

class ProjectDetailScreen extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectDetailScreen({super.key, required this.project});

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No definida';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString.split('T')[0]; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    void refreshParent() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(project['Name_project'] ?? 'Proyecto'),
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
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 600 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 40 : 20),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(isWide ? 40 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project['Name_project'] ?? '',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const Divider(height: 20, thickness: 1.2),
                          ListTile(
                            leading: const Icon(Icons.location_city,
                                color: Colors.blue),
                            title: const Text("Ciudad"),
                            subtitle:
                                Text(project['city'] ?? 'No especificada'),
                          ),
                          if (project['init_date'] != null)
                            ListTile(
                              leading: const Icon(Icons.calendar_today_outlined,
                                  color: Colors.green),
                              title: const Text("Fecha de inicio"),
                              subtitle: Text(_formatDate(project['init_date'])),
                            ),
                          ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: Colors.orange),
                            title: const Text("Fecha de finalización"),
                            subtitle: Text(_formatDate(project['end_date'])),
                          ),
                          if (project['date_deliveries'] != null)
                            ListTile(
                              leading: const Icon(Icons.local_shipping,
                                  color: Colors.teal),
                              title: const Text("Fecha de entregas"),
                              subtitle:
                                  Text(_formatDate(project['date_deliveries'])),
                            ),
                          if (project['deliveries'] != null)
                            ListTile(
                              leading: const Icon(Icons.inventory,
                                  color: Colors.indigo),
                              title: const Text("Número de entregas"),
                              subtitle: Text(project['deliveries'].toString()),
                            ),
                          ListTile(
                            leading: const Icon(Icons.person,
                                color: Colors.deepPurple),
                            title: const Text("Encargado"),
                            subtitle:
                                Text(project['in_charge'] ?? 'No asignado'),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.people, color: Colors.purple),
                            title: const Text("Trabajadores"),
                            subtitle:
                                Text(project['workers'] ?? 'No asignados'),
                          ),
                          if (project['mandate'] != null &&
                              project['mandate'].toString().isNotEmpty)
                            ListTile(
                              leading:
                                  const Icon(Icons.gavel, color: Colors.brown),
                              title: const Text("Mandato"),
                              subtitle: Text(project['mandate'].toString()),
                            ),
                          if (project['external'] != null &&
                              project['external'].toString().isNotEmpty)
                            ListTile(
                              leading:
                                  const Icon(Icons.public, color: Colors.cyan),
                              title: const Text("Contactos externos"),
                              subtitle: Text(project['external'].toString()),
                            ),
                          if (project['contracts'] != null)
                            ListTile(
                              leading: const Icon(Icons.description,
                                  color: Colors.deepOrange),
                              title: const Text("Contratos"),
                              subtitle: Text(project['contracts'].toString()),
                            ),
                          if (project['observations'] != null &&
                              project['observations'].toString().isNotEmpty)
                            ListTile(
                              leading:
                                  const Icon(Icons.note, color: Colors.grey),
                              title: const Text("Observaciones"),
                              subtitle: Text(project['observations']),
                            ),
                          ListTile(
                            leading:
                                const Icon(Icons.folder, color: Colors.amber),
                            title: const Text("Ruta del servidor"),
                            subtitle: Text(project['local_path'] ?? 'Sin ruta'),
                            trailing: project['local_path'] != null
                                ? OpenProject(
                                    windowsPath: project['local_path'],
                                    tooltip: 'Abrir carpeta',
                                    icon: Icons.open_in_new,
                                  )
                                : null,
                          ),
                          ListTile(
                            leading: const Icon(Icons.date_range,
                                color: Colors.blueGrey),
                            title: const Text("Creado"),
                            subtitle: Text(_formatDate(project['created_at'])),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.update, color: Colors.grey),
                            title: const Text("Actualizado"),
                            subtitle: Text(_formatDate(project['updated_at'])),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Debug: imprimir el proyecto para verificar el ID
                                    print('Project data: $project');
                                    // Navegar al formulario de edición
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
                                  label: const Text("Editar proyecto"),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await http.delete(
                                      Uri.parse(
                                          'https://backend-jcrgapp.onrender.com/user/deleteProject/${project['id_server']}'),
                                    );
                                    refreshParent();
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text("Eliminar proyecto"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
