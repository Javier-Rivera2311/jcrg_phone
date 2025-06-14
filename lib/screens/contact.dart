import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jcrg_phone/widgets/Enter_contact.dart';
import 'package:jcrg_phone/widgets/update_contact.dart';
import 'package:flutter/services.dart'; // Agrega esta línea
import 'package:url_launcher/url_launcher.dart'; // Agrega esta línea

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
      final response = await http
          .get(Uri.parse('https://backend-jcrg.onrender.com/user/Contacts'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> usuarios = data['usuarios'];
        usuarios.sort((a, b) => (a['Name'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((b['Name'] ?? '').toString().toLowerCase()));
        if (mounted) {
          setState(() {
            contacts = data['usuarios'];
            filteredContacts =
                contacts; // Inicialmente, muestra todos los contactos
          });
        }
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
        preferredSize:
            const Size.fromHeight(60.0), // Altura estándar del AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(
                20.0), // Bordes redondeados en la esquina inferior izquierda
            bottomRight: Radius.circular(
                20.0), // Bordes redondeados en la esquina inferior derecha
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
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors
                  .transparent, // Fondo transparente para mostrar el degradado
              elevation: 0, // Sin sombra
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, correo, comuna...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
                      Color cardColor;
                      switch ((contact['job'] ?? '').toLowerCase()) {
                        case 'jefe':
                          cardColor = Colors.blue[100]!;
                          break;
                        case 'trabajador':
                          cardColor = Colors.green[100]!;
                          break;
                        default:
                          cardColor = Colors.grey[100]!;
                      }
                      return Card(
                        color: cardColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          title: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  contact['Name'] ?? 'Sin nombre',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      color: Colors.green, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: GestureDetector(
                                      onLongPress: () {
                                        final phone = contact['Phone'] ?? '';
                                        if (phone.isNotEmpty) {
                                          Clipboard.setData(
                                              ClipboardData(text: phone));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Teléfono copiado al portapapeles')),
                                          );
                                        }
                                      },
                                      child: Text(
                                        contact['Phone'] ?? 'No disponible',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_city,
                                      color: Colors.orange, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      contact['Commune'] ?? 'No disponible',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.email,
                                    color: Colors.deepPurple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onLongPress: () {
                                      final email = contact['email'] ?? '';
                                      if (email.isNotEmpty) {
                                        Clipboard.setData(
                                            ClipboardData(text: email));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Correo copiado al portapapeles')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      contact['email'] ?? 'No disponible',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.work, color: Colors.teal),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    contact['job'] ?? 'No disponible',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.assignment,
                                    color: Colors.purple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    contact['project'] ?? 'No disponible',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton.icon(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                label: const Text('Editar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditContactForm(contact: contact),
                                    ),
                                  );
                                  if (result == true) {
                                    fetchContacts();
                                  }
                                },
                              ),
                            ),
                          ],
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
