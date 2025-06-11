import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import '../data/peliculas_data.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Pelicula> _todasLasPeliculas = [];
  List<Pelicula> _peliculasFiltradas = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _todasLasPeliculas = obtenerPeliculas();
    _peliculasFiltradas = [];
  }

  void _filtrarPeliculas(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _peliculasFiltradas = [];
      } else {
        _peliculasFiltradas = _todasLasPeliculas.where((pelicula) {
          return pelicula.titulo.toLowerCase().contains(query.toLowerCase()) ||
              pelicula.descripcion.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              pelicula.categoria.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buscar Películas"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Quita la flecha de regreso
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Buscar por título, descripción o categoría...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.redAccent),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            _searchController.clear();
                            _filtrarPeliculas('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: _filtrarPeliculas,
              ),
            ),
          ),

          // Contenido principal
          Expanded(child: _buildContent()),
        ],
      ),
      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // Buscar está seleccionado
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/categories');
              break;
            case 1:
              // Ya estamos en búsqueda
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorías',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Películas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!_isSearching) {
      // Estado inicial - mostrar sugerencias o categorías populares
      return _buildInitialContent();
    } else if (_peliculasFiltradas.isEmpty) {
      // No se encontraron resultados
      return _buildNoResults();
    } else {
      // Mostrar resultados de búsqueda
      return _buildSearchResults();
    }
  }

  Widget _buildInitialContent() {
    final List<String> categoriasPopulares = [
      "Terror",
      "Acción",
      "Romance",
      "Comedia",
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y mensaje de bienvenida
          Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search, size: 60, color: Colors.redAccent),
                ),
                SizedBox(height: 16),
                Text(
                  "¿Qué quieres ver hoy?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Busca por título, descripción o categoría",
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          ),

          SizedBox(height: 32),

          // Categorías populares
          Text(
            "Categorías Populares",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categoriasPopulares.map((categoria) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = categoria;
                  _filtrarPeliculas(categoria);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    categoria,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text(
            "No se encontraron películas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Intenta con otros términos de búsqueda",
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _peliculasFiltradas.length,
      itemBuilder: (context, index) {
        final pelicula = _peliculasFiltradas[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  pelicula.imagen,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: Icon(
                        Icons.movie,
                        color: Colors.grey[600],
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            title: Text(
              pelicula.titulo,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pelicula.descripcion,
                    style: TextStyle(color: Colors.grey[300], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      pelicula.categoria,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Icon(
              Icons.play_circle_outline,
              color: Colors.redAccent,
              size: 28,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: {
                  'titulo': pelicula.titulo,
                  'descripcion': pelicula.descripcion,
                  'imagen': pelicula.imagen,
                  'trailer': pelicula.trailer,
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
