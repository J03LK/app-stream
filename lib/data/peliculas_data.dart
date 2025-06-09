import '../models/pelicula.dart';

List<Pelicula> obtenerPeliculas() {
  return [
    Pelicula(
      titulo: "Winnie the Pooh: Sangre y Miel",
      descripcion: "Terror moderno con personajes infantiles.",
      imagen: "assets/images/winnie.jpg",
      trailer: "https://www.youtube.com/watch?v=ZQXN_9eyPAI",
      categoria: "Terror",
    ),
    Pelicula(
      titulo: "Titanic",
      descripcion: "Romance épico en el barco hundido.",
      imagen: "assets/images/titanic.jpg",
      trailer: "https://www.youtube.com/watch?v=FiRVcExwBVA",
      categoria: "Romance",
    ),
    Pelicula(
      titulo: "Jurassic World",
      descripcion: "Aventura con dinosaurios clonados.",
      imagen: "assets/images/jurassic.jpg",
      trailer: "https://www.youtube.com/watch?v=1R3LTANp7hw",
      categoria: "Aventura",
    ),
    Pelicula(
      titulo: "Rápidos y Furiosos",
      descripcion: "Carreras ilegales y acción sin frenos.",
      imagen: "assets/images/rapidos.jpg",
      trailer: "https://www.youtube.com/watch?v=-oJHZre7XZY",
      categoria: "Acción",
    ),
    Pelicula(
      titulo: "Mi Villano Favorito",
      descripcion: "Villano gracioso con su ejército de minions.",
      imagen: "assets/images/minions.jpg",
      trailer: "https://www.youtube.com/watch?v=zzCZ1W_CUoI",
      categoria: "Infantiles",
    ),
    Pelicula(
      titulo: "¿Qué pasó ayer?",
      descripcion: "Una boda, una resaca y muchas risas.",
      imagen: "assets/images/que_paso.jpg",
      trailer: "https://www.youtube.com/watch?v=wnNgGp1KVWQ",
      categoria: "Comedia",
    ),
  ];
}
