import 'package:flutter/material.dart';

class Screen6 extends StatelessWidget {
  const Screen6({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 6'),
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a Screen 6!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}