import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkerScreen extends StatefulWidget {
  const WorkerScreen({super.key});

  @override
  State<WorkerScreen> createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {
  List<dynamic> workers = [];

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    try {
      final response = await http.get(Uri.parse('https://backend-jcrg.onrender.com/user/mostrar'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          workers = data['usuarios'];
        });
      } else {
        throw Exception('Error al cargar los datos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Altura estándar del AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20.0), // Bordes redondeados en la esquina inferior izquierda
            bottomRight: Radius.circular(20.0), // Bordes redondeados en la esquina inferior derecha
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2962FF), // Azul eléctrico
                  Color(0xFF64B5F6), // Azul intermedio
                  Color(0xFFBBDEFB), // Azul claro
                ],
              ),
            ),
            child: AppBar(
              title: const Text(
                'Personal',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Fondo transparente para mostrar el degradado
              elevation: 0, // Sin sombra
            ),
          ),
        ),
      ),
      body: workers.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Muestra un indicador de carga mientras se obtienen los datos
          : ListView.builder(
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return ListTile(
                  title: Text(worker['Name'] ?? 'Sin nombre'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Correo: ${worker['mail'] ?? 'No disponible'}'),
                      Text('Departamento: ${worker['department_name'] ?? 'No disponible'}'),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}