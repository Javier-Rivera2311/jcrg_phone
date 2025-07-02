import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/openProject.dart';
import '../widgets/formularyProject.dart'; // Agregar esta importación

class ProjectDetailScreen extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectDetailScreen({super.key, required this.project});

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
                            subtitle: Text(project['city'] ?? ''),
                          ),
                          ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: Colors.green),
                            title: const Text("Fecha de finalización"),
                            subtitle: Text(
                              (project['end_date'] ?? '')
                                  .toString()
                                  .split("T")[0],
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.person,
                                color: Colors.deepPurple),
                            title: const Text("Encargado"),
                            subtitle: Text(project['in_charge'] ?? ''),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.people, color: Colors.orange),
                            title: const Text("Trabajadores"),
                            subtitle: Text(project['workers'] ?? ''),
                          ),
                          ListTile(
                            leading: const Icon(Icons.description,
                                color: Colors.teal),
                            title: const Text("Observaciones"),
                            subtitle: Text(project['observations'] ?? ''),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.folder, color: Colors.brown),
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
                                color: Colors.indigo),
                            title: const Text("Creado"),
                            subtitle: Text(
                              (project['created_at'] ?? '')
                                  .toString()
                                  .split("T")[0],
                            ),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.update, color: Colors.grey),
                            title: const Text("Actualizado"),
                            subtitle: Text(
                              (project['updated_at'] ?? '')
                                  .toString()
                                  .split("T")[0],
                            ),
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
                                          'https://backend-jcrg.onrender.com/user/deleteProject/${project['id_server']}'),
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
