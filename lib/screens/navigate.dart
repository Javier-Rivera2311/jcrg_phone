import 'package:flutter/material.dart';
import 'home.dart'; // Importa las pantallas
import 'task.dart';
import 'contact.dart';
import 'meetings.dart';
import 'workers.dart';
import 'notifications.dart';
import 'project.dart';
import 'report.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> screens;

  void setTabIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    screens = [
      Home(onNavigate: setTabIndex),
      const TaskScreen(),
      const ContactScreen(),
      const ProjectScreen(), // Cambiado de MeetingScreen a ProjectScreen
      const WorkerScreen(),
      const NotificationScreen(),
      const MeetingScreen(), // Cambiado de ProjectScreen a MeetingScreen
      const ReportScreen(),
    ];
  }

  final colors = [
    Color(0xFF42A5F5), // Azul más intenso, home
    Color(0xFF2196F3), // Azul estándar, tareas
    Color(0xFF1E88E5), // Azul oscuro, contactos
    Color.fromARGB(255, 116, 169, 255), // Azul pastel, proyecto
    Color(0xFF2962FF), // Azul eléctrico, personal
    Color(0xFF1976D2), // Azul vibrante, notificaciones
    Color(0xFF1565C0), // Azul más oscuro, reuniones
    Color.fromARGB(255, 255, 33, 33), // reportar problema
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'JCRG',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: colors[_currentIndex],
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              setState(() {
                _currentIndex = 5; // Índice de la pantalla de notificaciones
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: colors[_currentIndex],
                    ),
                    child: const Text(
                      'Menú',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Inicio'),
                    onTap: () {
                      setState(() => _currentIndex = 0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.task),
                    title: const Text('Tareas'),
                    onTap: () {
                      setState(() => _currentIndex = 1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.contact_page),
                    title: const Text('Contactos'),
                    onTap: () {
                      setState(() => _currentIndex = 2);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.work), // Icono para Proyecto
                    title: const Text('Proyecto'),
                    onTap: () {
                      setState(() => _currentIndex = 3); // Cambiado de 6 a 3
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Personal'),
                    onTap: () {
                      setState(() => _currentIndex = 4);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notificaciones'),
                    onTap: () {
                      setState(() => _currentIndex = 5);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Reuniones'),
                    onTap: () {
                      setState(() => _currentIndex = 6); // Cambiado de 3 a 6
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.report),
                    title: const Text('Reportar problema'),
                    onTap: () {
                      setState(() => _currentIndex = 7);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!mounted) return;
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: _currentIndex < screens.length
          ? screens[_currentIndex]
          : const Center(child: Text('Pantalla no encontrada')),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 10),
        child: GNav(
          color:
              colors[_currentIndex % colors.length], // Previene error de rango
          tabBackgroundColor: colors[_currentIndex % colors.length],
          selectedIndex: _currentIndex,
          tabBorderRadius: 10,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          onTabChange: (index) => {setState(() => _currentIndex = index)},
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
              iconActiveColor: Colors.white,
              textColor: Colors.white,
            ),
            GButton(
              icon: Icons.task,
              text: 'Tareas',
              iconActiveColor: Colors.white,
              textColor: Colors.white,
            ),
            GButton(
              icon: Icons.contact_page,
              text: 'Contactos',
              iconActiveColor: Colors.white,
              textColor: Colors.white,
            ),
            GButton(
              icon: Icons.work,
              text: 'Proyecto',
              iconActiveColor: Colors.white,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
