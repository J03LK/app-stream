import '../models/pelicula.dart';

List<Pelicula> obtenerPeliculas() {
  return [
    Pelicula(
      titulo: "Winnie the Pooh: Sangre y Miel",
      descripcion: "Terror moderno con personajes infantiles.",
      imagen: "assets/images/winnie.jpg",
      categoria: "Terror",
    ),
    Pelicula(
      titulo: "Titanic",
      descripcion: "Romance épico en el barco hundido.",
      imagen: "assets/images/titanic.jpg",
      categoria: "Romance",
    ),
    Pelicula(
      titulo: "Jurassic World",
      descripcion: "Aventura con dinosaurios clonados.",
      imagen: "assets/images/jurassic.jpg",
      categoria: "Aventura",
    ),
    Pelicula(
      titulo: "Rápidos y Furiosos",
      descripcion: "Carreras ilegales y acción sin frenos.",
      imagen: "assets/images/rapidos.jpg",
      categoria: "Acción",
    ),
    Pelicula(
      titulo: "Mi Villano Favorito",
      descripcion: "Villano gracioso con su ejército de minions.",
      imagen: "assets/images/minions.jpg",
      categoria: "Infantiles",
    ),
    Pelicula(
      titulo: "¿Qué pasó ayer?",
      descripcion: "Una boda, una resaca y muchas risas.",
      imagen: "assets/images/que_paso.jpg",
      categoria: "Comedia",
    ),
  ];
}
