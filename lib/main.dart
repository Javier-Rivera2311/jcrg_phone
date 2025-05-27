import 'package:flutter/material.dart';
import 'package:jcrg_phone/screens/navigate.dart';
import 'package:jcrg_phone/log/login.dart';
import 'package:jcrg_phone/log/register.dart';
import 'package:jcrg_phone/screens/task.dart';
import 'package:jcrg_phone/screens/contact.dart';
import 'package:jcrg_phone/screens/meetings.dart';
import 'package:jcrg_phone/screens/workers.dart';
import 'package:jcrg_phone/screens/notifications.dart';
import 'package:jcrg_phone/screens/messages.dart';
import 'package:jcrg_phone/screens/home.dart';
import 'package:jcrg_phone/screens/report.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class LoginChecker extends StatelessWidget {
  const LoginChecker({super.key});

  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn ? '/home' : '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(snapshot.data!);
        });
        return const SizedBox.shrink();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/checkLogin',
      routes: {
        '/checkLogin': (context) => const LoginChecker(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
        '/tasks': (context) => const TaskScreen(),
        '/contacts': (context) => const ContactScreen(),
        '/meetings': (context) => const MeetingScreen(),
        '/workers': (context) => const WorkerScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/report': (context) => const ReportScreen(),

      },
    );
  }
}
