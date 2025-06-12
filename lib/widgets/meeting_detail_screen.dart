import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:jcrg_phone/widgets/formularyMeet.dart';

class MeetingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const MeetingDetailScreen({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    // Formato de fecha: dd-MM-yyyy
    String formattedDate = '';
    if (meeting['date'] != null && meeting['date'].toString().isNotEmpty) {
      try {
        // Soporta fechas tipo '2025-06-26T00:00:00.000Z' y '2025-06-26'
        String dateStr = meeting['date'].toString();
        DateTime date = DateTime.parse(dateStr);
        formattedDate = '${date.day.toString().padLeft(2, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.year}';
      } catch (_) {
        // Si falla el parseo, intenta extraer solo la parte de la fecha
        final dateStr = meeting['date'].toString();
        final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(dateStr);
        if (match != null) {
          formattedDate = '${match.group(3)}-${match.group(2)}-${match.group(1)}';
        } else {
          formattedDate = dateStr;
        }
      }
    }

    // Formato de hora: 24h + AM/PM
    String formattedTime = '';
    if (meeting['time'] != null && meeting['time'].toString().isNotEmpty) {
      try {
        final timeParts = meeting['time'].toString().split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        String ampm = hour >= 12 ? 'PM' : 'AM';
        String hourStr = hour.toString().padLeft(2, '0');
        String minuteStr = minute.toString().padLeft(2, '0');
        formattedTime = '$hourStr:$minuteStr $ampm';
      } catch (_) {
        formattedTime = meeting['time'].toString();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(meeting['title'] ?? meeting['Title'] ?? 'Detalle reunión'),
      ),
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
                Text(meeting['title'] ?? meeting['Title'] ?? 'Sin título',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Divider(height: 20, thickness: 1.2),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.green),
                  title: const Text("Fecha"),
                  subtitle: Text(formattedDate),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.blue),
                  title: const Text("Hora"),
                  subtitle: Text(formattedTime),
                ),
                ListTile(
                  leading: Icon(
                    meeting['type'] == 'virtual' ? Icons.videocam : Icons.location_on,
                    color: meeting['type'] == 'virtual' ? Colors.deepPurple : Colors.blue,
                  ),
                  title: const Text("Tipo"),
                  subtitle: Text(meeting['type'] ?? ''),
                ),
                if (meeting['type'] == 'virtual' && meeting['url'] != null && meeting['url'].toString().isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.link, color: Colors.teal),
                    title: const Text("URL"),
                    subtitle: GestureDetector(
                      onTap: () async {
                        final url = meeting['url'].toString();
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          Clipboard.setData(ClipboardData(text: url));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('URL copiada al portapapeles')),
                          );
                        }
                      },
                      child: Text(
                        meeting['url'],
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                if (meeting['type'] == 'presencial' && meeting['address'] != null && meeting['address'].toString().isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.orange),
                    title: const Text("Dirección"),
                    subtitle: Text(meeting['address']),
                  ),
                if (meeting['details'] != null)
                  ListTile(
                    leading: const Icon(Icons.description, color: Colors.purple),
                    title: const Text("Detalles"),
                    subtitle: Text(meeting['details']),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormularyMeet(meeting: meeting),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Editar"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text('¿Estás seguro de que deseas eliminar esta reunión?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final id = meeting['id'] ?? meeting['ID'];
                          final url = 'https://backend-jcrg.onrender.com/user/deleteMeeting/$id';
                          final response = await http.delete(Uri.parse(url));
                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reunión eliminada')),
                            );
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al eliminar la reunión')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Eliminar"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
