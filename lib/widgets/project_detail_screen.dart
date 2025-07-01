import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      appBar: AppBar(title: Text(project['name'] ?? 'Proyecto')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project['name'] ?? '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Divider(height: 20, thickness: 1.2),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.blue),
                  title: const Text("Estado"),
                  subtitle: Text(project['state'] ?? ''),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.green),
                  title: const Text("Fecha de finalización"),
                  subtitle: Text(
                    (project['date_finish'] ?? '').toString().split("T")[0],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.deepPurple),
                  title: const Text("Encargado"),
                  subtitle: Text(project['manager'] ?? ''),
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.orange),
                  title: const Text("Participantes"),
                  subtitle: Text(project['participants'] ?? ''),
                ),
                ListTile(
                  leading: const Icon(Icons.description, color: Colors.teal),
                  title: const Text("Descripción"),
                  subtitle: Text(project['description'] ?? ''),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String? nuevoEstado = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              String? selected = project['state'];
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
                                            setStateDialog(() => selected = value);
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: const Text('En progreso'),
                                          value: 'en progreso',
                                          groupValue: selected,
                                          onChanged: (value) {
                                            setStateDialog(() => selected = value);
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: const Text('Completado'),
                                          value: 'completado',
                                          groupValue: selected,
                                          onChanged: (value) {
                                            setStateDialog(() => selected = value);
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: const Text('Cancelado'),
                                          value: 'cancelado',
                                          groupValue: selected,
                                          onChanged: (value) {
                                            setStateDialog(() => selected = value);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, null),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, selected),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (nuevoEstado != null && nuevoEstado != project['state']) {
                            await http.put(
                              Uri.parse('https://backend-jcrg.onrender.com/user/Project/state'),
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode({
                                "id": project['ID'],
                                "state": nuevoEstado
                              }),
                            );
                            refreshParent();
                          }
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text("Cambiar estado"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await http.delete(
                            Uri.parse('https://backend-jcrg.onrender.com/user/Project/${project['ID']}'),
                          );
                          refreshParent();
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text("Eliminar proyecto"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}