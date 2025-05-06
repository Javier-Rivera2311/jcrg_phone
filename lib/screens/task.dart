import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas'),
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a la lista de tareas!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}