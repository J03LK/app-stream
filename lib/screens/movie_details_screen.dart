import 'package:app_stream/screens/favorites_manager.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/pelicula.dart';

class MovieDetailScreen extends StatefulWidget {
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Pelicula pelicula;
  late bool isFavorite;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    pelicula = Pelicula(
      titulo: args['titulo']!,
      descripcion: args['descripcion']!,
      imagen: args['imagen']!,
      trailer: args['trailer']!,
      categoria: '', // si tienes categoría, asigna aquí
    );

    isFavorite = FavoritesManager().isFavorite(pelicula);
  }

  void toggleFavorite() {
    setState(() {
      if (isFavorite) {
        FavoritesManager().removeFavorite(pelicula);
        isFavorite = false;
      } else {
        FavoritesManager().addFavorite(pelicula);
        isFavorite = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de la Película"),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    pelicula.imagen.isNotEmpty
                        ? Image.network(pelicula.imagen, height: 250, fit: BoxFit.cover)
                        : Placeholder(fallbackHeight: 250),
                    IconButton(
                      icon: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                      onPressed: () => _showTrailerDialog(context, pelicula.trailer),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  pelicula.titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  pelicula.descripcion,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/player'),
                  child: Text("Ver Ahora"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTrailerDialog(BuildContext context, String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    late YoutubePlayerController controller;

    controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          insetPadding: EdgeInsets.all(16),
          child: Container(
            width: screenWidth * 0.9,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                onEnded: (metaData) {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
