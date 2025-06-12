import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Pelicula {
  final String titulo;
  final String descripcion;
  final String imagen;
  final String categoria;
  final String trailer;

  Pelicula({
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.categoria,
    required this.trailer,
  });
}

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Pelicula pelicula;
  bool isFavorite = false;
  late DatabaseReference _favoritesRef;
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _favoritesRef = FirebaseDatabase.instance.ref('usuarios_favoritos');
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Pelicula;
    pelicula = args;
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    if (_currentUser == null) return;

    final snapshot = await _favoritesRef
        .child(_currentUser!.uid)
        .child(_sanitizeKey(pelicula.titulo))
        .get();

    if (mounted) {
      setState(() {
        isFavorite = snapshot.exists;
      });
    }
  }

  String _sanitizeKey(String key) {
    return key
        .replaceAll('.', '_')
        .replaceAll('#', '_')
        .replaceAll('\$', '_')
        .replaceAll('[', '_')
        .replaceAll(']', '_')
        .replaceAll('/', '_');
  }

  Future<void> _toggleFavorite() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para guardar favoritos'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      final userFavoritesRef = _favoritesRef.child(_currentUser!.uid);
      final movieKey = _sanitizeKey(pelicula.titulo);

      if (isFavorite) {
        await userFavoritesRef.child(movieKey).set({
          'titulo': pelicula.titulo,
          'descripcion': pelicula.descripcion,
          'imagen': pelicula.imagen,
          'trailer': pelicula.trailer,
          'categoria': pelicula.categoria,
          'fecha_guardado': ServerValue.timestamp,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${pelicula.titulo}" agregada a favoritos'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        await userFavoritesRef.child(movieKey).remove();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${pelicula.titulo}" removida de favoritos'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isFavorite = !isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pelicula.titulo),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
              size: 30,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(pelicula.imagen),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.play_circle_filled,
                    size: 64,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  onPressed: () =>
                      _showTrailerDialog(context, pelicula.trailer),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pelicula.titulo,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    pelicula.categoria,
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    pelicula.descripcion,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/player'),
                      child: Text(
                        'VER AHORA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrailerDialog(BuildContext context, String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId == null) return;

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: YoutubePlayer(
              controller: controller,
              aspectRatio: 16 / 9,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.redAccent,
              onEnded: (metaData) {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
