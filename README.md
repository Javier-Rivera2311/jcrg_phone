# 📱 JCRG

**JCRG** es una aplicación móvil multiplataforma desarrollada con **Flutter**, diseñada para la gestión interna de la empresa **JCRG Ingeniería**.  
Centraliza la administración de proyectos, tareas, contactos, reuniones y personal, optimizando la comunicación y la productividad del equipo.

---

## 🚀 Características Principales

- **📱 Multiplataforma:** Compilada para Android, iOS, Windows, macOS, Linux y Web desde una única base de código.  
- **🔐 Autenticación de Usuarios:** Sistema seguro de inicio de sesión, registro y cambio de contraseña.  
- **🏠 Panel de Inicio (Home):** Acceso rápido a las funcionalidades principales de la aplicación.  
- **📋 Gestión de Tareas:** Asignación y seguimiento de tareas por proyecto y categoría.  
- **👥 Gestión de Contactos:** Directorio de contactos internos y externos con información detallada.  
- **📂 Gestión de Proyectos:** Creación, edición y seguimiento del estado de los proyectos de la empresa.  
- **📅 Planificación de Reuniones:** Programación de reuniones virtuales y presenciales.  
- **👨‍💼 Directorio de Personal:** Lista de empleados con su información de contacto.  
- **🎫 Sistema de Tickets:** Módulo para reportar y dar seguimiento a problemas o solicitudes.  
- **🔔 Notificaciones Push:** Integración con Firebase para el envío de notificaciones en tiempo real.  
- **🌐 Conectividad con Backend:** Comunicación con un backend desarrollado en **Node.js** y desplegado en **Render** para la gestión de datos.

---

## 🧩 Primeros Pasos

Sigue los pasos a continuación para ejecutar este proyecto en tu entorno local.

### ✅ Prerrequisitos

- Tener instalado [Flutter](https://flutter.dev/docs/get-started/install) en tu máquina.  
- Un editor de código como [VS Code](https://code.visualstudio.com/) o [Android Studio](https://developer.android.com/studio).  
- Tener configurado un emulador de Android, un simulador de iOS o un dispositivo físico.

---

## ⚙️ Instalación


# 1. Clona el repositorio
```bash
git clone https://github.com/javier-rivera2311/jcrg_phone.git
```
# 2. Navega al directorio del proyecto
```bash
cd jcrg_phone
```
# 3. Instala las dependencias
```bash
flutter pub get
```

##▶️ Ejecución de la Aplicación
# 1. Abre el proyecto en tu editor preferido
# 2. Asegúrate de tener un dispositivo o emulador en ejecución
# 3. Ejecuta la aplicación
```bash
flutter run
```

## 📦 Dependencias Clave

| Paquete                               | Descripción                                          |
| ------------------------------------- | ---------------------------------------------------- |
| `flutter`                             | Framework principal para la interfaz de usuario      |
| `http`                                | Peticiones HTTP al backend                           |
| `shared_preferences`                  | Almacenamiento local (token de sesión, preferencias) |
| `url_launcher`                        | Apertura de URLs externas                            |
| `firebase_core`, `firebase_messaging` | Integración con Firebase y notificaciones push       |
| `google_nav_bar`                      | Barra de navegación inferior moderna                 |
| `flutter_launcher_icons`, `msix`      | Configuración de íconos e instaladores para Windows  |

## ☁️ Despliegue

# Compilación para Android
flutter build apk --release

# Compilación para Web
flutter build web

# Compilaciones de escritorio
flutter build windows
flutter build macos
flutter build linux

## 🏗️ Backend Asociado
El backend de esta aplicación está desarrollado en Node.js + Express + MySQL,
con soporte para notificaciones push mediante Firebase Cloud Messaging (FCM).

📦 Repositorio del backend:
👉 https://github.com/javier-rivera2311/jcrg_backend

## 🧠 Autor
**Desarrollado por Javier Rivera**

📧 javierrivera2311@gmail.com
💼 Proyecto interno de JCRG Ingeniería

## 📜 Licencia

Este proyecto está licenciado bajo la MIT License.
Consulta el archivo LICENSE para más detalles.



