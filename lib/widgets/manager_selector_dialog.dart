import 'package:flutter/material.dart';

class ManagerSelectorDialog extends StatefulWidget {
  final List<String> workers;
  final String? selectedManager;

  const ManagerSelectorDialog({
    super.key,
    required this.workers,
    this.selectedManager,
  });

  @override
  State<ManagerSelectorDialog> createState() => _ManagerSelectorDialogState();
}

class _ManagerSelectorDialogState extends State<ManagerSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredWorkers = [];
  String? _tempSelectedManager;

  @override
  void initState() {
    super.initState();
    _filteredWorkers = widget.workers;
    _tempSelectedManager = widget.selectedManager;
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
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Seleccionar Encargado en la Oficina',
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
                  hintText: 'Buscar encargado en la oficina...',
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
                  final isSelected = _tempSelectedManager == worker;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        worker.isNotEmpty ? worker[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(worker),
                    trailing: Radio<String>(
                      value: worker,
                      groupValue: _tempSelectedManager,
                      onChanged: (value) {
                        setState(() {
                          _tempSelectedManager = value;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _tempSelectedManager = worker;
                      });
                    },
                  );
                },
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(_tempSelectedManager != null
                      ? 'Encargado en la oficina seleccionado: $_tempSelectedManager'
                      : 'Ningún encargado en la oficina seleccionado'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, _tempSelectedManager),
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
