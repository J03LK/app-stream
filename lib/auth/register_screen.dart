import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final redColor = Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text("Registro"),
        backgroundColor: redColor,
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              size: 100,
              color: redColor,
            ),
            SizedBox(height: 30),
            TextField(
              controller: userController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nombre de Usuario",
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.person, color: redColor),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Correo",
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.email, color: redColor),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Contraseña",
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.lock, color: redColor),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Registrar",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
