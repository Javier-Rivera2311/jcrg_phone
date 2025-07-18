import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  final void Function(int)? onNavigate;
  const Home({super.key, this.onNavigate});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  Future<void> _initializeHome() async {
    // Verificar token primero
    final isValidToken = await _validateToken();

    if (!isValidToken) {
      // Redirigir al login si el token no es válido
      _redirectToLogin();
      return;
    }

    // Si el token es válido, cargar datos del usuario
    await _loadUserName();

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _validateToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Si no hay token, redirigir al login
      if (token == null || token.isEmpty) {
        print('No hay token guardado');
        return false;
      }

      // Verificar si el token ha expirado
      if (_isTokenExpired(token)) {
        print('Token expirado');
        await _clearUserData(); // Limpiar datos del usuario
        return false;
      }

      print('Token válido');
      return true;
    } catch (error) {
      print('Error validando token: $error');
      return false;
    }
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      // Normalizar el padding de base64
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      final exp = payloadMap['exp'];
      if (exp != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final now = DateTime.now();

        print('Token expira: $expiryDate');
        print('Hora actual: $now');

        return now.isAfter(expiryDate);
      }

      return true;
    } catch (error) {
      print('Error decodificando token: $error');
      return true;
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');
    await prefs.remove('userId');
    // Agregar otros datos que quieras limpiar
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
        // O si usas rutas con nombres diferentes:
        // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras se valida el token
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando sesión...'),
            ],
          ),
        ),
      );
    }

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
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                // Agregar botón de logout opcional
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _showLogoutDialog,
                ),
              ],
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
                      _buildButton(Icons.task, 'Tareas', Color(0xFF2196F3),
                          buttonWidth, 1),
                      _buildButton(Icons.contact_page, 'Contactos',
                          Color(0xFF1E88E5), buttonWidth, 2),
                      _buildButton(Icons.meeting_room, 'Reuniones',
                          Color(0xFF1565C0), buttonWidth, 6),
                      _buildButton(Icons.work, 'Proyecto',
                          Color.fromARGB(255, 116, 169, 255), buttonWidth, 3),
                      _buildButton(Icons.people, 'Personal', Color(0xFF2962FF),
                          buttonWidth, 4),
                      _buildButton(Icons.notifications, 'Notificaciones',
                          Color(0xFF1976D2), buttonWidth, 5),
                    ],
                  );
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onNavigate?.call(7);
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

  Widget _buildButton(
      IconData icon, String label, Color color, double width, int tabIndex) {
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _clearUserData();
              Navigator.pop(context);
              _redirectToLogin();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
