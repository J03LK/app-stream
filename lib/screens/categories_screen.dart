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
    final redColor = Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text("Categorías de Películas"),
        backgroundColor: redColor,
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/home', arguments: null);
                },
                child: Text(
                  "Ver Todas las Películas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: categorias.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 3 / 2,
                ),
                itemBuilder: (context, index) {
                  final categoria = categorias[index];
                  return Material(
                    color: redColor,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/home',
                          arguments: categoria,
                        );
                      },
                      child: Center(
                        child: Text(
                          categoria,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
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
