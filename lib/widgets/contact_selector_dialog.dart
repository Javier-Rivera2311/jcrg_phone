import 'package:flutter/material.dart';
import 'package:jcrg_phone/screens/externalproject.dart';

class ContactSelectorDialog extends StatefulWidget {
  final List<Map<String, dynamic>> contacts;
  final List<String> selectedContacts;

  const ContactSelectorDialog({
    super.key,
    required this.contacts,
    required this.selectedContacts,
  });

  @override
  State<ContactSelectorDialog> createState() => _ContactSelectorDialogState();
}

class _ContactSelectorDialogState extends State<ContactSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredContacts = [];
  List<String> _tempSelectedContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
    _tempSelectedContacts = List.from(widget.selectedContacts);
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = widget.contacts.where((contact) {
        final name = contact['Name']?.toLowerCase() ?? '';
        final email = contact['email']?.toLowerCase() ?? '';
        final organization = contact['organization']?.toLowerCase() ?? '';
        return name.contains(query) ||
            email.contains(query) ||
            organization.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.public, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Seleccionar Contactos Externos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar contactos...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _filterContacts(),
              ),
            ),

            // Contacts list
            Expanded(
              child: ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  final name = contact['Name'] ?? 'Sin nombre';
                  final isSelected = _tempSelectedContacts.contains(name);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (contact['organization'] != null)
                          Text(contact['organization']),
                        if (contact['email'] != null) Text(contact['email']),
                      ],
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _tempSelectedContacts.add(name);
                          } else {
                            _tempSelectedContacts.remove(name);
                          }
                        });
                      },
                    ),
                    onTap: () {
                      // Navegar a la vista de detalles del contacto
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExternalProjectScreen(contact: contact),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('${_tempSelectedContacts.length} seleccionados'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, _tempSelectedContacts),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
