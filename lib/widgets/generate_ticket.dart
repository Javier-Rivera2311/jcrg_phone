import 'package:flutter/material.dart';

class GenerateTicketView extends StatelessWidget {
  const GenerateTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Ticket'),
      ),
      body: const Center(
        child: Text(
          'Aquí puedes generar un ticket.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
