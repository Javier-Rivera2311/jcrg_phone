import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenProject extends StatelessWidget {
  final String windowsPath;
  final IconData? icon;
  final String? tooltip;

  const OpenProject({
    super.key,
    required this.windowsPath,
    this.icon = Icons.folder_open,
    this.tooltip = 'Abrir carpeta',
  });

  /// Convierte una ruta de Windows a formato SMB para macOS/móviles.
  String convertNetworkPath(String windowsPath) {
    if (windowsPath.isEmpty) return windowsPath;

    // Elimina los dobles backslash iniciales y normaliza los separadores
    String path = windowsPath.replaceFirst(RegExp(r'^\\\\'), '');
    List<String> parts = path.split('\\');
    if (parts.length < 2) return windowsPath; // fallback si la ruta es rara

    String host = parts[0];
    String share = parts[1];
    String rest = parts.length > 2 ? parts.sublist(2).join('/') : '';

    if (Platform.isWindows) {
      return windowsPath;
    } else {
      String smbPath = 'smb://$host/$share';
      if (rest.isNotEmpty) smbPath += '/$rest';
      return smbPath;
    }
  }

  Future<void> openNetworkFolder(BuildContext context) async {
    final convertedPath = convertNetworkPath(windowsPath);

    try {
      Uri? uri;

      if (Platform.isWindows) {
        // Si es ruta UNC de red, usa file://servidor/carpeta (sin slash extra)
        if (windowsPath.startsWith(r'\\')) {
          // Quita los backslash iniciales y reemplaza \ por /
          final uncPath = windowsPath.replaceFirst(RegExp(r'^\\\\'), '');
          // file://servidor/carpeta
          uri = Uri.parse('file:///${uncPath.replaceAll(r"\", "/")}');
        } else {
          // Ruta local
          uri = Uri.file(windowsPath);
        }

        // Solución alternativa: usar 'explorer' para abrir la carpeta si launchUrl falla
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Intenta abrir con explorer.exe si launchUrl falla
          try {
            final pathToOpen = windowsPath.replaceAll('/', r'\');
            await Process.run('explorer', [pathToOpen]);
          } catch (e) {
            _showErrorSnackBar(context,
                'No se pudo abrir la carpeta con explorer.exe.\nError: $e\nRuta: $windowsPath');
          }
        }
      } else if (Platform.isMacOS) {
        uri = Uri.parse(convertedPath);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showErrorSnackBar(context,
              'No se pudo abrir la carpeta.\nVerifica que la ruta sea accesible desde este equipo.\nRuta: ${uri?.toString() ?? convertedPath}');
        }
      } else {
        // Móviles: solo mostrar la ruta
        _showMobileDialog(context, convertedPath);
      }
    } catch (e) {
      _showErrorSnackBar(
          context, 'Error al abrir la carpeta: $e\nRuta: $windowsPath');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showMobileDialog(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ruta del servidor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'No es posible abrir la carpeta desde este dispositivo.'),
            const SizedBox(height: 10),
            const Text('Ruta:'),
            SelectableText(
              path,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Platform.isWindows || Platform.isMacOS;

    return IconButton(
      icon: Icon(
        icon,
        color: isDesktop ? Colors.blue : Colors.grey,
      ),
      tooltip: tooltip,
      onPressed:
          windowsPath.isNotEmpty ? () => openNetworkFolder(context) : null,
    );
  }
}
