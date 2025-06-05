import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskDetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Función para refrescar la vista anterior al volver
    void refreshParent() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true); // Devuelve true para indicar que hubo cambios
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(task['title'])),
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
                Text(task['title'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Divider(height: 20, thickness: 1.2),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.blue),
                  title: const Text("Estado"),
                  subtitle: Text(task['state']),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.green),
                  title: const Text("Fecha de finalización"),
                  subtitle: Text(task['date_finish'].toString().split("T")[0]),
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.deepPurple),
                  title: const Text("Trabajadores"),
                  subtitle: Text(task['workers']),
                ),
                ListTile(
                  leading: const Icon(Icons.category, color: Colors.orange),
                  title: const Text("Categoría"),
                  subtitle: Text(task['category']),
                ),
                ListTile(
                  leading: const Icon(Icons.description, color: Colors.teal),
                  title: const Text("Descripción"),
                  subtitle: Text(task['description'] ?? ''),
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
                                          title: const Text('Completada'),
                                          value: 'completada',
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
                          if (nuevoEstado != null && nuevoEstado != task['state']) {
                            await http.put(
                              Uri.parse('https://backend-jcrg.onrender.com/user/Task/state'),
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode({
                                "id": task['ID'],
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
                            Uri.parse('https://backend-jcrg.onrender.com/user/Task/${task['ID']}'),
                          );
                          refreshParent();
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text("Eliminar tarea"),
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
