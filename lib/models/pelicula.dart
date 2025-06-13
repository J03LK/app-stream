import 'package:flutter/material.dart'; // Agregar este import

class Pelicula {
  final String titulo;
  final String descripcion;
  final String imagen;
  final String categoria;
  final String trailer;
  final int edadMinima; // Requerido

  Pelicula({
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.categoria,
    required this.trailer,
    required this.edadMinima, // Requerido
  });

  // Método para verificar si una película es apropiada para cierta edad
  bool esApropiadaParaEdad(int edadUsuario) {
    return edadUsuario >= edadMinima;
  }

  // Obtener el texto de clasificación
  String get clasificacion {
    if (edadMinima <= 0) return 'ATP'; // Apta para todo público
    if (edadMinima <= 13) return '+$edadMinima';
    if (edadMinima <= 16) return '+$edadMinima';
    if (edadMinima <= 18) return '+$edadMinima';
    return '+$edadMinima';
  }

  // Obtener color según la clasificación
  Color get colorClasificacion {
    if (edadMinima <= 0) return Colors.green;
    if (edadMinima <= 13) return Colors.blue;
    if (edadMinima <= 16) return Colors.orange;
    return Colors.red;
  }
}