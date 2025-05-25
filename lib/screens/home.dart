import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final void Function(int)? onNavigate;
  const Home({super.key, this.onNavigate});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
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
                  Color(0xFF42A5F5),
                  Color.fromARGB(255, 104, 184, 250),
                  Color.fromARGB(255, 213, 234, 252),
                ],
              ),
            ),
            child: AppBar(
              title: const Text(
                'Inicio',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                userName != null && userName!.isNotEmpty
                    ? '¡Bienvenido a la App JCRG, $userName!'
                    : '¡Bienvenido a la App JCRG!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Administra tus tareas, notificaciones del trabajo, contactos, reuniones y más desde un solo lugar.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  double buttonWidth = (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildButton(Icons.task, 'Tareas', const Color.fromARGB(255, 33, 192, 38), buttonWidth, 1),
                      _buildButton(Icons.meeting_room, 'Reuniones', Colors.blueAccent, buttonWidth, 3),
                      _buildButton(Icons.message, 'Mensajes', Colors.orangeAccent, buttonWidth, 6),
                      _buildButton(Icons.contact_page, 'Contactos', Colors.purpleAccent, buttonWidth, 2),
                      _buildButton(Icons.people, 'Personal', Colors.teal, buttonWidth, 4),
                      _buildButton(Icons.notifications, 'Notificaciones', const Color.fromARGB(255, 2, 189, 202), buttonWidth, 5),
                    ],
                  );
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onNavigate?.call(7); // Ir a Reportar Problema
                  },
                  icon: const Icon(Icons.report_problem, color: Colors.white),
                  label: const Text('Reportar Problema'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 207, 29, 29),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, Color color, double width, int tabIndex) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: () {
          widget.onNavigate?.call(tabIndex);
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
