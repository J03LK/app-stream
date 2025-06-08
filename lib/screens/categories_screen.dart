import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  final List<String> categorias = [
    "Terror",
    "Romance",
    "Aventura",
    "Acción",
    "Infantiles",
    "Comedia",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Categorías de Películas")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home', arguments: null);
              },
              child: Text("Ver Todas las Películas"),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: categorias.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final categoria = categorias[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/home',
                        arguments: categoria,
                      );
                    },
                    child: Card(
                      color: Colors.redAccent,
                      child: Center(
                        child: Text(
                          categoria,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
