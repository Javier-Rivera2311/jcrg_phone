import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  
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
                  Color(0xFF0D47A1), // Azul profundo
                  Color(0xFF2196F3), // Azul estándar
                  Color(0xFF64B5F6), // Azul intermedio
                ],
              ),
            ),
            child: AppBar(
              title: const Text(
                'Mensajes',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Fondo transparente para mostrar el degradado
              elevation: 0, // Sin sombra
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido a los mensajes!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}