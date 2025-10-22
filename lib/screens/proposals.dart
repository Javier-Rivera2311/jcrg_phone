import 'package:flutter/material.dart';
import '../widgets/proposals_participating.dart';
import '../widgets/proposals_preparing.dart';
import '../widgets/proposals_quotes.dart';
import '../widgets/proposals_history.dart';

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({super.key});

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

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
                'Propuestas',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determinar si es pantalla grande
          final isLargeScreen = constraints.maxWidth > 800;
          final isMediumScreen = constraints.maxWidth > 600;

          // Configurar padding según el tamaño de pantalla
          final horizontalPadding = isLargeScreen
              ? constraints.maxWidth * 0.25
              : isMediumScreen
                  ? constraints.maxWidth * 0.15
                  : 24.0;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Título descriptivo
                      Text(
                        'Gestión de Propuestas',
                        style: TextStyle(
                          fontSize: isLargeScreen
                              ? 32
                              : isMediumScreen
                                  ? 30
                                  : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isLargeScreen ? 20 : 16),
                      Text(
                        'Selecciona una opción para gestionar tus propuestas comerciales',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: isLargeScreen
                              ? 80
                              : isMediumScreen
                                  ? 70
                                  : 60),

                      // Botones de navegación verticales
                      _buildProposalButton(
                        'Participando',
                        Icons.groups,
                        Colors.blue,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProposalsParticipatingWidget(),
                            )),
                        isLargeScreen: isLargeScreen,
                      ),
                      const SizedBox(height: 20),
                      _buildProposalButton(
                        'Preparando',
                        Icons.build,
                        Colors.orange,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProposalsPreparingWidget(),
                            )),
                        isLargeScreen: isLargeScreen,
                      ),
                      const SizedBox(height: 20),
                      _buildProposalButton(
                        'Cotizaciones Enviadas',
                        Icons.send,
                        Colors.green,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProposalsQuotesWidget(),
                            )),
                        isLargeScreen: isLargeScreen,
                      ),
                      const SizedBox(height: 20),
                      _buildProposalButton(
                        'Historial',
                        Icons.history,
                        Colors.purple,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProposalsHistoryWidget(),
                            )),
                        isLargeScreen: isLargeScreen,
                      ),

                      SizedBox(
                          height: isLargeScreen
                              ? 80
                              : isMediumScreen
                                  ? 70
                                  : 60),

                      // Texto informativo responsivo
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isLargeScreen ? 600 : double.infinity,
                        ),
                        padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: isLargeScreen ? 28 : 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cada sección te permite gestionar propuestas en diferentes etapas del proceso comercial.',
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 16 : 14,
                                  color: Colors.blue,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProposalButton(
      String label, IconData icon, Color color, VoidCallback onPressed,
      {bool isLargeScreen = false}) {
    return SizedBox(
      width: double.infinity,
      height: isLargeScreen ? 80 : 70,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isLargeScreen ? 32 : 28),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isLargeScreen ? 22 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
