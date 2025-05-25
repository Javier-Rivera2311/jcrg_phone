import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

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
                  Color(0xFF42A5F5), // Azul más intenso
                  Color.fromARGB(255, 104, 184, 250), // Azul más claro
                  Color.fromARGB(255, 213, 234, 252), // Azul más claro
                ],
              ),
            ),
            child: AppBar(
              title: const Text(
                'Inicio',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Fondo transparente para mostrar el degradado
              elevation: 0, // Sin sombra
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
                style: TextStyle(fontSize: 16, color: Colors.black54), // Cambiado a negro suave
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calcula el ancho para 2 botones por fila con espacio entre ellos
                  double buttonWidth = (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildButton(
                        icon: Icons.task,
                        label: 'Tareas',
                        color: const Color.fromARGB(255, 33, 192, 38),
                        width: buttonWidth,
                      ),
                      _buildButton(
                        icon: Icons.meeting_room,
                        label: 'Reuniones',
                        color: Colors.blueAccent,
                        width: buttonWidth,
                      ),
                      _buildButton(
                        icon: Icons.message,
                        label: 'Mensajes',
                        color: Colors.orangeAccent,
                        width: buttonWidth,
                      ),
                      _buildButton(
                        icon: Icons.contact_page,
                        label: 'Contactos',
                        color: Colors.purpleAccent,
                        width: buttonWidth,
                      ),
                      _buildButton(
                        icon: Icons.people,
                        label: 'Personal',
                        color: Colors.teal,
                        width: buttonWidth,
                      ),
                      _buildButton(
                        icon: Icons.notifications,
                        label: 'Notificaciones',
                        color: const Color.fromARGB(255, 2, 189, 202),
                        width: buttonWidth,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 15),
              // Botón más grande para "Reportar Problema"
              SizedBox(
                width: double.infinity, // Ocupa todo el ancho disponible
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Acción para reportar problema
                  },
                  icon: const Icon(Icons.report_problem, color: Colors.white), // Icono en blanco
                  label: const Text('Reportar Problema'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 207, 29, 29), // Cambiado al color de "Notificaciones"
                    foregroundColor: Colors.white, // Texto en blanco
                    padding: const EdgeInsets.symmetric(vertical: 15), // Más alto
                    textStyle: const TextStyle(fontSize: 20), // Tamaño de letra más grande
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    double? width,
  }) {
    return SizedBox(
      width: width ?? 162, // Usa el ancho calculado o el fijo por defecto
      child: ElevatedButton.icon(
        onPressed: () {
          // Acción para el botón
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(label, overflow: TextOverflow.ellipsis), // Elipsis si es muy largo
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