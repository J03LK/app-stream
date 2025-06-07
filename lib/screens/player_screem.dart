import 'package:flutter/material.dart';

class PlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reproduciendo...")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ondemand_video, size: 100),
            SizedBox(height: 20),
            Text("Aquí va el reproductor de video"),
          ],
        ),
      ),
    );
  }
}
