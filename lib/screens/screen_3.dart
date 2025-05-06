import 'package:flutter/material.dart';

class Screen3 extends StatelessWidget {
  const Screen3({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 3'),
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a Screen 3!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}