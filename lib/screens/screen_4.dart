import 'package:flutter/material.dart';

class Screen4 extends StatelessWidget {
  const Screen4({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 4'),
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a Screen 4!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}