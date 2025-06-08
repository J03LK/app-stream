import 'package:flutter/material.dart';

class MovieDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(title: Text(args["titulo"]!)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            args["imagen"]!.isEmpty
                ? Placeholder(fallbackHeight: 200)
                : Image.network(args["imagen"]!),
            SizedBox(height: 20),
            Text(args["descripcion"]!),
          ],
        ),
      ),
    );
  }
}
