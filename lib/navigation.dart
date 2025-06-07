import 'package:app_stream/screens/home_screen.dart';
import 'package:app_stream/screens/login_screen.dart';
import 'package:app_stream/screens/movie_details_screen.dart';
import 'package:app_stream/screens/player_screem.dart';
import 'package:app_stream/screens/register_screen.dart';
import 'package:app_stream/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => WelcomeScreen(),
  '/login': (context) => LoginScreen(),
  '/register': (context) => RegisterScreen(),
  '/home': (context) => HomeScreen(),
  '/detail': (context) => MovieDetailScreen(),
  '/player': (context) => PlayerScreen(),
};
