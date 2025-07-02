import 'package:flutter/material.dart';
import 'package:jcrg_phone/services/email_memory_service.dart';

class EmailDebugWidget extends StatelessWidget {
  const EmailDebugWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: EmailMemoryService.getEmailInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final info = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email Memory Debug Info'),
                Text('Has Email: ${info['hasEmail']}'),
                Text('Email: ${info['email'] ?? 'N/A'}'),
                Text('Timestamp: ${info['timestamp']}'),
                if (info['error'] != null) Text('Error: ${info['error']}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await EmailMemoryService.clearLastEmail();
                    // Refresh widget
                  },
                  child: const Text('Clear Email'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
