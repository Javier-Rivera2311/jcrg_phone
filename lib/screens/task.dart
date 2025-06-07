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

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final response = await http
        .get(Uri.parse('https://backend-jcrg.onrender.com/user/getTasks'));

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

      setState(() {
        groupedTasks = grouped;
        _allTasks = List<Map<String, dynamic>>.from(tasks);
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final filteredGroupedTasks = getFilteredTasks();
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true, // <-- Agrega esto para evitar overflow
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
            child: filteredGroupedTasks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (isWide) {
                        // Vista tipo grid para pantallas anchas
                        List<Widget> tiles = [];
                        filteredGroupedTasks.forEach((category, tasks) {
                          tiles.add(
                            Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              child: ExpansionTile(
                                title: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                children: tasks.map((task) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final changed = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TaskDetailScreen(task: task),
                                          ),
                                        );
                                        if (changed == true) {
                                          fetchTasks();
                                        }
                                      },
                                      child: Card(
                                        color: task['state'] == 'completada'
                                            ? Colors.green[100]
                                            : task['state'] == 'en progreso'
                                                ? Colors.yellow[100]
                                                : task['state'] == 'pendiente'
                                                    ? Colors.red[100]
                                                    : Colors.white,
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.assignment,
                                                      color: Colors.blue),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(task['title'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text("Estado: ${task['state']}"),
                                              Text(
                                                  "Fecha: ${task['date_finish'].toString().split('T')[0]}"),
                                              Text(
                                                  "Trabajadores: ${task['workers']}"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        });
                        return GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          children: tiles,
                        );
                      } else {
                        // Vista lista para móviles
                        return ListView(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 12,
                            bottom:
                                80, // <-- Agrega padding inferior para evitar que el botón flote sobre el contenido
                          ),
                          children: filteredGroupedTasks.entries.map((entry) {
                            final category = entry.key;
                            final tasks = entry.value;

                            return ExpansionTile(
                              title: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              children: tasks.map((task) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final changed = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              TaskDetailScreen(task: task),
                                        ),
                                      );
                                      if (changed == true) {
                                        fetchTasks();
                                      }
                                    },
                                    child: Card(
                                      color: task['state'] == 'completada'
                                          ? Colors.green[100]
                                          : task['state'] == 'en progreso'
                                              ? Colors.yellow[100]
                                              : task['state'] == 'pendiente'
                                                  ? Colors.red[100]
                                                  : Colors.white,
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.assignment,
                                                    color: Colors.blue),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(task['title'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      )),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text("Estado: ${task['state']}"),
                                            Text(
                                                "Fecha: ${task['date_finish'].toString().split('T')[0]}"),
                                            Text(
                                                "Trabajadores: ${task['workers']}"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        );
                      }
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
}
