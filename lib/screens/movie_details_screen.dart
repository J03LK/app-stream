import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String titulo = args['titulo']!;
    final String descripcion = args['descripcion']!;
    final String imagen = args['imagen']!;
    final String trailerUrl = args['trailer']!;

    return Scaffold(
      appBar: AppBar(title: Text("Detalle de la Película")),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    imagen.isNotEmpty
                        ? Image.asset(imagen, height: 250, fit: BoxFit.cover)
                        : Placeholder(fallbackHeight: 250),
                    IconButton(
                      icon: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                      onPressed: () => _showTrailerDialog(context, trailerUrl),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  descripcion,
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
