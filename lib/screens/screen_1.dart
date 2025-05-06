import 'package:flutter/material.dart';

class Screen1 extends StatelessWidget {
  const Screen1({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 1'),
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a Screen 1!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}