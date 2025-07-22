import 'package:flutter/material.dart';

class WorkerSelectorDialog extends StatefulWidget {
  final List<String> workers;
  final List<String> selectedWorkers;

  const WorkerSelectorDialog({
    super.key,
    required this.workers,
    required this.selectedWorkers,
  });

  @override
  State<WorkerSelectorDialog> createState() => _WorkerSelectorDialogState();
}

class _WorkerSelectorDialogState extends State<WorkerSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredWorkers = [];
  List<String> _tempSelectedWorkers = [];

  @override
  void initState() {
    super.initState();
    _filteredWorkers = widget.workers;
    _tempSelectedWorkers = List.from(widget.selectedWorkers);
  }

  void _filterWorkers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWorkers = widget.workers.where((worker) {
        return worker.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Seleccionar Trabajadores',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar trabajadores...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _filterWorkers(),
              ),
            ),

            // Workers list
            Expanded(
              child: ListView.builder(
                itemCount: _filteredWorkers.length,
                itemBuilder: (context, index) {
                  final worker = _filteredWorkers[index];
                  final isSelected = _tempSelectedWorkers.contains(worker);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        worker.isNotEmpty ? worker[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(worker),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _tempSelectedWorkers.add(worker);
                          } else {
                            _tempSelectedWorkers.remove(worker);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('${_tempSelectedWorkers.length} seleccionados'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, _tempSelectedWorkers),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
