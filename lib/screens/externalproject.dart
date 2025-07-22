import 'package:flutter/material.dart';

class ExternalProjectScreen extends StatelessWidget {
  final Map<String, dynamic> contact;

  const ExternalProjectScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact['Name'] ?? 'Contacto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.blue.withOpacity(0.2)
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Text(
                        contact['Name']?.isNotEmpty == true
                            ? contact['Name'][0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      contact['Name'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (contact['job'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          contact['job'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información de contacto
            _buildInfoSection(
              'Información de Contacto',
              Icons.contact_phone,
              Colors.green,
              [
                if (contact['email'] != null)
                  _buildInfoRow(Icons.email, 'Email', contact['email']),
                if (contact['Phone'] != null)
                  _buildInfoRow(Icons.phone, 'Teléfono', contact['Phone']),
                if (contact['Commune'] != null)
                  _buildInfoRow(
                      Icons.location_on, 'Comuna', contact['Commune']),
              ],
            ),

            const SizedBox(height: 16),

            // Información profesional
            _buildInfoSection(
              'Información Profesional',
              Icons.work,
              Colors.orange,
              [
                if (contact['organization'] != null)
                  _buildInfoRow(
                      Icons.business, 'Organización', contact['organization']),
                if (contact['project'] != null)
                  _buildInfoRow(Icons.folder, 'Proyecto', contact['project']),
                if (contact['job'] != null)
                  _buildInfoRow(Icons.work_outline, 'Cargo', contact['job']),
              ],
            ),

            const SizedBox(height: 16),

            // Acciones
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.contact_phone, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Acciones de Contacto',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (contact['Phone'] != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Implementar llamada telefónica
                              },
                              icon: const Icon(Icons.phone),
                              label: const Text('Llamar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        if (contact['Phone'] != null &&
                            contact['email'] != null)
                          const SizedBox(width: 8),
                        if (contact['email'] != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Implementar envío de email
                              },
                              icon: const Icon(Icons.email),
                              label: const Text('Email'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      String title, IconData icon, Color color, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
