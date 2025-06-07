import 'package:flutter/material.dart';
import 'navigation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamzy',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
