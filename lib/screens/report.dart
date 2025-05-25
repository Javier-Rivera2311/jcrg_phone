import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reportar Problema',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Aquí puedes reportar un problema.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}