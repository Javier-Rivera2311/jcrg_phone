import 'package:flutter/material.dart';
import 'home.dart'; // Importa las pantallas
import 'screen_1.dart';
import 'task.dart';
import 'screen_3.dart';
import 'screen_4.dart';
import 'screen_5.dart';
import 'screen_6.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Lista de pantallas
  final screens = [
    const Home(), // Llama la vista HomeScreen
    const Screen1(), // Llama la vista Screen2
    const TaskScreen(),
    const Screen3(), // Llama la vista Screen3
    const Screen4(), // Llama la vista Screen4
    const Screen5(), // Llama la vista Screen5
    const Screen6(), // Llama la vista Screen6
    ];

final colors = [
  Color(0xFF42A5F5), // Azul más intenso
  Color(0xFF2196F3), // Azul estándar
  Color(0xFF1E88E5), // Azul oscuro
  Color(0xFF1565C0), // Azul más oscuro
  Color(0xFF2962FF), // Azul eléctrico
  Color(0xFF1976D2), // Azul vibrante
  Color(0xFF0D47A1), // Azul profundo
  Color(0xFFBBDEFB), // Azul muy claro
  Color(0xFF82B1FF), // Azul pastel
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JCRG',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: colors[_currentIndex],
      ),
      drawer: Drawer(
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
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Mensajes'),
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tareas'),
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Reuiniones'),
              onTap: () {
                setState(() => _currentIndex = 3);
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Personal'),
              onTap: () {
                setState(() => _currentIndex = 4);
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_page),
              title: const Text('contactos'),
              onTap: () {
                setState(() => _currentIndex = 5);
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              onTap: () {
                setState(() => _currentIndex = 6);
                Navigator.pop(context); // Cierra el drawer
              },
            ),
          ],
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 10),
        child: GNav(
          color: colors[_currentIndex],
          tabBackgroundColor: colors[_currentIndex],
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
              icon: Icons.message,
              text: 'Mensajes',
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
          ],
        ),
      ),
    );
  }
}