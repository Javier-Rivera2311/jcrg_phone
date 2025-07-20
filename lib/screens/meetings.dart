import 'package:flutter/material.dart';
import 'package:jcrg_phone/widgets/formularyMeet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jcrg_phone/widgets/meeting_detail_screen.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  List<Map<String, dynamic>> presencialMeetings = [];
  List<Map<String, dynamic>> virtualMeetings = [];
  bool isLoading = true;
  String _searchQuery = '';
  int _selectedTab = 0; // 0 para virtuales, 1 para presenciales

  @override
  void initState() {
    super.initState();
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse('https://backend-jcrgapp.onrender.com/user/getMeetings'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meetings = data['meetings'] ?? [];
      presencialMeetings = [];
      virtualMeetings = [];
      for (var meet in meetings) {
        if ((meet['type'] ?? '').toLowerCase() == 'presencial') {
          presencialMeetings.add(Map<String, dynamic>.from(meet));
        } else if ((meet['type'] ?? '').toLowerCase() == 'virtual') {
          virtualMeetings.add(Map<String, dynamic>.from(meet));
        }
      }
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> getFilteredMeetings(bool isPresencial) {
    final meetings = isPresencial ? presencialMeetings : virtualMeetings;
    
    if (_searchQuery.isEmpty) return meetings;
    final query = _searchQuery.trim().toLowerCase();
    
    return meetings.where((meet) {
      final title = (meet['title'] ?? meet['Title'] ?? '').toString().toLowerCase();
      final details = (meet['details'] ?? '').toString().toLowerCase();
      final address = (meet['address'] ?? '').toString().toLowerCase();
      final url = (meet['url'] ?? '').toString().toLowerCase();
      
      return title.contains(query) || 
             details.contains(query) || 
             address.contains(query) || 
             url.contains(query);
    }).toList();
  }

  Widget meetingCard(Map<String, dynamic> meet) {
    // Formato de fecha: dd-MM-yyyy
    String formattedDate = '';
    if (meet['date'] != null && meet['date'].toString().isNotEmpty) {
      try {
        final date = DateTime.parse(meet['date']);
        formattedDate = '${date.day.toString().padLeft(2, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.year}';
      } catch (_) {
        formattedDate = meet['date'].toString();
      }
    }

    // Formato de hora: 24h + AM/PM
    String formattedTime = '';
    if (meet['time'] != null && meet['time'].toString().isNotEmpty) {
      try {
        final timeParts = meet['time'].toString().split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        String ampm = hour >= 12 ? 'PM' : 'AM';
        String hourStr = hour.toString().padLeft(2, '0');
        String minuteStr = minute.toString().padLeft(2, '0');
        formattedTime = '$hourStr:$minuteStr $ampm';
      } catch (_) {
        formattedTime = meet['time'].toString();
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingDetailScreen(meeting: meet),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(
            meet['type'] == 'virtual' ? Icons.videocam : Icons.location_on,
            color: meet['type'] == 'virtual' ? Colors.deepPurple : Colors.blue,
          ),
          title: Text(meet['title'] ?? meet['Title'] ?? 'Sin título',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: $formattedDate'),
              Text('Hora: $formattedTime'),
              if (meet['type'] == 'virtual' && meet['url'] != null)
                Text('URL: ${meet['url']}'),
              if (meet['type'] == 'presencial' && meet['address'] != null)
                Text('Dirección: ${meet['address']}'),
              if (meet['details'] != null)
                Text('Detalles: ${meet['details']}'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isWide ? 70 : 80),
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
                  Color(0xFF1565C0),
                  Color(0xFF64B5F6),
                  Color(0xFFBBDEFB),
                ],
              ),
            ),
            child: AppBar(
              title: const Text(
                'Reuniones',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Botones de navegación
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedTab = 0;
                            });
                          },
                          icon: const Icon(Icons.videocam),
                          label: const Text('Virtuales'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedTab == 0
                                ? Colors.deepPurple
                                : Colors.grey[300],
                            foregroundColor:
                                _selectedTab == 0 ? Colors.white : Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedTab = 1;
                            });
                          },
                          icon: const Icon(Icons.location_on),
                          label: const Text('Presenciales'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedTab == 1 
                                ? Colors.blue 
                                : Colors.grey[300],
                            foregroundColor:
                                _selectedTab == 1 ? Colors.white : Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Barra de búsqueda
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
                        hintText: 'Buscar reuniones',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                
                // Lista de reuniones
                Expanded(
                  child: _buildMeetingList(_selectedTab == 1), // true para presenciales, false para virtuales
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularyMeet()),
          );
          if (result == true) {
            await fetchMeetings();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reunión agregada correctamente')),
            );
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar reunión',
      ),
    );
  }

  Widget _buildMeetingList(bool isPresencial) {
    final filteredMeetings = getFilteredMeetings(isPresencial);

    if (filteredMeetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPresencial ? Icons.location_on : Icons.videocam,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isPresencial
                  ? 'No hay reuniones presenciales'
                  : 'No hay reuniones virtuales',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar una nueva reunión',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: 80,
      ),
      itemCount: filteredMeetings.length,
      itemBuilder: (context, index) {
        final meet = filteredMeetings[index];
        return meetingCard(meet);
      },
    );
  }
}
