import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'formularyTicket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateTicketView extends StatefulWidget {
  const GenerateTicketView({super.key});

  @override
  State<GenerateTicketView> createState() => _GenerateTicketViewState();
}

class _GenerateTicketViewState extends State<GenerateTicketView> {
  late Future<List<dynamic>> myTicketsFuture;

  @override
  void initState() {
    super.initState();
    myTicketsFuture = fetchMyTickets();
  }

  Future<List<dynamic>> fetchMyTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no disponible. Por favor inicie sesión.');
    }

    final response = await http.get(
      Uri.parse('https://backend-jcrg.onrender.com/user/myTickets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // <- clave para autenticación
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // DEBUG: imprime la respuesta para ver la estructura real
      print('Respuesta myTickets: $data');
      // Intenta encontrar la lista de tickets en diferentes claves posibles
      if (data is List) {
        return data;
      } else if (data['data'] is List) {
        return data['data'];
      } else if (data['tickets'] is List) {
        return data['tickets'];
      } else if (data['data'] is Map) {
        return [data['data']];
      } else if (data['ticket'] != null) {
        return [data['ticket']];
      } else {
        return [];
      }
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado (403): Token faltante o inválido.');
    } else {
      throw Exception('Error al cargar tus tickets (${response.statusCode})');
    }
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return 'Sin fecha';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  Widget buildTicketTile(Map<String, dynamic> ticket) {
    return ListTile(
      leading: Icon(
        ticket['status'] == 'Cerrado'
            ? Icons.check_circle
            : ticket['status'] == 'En progreso'
                ? Icons.autorenew
                : Icons.error_outline,
        color: ticket['status'] == 'Cerrado'
            ? Colors.green
            : ticket['status'] == 'En progreso'
                ? Colors.orange
                : Colors.red,
      ),
      title: Text(ticket['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prioridad: ${ticket['priority'] ?? ''}'),
          Text('Estado: ${ticket['status'] ?? ''}'),
          Text('Departamento: ${ticket['department_name'] ?? ''}'),
          Text('Trabajador: ${ticket['worker_name'] ?? ''}'),
          Text('Creado: ${formatDate(ticket['creation_date'])}'),
          if ((ticket['support_response'] ?? '').toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Respuesta soporte: ${ticket['support_response']}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void openCreateTicketForm() async {
    // Simula workerId y departmentId, reemplaza por los valores reales si los tienes
    const workerId = 1;
    const departmentId = 1;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FormularyTicket(workerId: workerId, departmentId: departmentId),
      ),
    );
    setState(() {
      myTicketsFuture = fetchMyTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 255, 33, 33),
                Color.fromARGB(255, 255, 100, 100),
                Color.fromARGB(255, 255, 180, 180),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0), // Bordes redondeados en la esquina inferior izquierda
              bottomRight: Radius.circular(20.0), // Bordes redondeados en la esquina inferior derecha
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Mis Tickets'),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: myTicketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('No tienes tickets creados.'));
          }
          return ListView.separated(
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return buildTicketTile(ticket);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateTicketForm,
        child: const Icon(Icons.add),
        tooltip: 'Crear Ticket',
      ),
    );
  }
}
