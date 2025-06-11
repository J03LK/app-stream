import '../models/pelicula.dart';

List<Pelicula> obtenerPeliculas() {
  return [
    Pelicula(
      titulo: "Winnie the Pooh: Sangre y Miel",
      descripcion: "Terror moderno con personajes infantiles.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/337368/posters/63a0e67a546cc.jpg",
      trailer: "https://www.youtube.com/watch?v=ZQXN_9eyPAI",
      categoria: "Terror",
    ),
    Pelicula(
      titulo: "Titanic",
      descripcion: "Romance épico en el barco hundido.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/231/posters/642d748b22859.jpg",
      trailer: "https://www.youtube.com/watch?v=FiRVcExwBVA",
      categoria: "Romance",
    ),
    Pelicula(
      titulo: "Jurassic World",
      descripcion: "Aventura con dinosaurios clonados.",
      imagen: "https://artworks.thetvdb.com/banners/movies/200/posters/200.jpg",
      trailer: "https://www.youtube.com/watch?v=1R3LTANp7hw",
      categoria: "Aventura",
    ),
    Pelicula(
      titulo: "Rápidos y Furiosos",
      descripcion: "Carreras ilegales y acción sin frenos.",
      imagen: "https://artworks.thetvdb.com/banners/movies/41146/posters/2395203.jpg",
      trailer: "https://www.youtube.com/watch?v=-oJHZre7XZY",
      categoria: "Acción",
    ),
    Pelicula(
      titulo: "Mi Villano Favorito",
      descripcion: "Villano gracioso con su ejército de minions.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/258/posters/641889a184485.jpg",
      trailer: "https://www.youtube.com/watch?v=zzCZ1W_CUoI",
      categoria: "Infantiles",
    ),
    Pelicula(
      titulo: "¿Qué pasó ayer?",
      descripcion: "Una boda, una resaca y muchas risas.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/1257/posters/605df8d29ff70.jpg",
      trailer: "https://www.youtube.com/watch?v=wnNgGp1KVWQ",
      categoria: "Comedia",
    ),
  ];
}
