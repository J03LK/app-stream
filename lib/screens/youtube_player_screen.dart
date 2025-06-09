import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final String videoUrl;

  YouTubePlayerScreen({required this.videoUrl});

  @override
  _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  late String _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? '';
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlayerReady) {
      // Mostrar miniatura + botón play
      final thumbnailUrl = YoutubePlayer.getThumbnail(videoId: _videoId);
      return Scaffold(
        appBar: AppBar(title: Text("Tráiler")),
        body: Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _initializePlayer();
                _isPlayerReady = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(thumbnailUrl),
                Icon(Icons.play_circle_fill, size: 80, color: Colors.white70),
              ],
            ),
          ),
        ),
      );
    } else {
      // Mostrar el reproductor
      return Scaffold(
        appBar: AppBar(title: Text("Tráiler")),
        body: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
        ),
      );
    }
  }
}
