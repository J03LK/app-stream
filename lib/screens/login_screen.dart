import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar Sesión")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Correo")),
            TextField(controller: passController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Entrar"),
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
          ],
        ),
      ),
    );
  }
}
