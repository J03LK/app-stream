import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: userController, decoration: InputDecoration(labelText: "Nombre de Usuario")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Correo")),
            TextField(controller: passController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Registrar"),
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
          ],
        ),
      ),
    );
  }
}
