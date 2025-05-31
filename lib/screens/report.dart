import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:jcrg_phone/widgets/check_ticket.dart';
import 'package:jcrg_phone/widgets/generate_ticket.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Future<bool> fetchIsSpecialUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs
          .getString('token'); // Asegúrate de guardar el token al hacer login
      print('Token enviado: $token');
      final response = await http.get(
        Uri.parse(
            'https://backend-jcrg.onrender.com/user/departamentosUsuarios'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('Respuesta backend: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('departamentos')) {
          final departamentos = data['departamentos'];

          if (departamentos is List) {
            for (var d in departamentos) {
              if (d is Map && d['department_id'] == 4) {
                return true;
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error al verificar usuario especial: $e');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: fetchIsSpecialUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
                child: Text('No se pudo obtener la información del usuario')),
          );
        }

        final isAuthorizedUser = snapshot.data!;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 255, 33, 33), // Rojo principal
                    Color.fromARGB(255, 255, 100, 100), // Primer tono más claro
                    Color.fromARGB(
                        255, 255, 160, 160), // Segundo tono más claro
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: AppBar(
                title: const Text('Reportar Problema'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
          body: isAuthorizedUser
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Vista especial para usuarios autorizados',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Verificar Ticket'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CheckTicketView()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Generar Ticket'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const GenerateTicketView()),
                          );
                        },
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    'Vista estándar: No tienes acceso especial.',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
        );
      },
    );
  }
}
