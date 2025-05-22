import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jcrg_phone/widgets/Enter_contact.dart';
import 'package:jcrg_phone/widgets/update_contact.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<dynamic> contacts = [];
  List<dynamic> filteredContacts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchContacts();
    searchController.addListener(() {
      filterContacts();
    });
  }

  Future<void> fetchContacts() async {
    try {
      final response = await http.get(Uri.parse('https://backend-jcrg.onrender.com/user/Contacts'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          contacts = data['usuarios'];
          filteredContacts = contacts; // Inicialmente, muestra todos los contactos
        });
      } else {
        throw Exception('Error al cargar los datos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

void filterContacts() {
  final query = searchController.text.toLowerCase();
  setState(() {
    filteredContacts = contacts.where((contact) {
      final name = contact['Name']?.toLowerCase() ?? '';
      final email = contact['email']?.toLowerCase() ?? '';
      final commune = contact['Commune']?.toLowerCase() ?? '';
      final phone = contact['Phone']?.toLowerCase() ?? '';
      final job = contact['job']?.toLowerCase() ?? '';
      final project = contact['project']?.toLowerCase() ?? '';

      return name.contains(query) ||
          email.contains(query) ||
          commune.contains(query) ||
          phone.contains(query) ||
          job.contains(query) ||
          project.contains(query);
    }).toList();
  });
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
                  Color(0xFF1E88E5), // Azul oscuro
                  Color(0xFF64B5F6), // Azul intermedio
                  Color(0xFFBBDEFB), // Azul claro
                ],
              ),
            ),
            child: AppBar(
              title: const Text(
                'Contactos',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Fondo transparente para mostrar el degradado
              elevation: 0, // Sin sombra
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar',
                hintText: 'Ingresa un contacto',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredContacts.isEmpty
                ? const Center(child: Text('No se encontraron contactos'))
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(contact['Name'] ?? 'Sin nombre'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Correo: ${contact['email'] ?? 'No disponible'}'),
                              Text('Teléfono: ${contact['Phone'] ?? 'No disponible'}'),
                              Text('Comuna: ${contact['Commune'] ?? 'No disponible'}'),
                              Text('Trabajo: ${contact['job'] ?? 'No disponible'}'),
                              Text('Proyecto: ${contact['project'] ?? 'No disponible'}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditContactForm(contact: contact),
                                ),
                              );
                              if (result == true) {
                                fetchContacts(); // Refresca la lista si se editó un contacto
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EnterContactForm(),
            ),
          );
          if (result == true) {
            fetchContacts(); // Refresca la lista si se agregó un contacto
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}