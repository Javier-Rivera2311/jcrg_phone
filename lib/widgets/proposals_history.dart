import 'package:flutter/material.dart';

class ProposalsHistoryWidget extends StatefulWidget {
  const ProposalsHistoryWidget({super.key});

  @override
  State<ProposalsHistoryWidget> createState() => _ProposalsHistoryWidgetState();
}

class _ProposalsHistoryWidgetState extends State<ProposalsHistoryWidget> {
  List<Map<String, dynamic>> historialPropuestas = [
    {
      'id': 'P001',
      'titulo': 'Propuesta Sistema CRM',
      'cliente': 'Empresa ABC',
      'estado': 'Cerrada - Ganada',
      'valor': '\$2.500.000',
      'fecha': '15/01/2024',
      'tipo': 'Participando',
      'color': Colors.green,
    },
    {
      'id': 'P002',
      'titulo': 'Desarrollo App Móvil',
      'cliente': 'TechStart SA',
      'estado': 'Cerrada - Perdida',
      'valor': '\$1.800.000',
      'fecha': '08/01/2024',
      'tipo': 'Preparando',
      'color': Colors.red,
    },
    {
      'id': 'P003',
      'titulo': 'Consultoría IT',
      'cliente': 'InnovaCorp',
      'estado': 'Cerrada - Ganada',
      'valor': '\$950.000',
      'fecha': '22/12/2023',
      'tipo': 'Cotizaciones Enviadas',
      'color': Colors.green,
    },
  ];

  String filtroEstado = 'Todos';
  String busqueda = '';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    List<Map<String, dynamic>> propuestasFiltradas =
        historialPropuestas.where((propuesta) {
      bool cumpleFiltro =
          filtroEstado == 'Todos' || propuesta['estado'].contains(filtroEstado);
      bool cumpleBusqueda = busqueda.isEmpty ||
          propuesta['titulo'].toLowerCase().contains(busqueda.toLowerCase()) ||
          propuesta['cliente'].toLowerCase().contains(busqueda.toLowerCase()) ||
          propuesta['id'].toLowerCase().contains(busqueda.toLowerCase());
      return cumpleFiltro && cumpleBusqueda;
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isWide ? 70 : 80),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 33, 150, 255),
                  Color.fromARGB(255, 100, 180, 255),
                  Color.fromARGB(255, 180, 220, 255),
                ],
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Historial de Propuestas',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home',
                    (route) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  onChanged: (value) {
                    setState(() {
                      busqueda = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar propuestas...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filtro por estado
                Row(
                  children: [
                    const Text('Filtrar: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: DropdownButton<String>(
                        value: filtroEstado,
                        isExpanded: true,
                        items:
                            ['Todos', 'Ganada', 'Perdida'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            filtroEstado = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de propuestas históricas
          Expanded(
            child: propuestasFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron propuestas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta cambiar los filtros de búsqueda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: propuestasFiltradas.length,
                    itemBuilder: (context, index) {
                      final propuesta = propuestasFiltradas[index];
                      return _buildHistoryCard(propuesta, isWide);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> propuesta, bool isWide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: propuesta['color'].withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con ID y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      propuesta['id'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: propuesta['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      propuesta['estado'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: propuesta['color'],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Título
              Text(
                propuesta['titulo'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Información en dos columnas o una según el ancho
              if (isWide)
                Row(
                  children: [
                    Expanded(child: _buildInfoColumn(propuesta)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildValueColumn(propuesta)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildInfoColumn(propuesta),
                    const SizedBox(height: 8),
                    _buildValueColumn(propuesta),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(Map<String, dynamic> propuesta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.business, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                propuesta['cliente'],
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.category, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                propuesta['tipo'],
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValueColumn(Map<String, dynamic> propuesta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money, size: 16, color: Colors.green),
            const SizedBox(width: 6),
            Text(
              propuesta['valor'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              propuesta['fecha'],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
