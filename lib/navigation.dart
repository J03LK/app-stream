import 'package:app_stream/screens/favorites_screen.dart';
import 'package:app_stream/screens/home_screen.dart';
import 'package:app_stream/auth/login_screen.dart';
import 'package:app_stream/screens/movie_details_screen.dart';
import 'package:app_stream/screens/player_screem.dart';
import 'package:app_stream/auth/register_screen.dart';
import 'package:app_stream/screens/welcome_screen.dart';
import 'package:app_stream/screens/categories_screen.dart';
import 'package:app_stream/screens/profile_screen.dart';
import 'package:app_stream/screens/search_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => WelcomeScreen(),
  '/login': (context) => LoginScreen(),
  '/register': (context) => RegisterScreen(),
  '/home': (context) => HomeScreen(),
  '/detail': (context) => MovieDetailScreen(),
  '/player': (context) => PlayerScreen(),
  '/categories': (context) => CategoriesScreen(),
  '/profile': (context) => ProfileScreen(),
  '/search': (context) => SearchScreen(),
  '/favorites': (context) => FavoritesScreen(), 
};