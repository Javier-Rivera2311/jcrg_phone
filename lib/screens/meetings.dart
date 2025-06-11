import 'package:flutter/material.dart';
import 'package:jcrg_phone/widgets/formularyMeet.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(60.0), // Altura estándar del AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(
                20.0), // Bordes redondeados en la esquina inferior izquierda
            bottomRight: Radius.circular(
                20.0), // Bordes redondeados en la esquina inferior derecha
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1565C0), // Azul más oscuro
                  Color(0xFF64B5F6), // Azul intermedio
                  Color(0xFFBBDEFB), // Azul claro
                ],
              ),
            ),
            child: AppBar(
              title: const Text(
                'Reuniones',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors
                  .transparent, // Fondo transparente para mostrar el degradado
              elevation: 0, // Sin sombra
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido a la lista de reuniones!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularyMeet()),
          );
          if (result == true) {
            // Aquí puedes refrescar la lista de reuniones si implementas el fetch
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
}
