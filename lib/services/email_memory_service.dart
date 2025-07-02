import 'package:shared_preferences/shared_preferences.dart';

class EmailMemoryService {
  static const String _lastEmailKey = 'lastEmail';

  /// Cargar el último correo guardado del dispositivo
  /// Retorna null si no hay correo guardado
  static Future<String?> getLastEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastEmail = prefs.getString(_lastEmailKey);

      if (lastEmail != null && lastEmail.isNotEmpty) {
        print('EmailMemoryService: Último correo cargado: $lastEmail');
        return lastEmail;
      }

      print('EmailMemoryService: No hay correo guardado');
      return null;
    } catch (error) {
      print('EmailMemoryService: Error cargando último correo: $error');
      return null;
    }
  }

  /// Guardar el correo en el dispositivo
  /// Solo se debe llamar cuando el login sea exitoso
  static Future<bool> saveLastEmail(String email) async {
    try {
      if (email.trim().isEmpty) {
        print('EmailMemoryService: No se puede guardar un correo vacío');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_lastEmailKey, email.trim());

      if (success) {
        print('EmailMemoryService: Correo guardado exitosamente: $email');
      } else {
        print('EmailMemoryService: Error guardando correo');
      }

      return success;
    } catch (error) {
      print('EmailMemoryService: Error guardando correo: $error');
      return false;
    }
  }

  /// Eliminar el correo guardado del dispositivo
  static Future<bool> clearLastEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_lastEmailKey);

      if (success) {
        print('EmailMemoryService: Correo eliminado exitosamente');
      } else {
        print('EmailMemoryService: Error eliminando correo');
      }

      return success;
    } catch (error) {
      print('EmailMemoryService: Error eliminando correo: $error');
      return false;
    }
  }

  /// Verificar si hay un correo guardado
  static Future<bool> hasLastEmail() async {
    try {
      final lastEmail = await getLastEmail();
      return lastEmail != null && lastEmail.isNotEmpty;
    } catch (error) {
      print('EmailMemoryService: Error verificando correo: $error');
      return false;
    }
  }

  /// Obtener información del correo guardado (para debugging)
  static Future<Map<String, dynamic>> getEmailInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_lastEmailKey);

      return {
        'hasEmail': email != null && email.isNotEmpty,
        'email': email,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (error) {
      return {
        'hasEmail': false,
        'email': null,
        'error': error.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
