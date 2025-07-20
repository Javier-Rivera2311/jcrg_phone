import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:jcrg_phone/widgets/formularyMeet.dart';

class MeetingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const MeetingDetailScreen({super.key, required this.meeting});

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No definida';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString.split('T')[0];
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return 'No definida';

    try {
      final timeParts = timeString.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      String ampm = hour >= 12 ? 'PM' : 'AM';
      String hourStr = hour.toString().padLeft(2, '0');
      String minuteStr = minute.toString().padLeft(2, '0');
      return '$hourStr:$minuteStr $ampm';
    } catch (_) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    void refreshParent() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    }

    final isVirtual = meeting['type'] == 'virtual';
    final meetingDate = meeting['date'] != null ? DateTime.parse(meeting['date']) : null;
    final isUpcoming = meetingDate != null ? meetingDate.isAfter(DateTime.now()) : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(meeting['title'] ?? meeting['Title'] ?? 'Reunión'),
        backgroundColor: isVirtual ? Colors.deepPurple : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 24 : 16),
            child: Column(
              children: [
                // Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: isVirtual
                            ? [Colors.deepPurple.shade50, Colors.deepPurple.shade100]
                            : [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isVirtual ? Icons.videocam : Icons.location_on,
                          size: 48,
                          color: isVirtual ? Colors.deepPurple : Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          meeting['title'] ?? meeting['Title'] ?? 'Sin título',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isVirtual ? Colors.deepPurple : Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVirtual ? Icons.videocam : Icons.location_on,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isVirtual ? 'Reunión Virtual' : 'Reunión Presencial',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUpcoming) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Próxima',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Información de Fecha y Hora
                _buildInfoSection(
                  'Fecha y Hora',
                  Icons.schedule,
                  Colors.orange,
                  [
                    _buildInfoRow(Icons.calendar_today, 'Fecha',
                        _formatDate(meeting['date'])),
                    _buildInfoRow(Icons.access_time, 'Hora',
                        _formatTime(meeting['time'])),
                  ],
                ),

                const SizedBox(height: 16),

                // Información de Ubicación/URL
                if (isVirtual && meeting['url'] != null && meeting['url'].toString().isNotEmpty) ...[
                  _buildInfoSection(
                    'Enlace Virtual',
                    Icons.link,
                    Colors.deepPurple,
                    [
                      _buildInfoRowWithAction(
                        Icons.videocam,
                        'URL de la reunión',
                        meeting['url'].toString(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: meeting['url'].toString()));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('URL copiada al portapapeles')),
                                );
                              },
                              tooltip: 'Copiar URL',
                            ),
                            IconButton(
                              icon: const Icon(Icons.launch, size: 20),
                              onPressed: () async {
                                final url = meeting['url'].toString();
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No se pudo abrir el enlace')),
                                  );
                                }
                              },
                              tooltip: 'Abrir enlace',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                if (!isVirtual && meeting['address'] != null && meeting['address'].toString().isNotEmpty) ...[
                  _buildInfoSection(
                    'Ubicación',
                    Icons.location_on,
                    Colors.blue,
                    [
                      _buildInfoRow(Icons.place, 'Dirección',
                          meeting['address'].toString()),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Detalles
                if (meeting['details'] != null && meeting['details'].toString().isNotEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Detalles de la Reunión',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              meeting['details'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormularyMeet(meeting: meeting),
                            ),
                          );
                          if (result == true) {
                            refreshParent();
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Editar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isVirtual ? Colors.deepPurple : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: const Text(
                                  '¿Estás seguro de que deseas eliminar esta reunión?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            final id = meeting['id'] ?? meeting['ID'];
                            final response = await http.delete(
                              Uri.parse('https://backend-jcrgapp.onrender.com/user/deleteMeeting/$id'),
                            );
                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reunión eliminada')),
                              );
                              refreshParent();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error al eliminar la reunión')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text("Eliminar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, Color color, List<Widget> children) {
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

  Widget _buildInfoRowWithAction(IconData icon, String label, String value, Widget? action) {
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}
