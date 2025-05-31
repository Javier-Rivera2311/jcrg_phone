import 'package:flutter/material.dart';

class CheckTicketView extends StatelessWidget {
  const CheckTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Ticket'),
      ),
      body: const Center(
        child: Text(
          'Aquí puedes verificar un ticket.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
