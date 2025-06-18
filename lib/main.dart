import 'package:flutter/material.dart';
import 'navigation.dart';
import 'splash_screen.dart'; // Importa tu splash screen

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamzy',
      theme: ThemeData.dark(),
      // Cambia la ruta inicial al splash screen
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        // Mantén todas tus rutas existentes
        ...appRoutes,
      },
      debugShowCheckedModeBanner: false,
    );
  }
}