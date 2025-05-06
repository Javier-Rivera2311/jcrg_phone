import 'package:flutter/material.dart';

class Screen5 extends StatelessWidget {
  const Screen5({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 5'),
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a Screen 5!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}