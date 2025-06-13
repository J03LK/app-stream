import '../models/pelicula.dart';

List<Pelicula> obtenerPeliculas() {
  return [
    Pelicula(
      titulo: "Winnie the Pooh: Sangre y Miel",
      descripcion: "Terror moderno con personajes infantiles.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/337368/posters/63a0e67a546cc.jpg",
      trailer: "https://www.youtube.com/watch?v=ZQXN_9eyPAI",
      categoria: "Terror",
      edadMinima: 18, // Solo para adultos - contenido violento y perturbador
    ),
    Pelicula(
      titulo: "Titanic",
      descripcion: "Romance épico en el barco hundido.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/231/posters/642d748b22859.jpg",
      trailer: "https://www.youtube.com/watch?v=FiRVcExwBVA",
      categoria: "Romance",
      edadMinima: 13, // Contenido romántico y algunas escenas dramáticas
    ),
    Pelicula(
      titulo: "Jurassic World",
      descripcion: "Aventura con dinosaurios clonados.",
      imagen: "https://artworks.thetvdb.com/banners/movies/200/posters/200.jpg",
      trailer: "https://www.youtube.com/watch?v=1R3LTANp7hw",
      categoria: "Aventura",
      edadMinima: 13, // Escenas de acción intensas y suspenso
    ),
    Pelicula(
      titulo: "Rápidos y Furiosos",
      descripcion: "Carreras ilegales y acción sin frenos.",
      imagen: "https://artworks.thetvdb.com/banners/movies/41146/posters/2395203.jpg",
      trailer: "https://www.youtube.com/watch?v=-oJHZre7XZY",
      categoria: "Acción",
      edadMinima: 16, // Violencia, persecuciones peligrosas y lenguaje
    ),
    Pelicula(
      titulo: "Mi Villano Favorito",
      descripcion: "Villano gracioso con su ejército de minions.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/258/posters/641889a184485.jpg",
      trailer: "https://www.youtube.com/watch?v=zzCZ1W_CUoI",
      categoria: "Infantiles",
      edadMinima: 0, // Apta para toda la familia
    ),
    Pelicula(
      titulo: "¿Qué pasó ayer?",
      descripcion: "Una boda, una resaca y muchas risas.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/1257/posters/605df8d29ff70.jpg",
      trailer: "https://www.youtube.com/watch?v=wnNgGp1KVWQ",
      categoria: "Comedia",
      edadMinima: 16, // Contenido para adultos, alcohol, humor sexual
    ),
    // Agregando más películas para mejor variedad
    Pelicula(
      titulo: "Frozen",
      descripcion: "Aventura musical de dos hermanas en un reino helado.",
      imagen: "https://m.media-amazon.com/images/M/MV5BMTQ1MjQwMTE5OF5BMl5BanBnXkFtZTgwNjk3MTcyMDE@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=TbQm5doF_Uc",
      categoria: "Infantiles",
      edadMinima: 0, // Para toda la familia
    ),
    Pelicula(
      titulo: "John Wick",
      descripcion: "Asesino retirado busca venganza por su perro.",
      imagen: "https://m.media-amazon.com/images/M/MV5BMTU2NjA1ODgzMF5BMl5BanBnXkFtZTgwMTM2MTI4MjE@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=C0BMx-qxsP4",
      categoria: "Acción",
      edadMinima: 18, // Violencia extrema y contenido gráfico
    ),
    Pelicula(
      titulo: "El Diario de la Princesa",
      descripcion: "Una adolescente descubre que es princesa.",
      imagen: "https://m.media-amazon.com/images/M/MV5BMzcwYjEwMzEtZTZmMi00ZGFhLWJhZjItMDAzNDVkNjZmM2U5L2ltYWdlL2ltYWdlXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=CzcJASnEd0Y",
      categoria: "Romance",
      edadMinima: 0, // Contenido familiar apropiado
    ),
    Pelicula(
      titulo: "Toy Story",
      descripcion: "Los juguetes cobran vida cuando no hay nadie.",
      imagen: "https://artworks.thetvdb.com/banners/movies/318/posters/318.jpg",
      trailer: "https://www.youtube.com/watch?v=v-PjgYDrg70",
      categoria: "Infantiles",
      edadMinima: 0, // Para toda la familia
    ),
    Pelicula(
      titulo: "Saw",
      descripcion: "Thriller psicológico con juegos mortales.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/376/posters/64b0e13abd50a.jpg",
      trailer: "https://www.youtube.com/watch?v=S-1QgOMQ-ls",
      categoria: "Terror",
      edadMinima: 18, 
    ),
    Pelicula(
      titulo: "La La Land",
      descripcion: "Musical romántico en Los Ángeles.",
      imagen: "https://m.media-amazon.com/images/M/MV5BMzUzNDM2NzM2MV5BMl5BanBnXkFtZTgwNTM3NTg4OTE@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=0pdqf4P9MB8",
      categoria: "Romance",
      edadMinima: 13, // Contenido romántico maduro
    ),
    Pelicula(
      titulo: "Superbad",
      descripcion: "Comedia sobre adolescentes antes de graduarse.",
      imagen: "https://artworks.thetvdb.com/banners/movies/2014/posters/2136742.jpg",
      trailer: "https://www.youtube.com/watch?v=4eaZ_48ZYog",
      categoria: "Comedia",
      edadMinima: 16, // Humor sexual, lenguaje fuerte, alcohol
    ),
    Pelicula(
      titulo: "Indiana Jones",
      descripcion: "Arqueólogo aventurero en busca de tesoros perdidos.",
      imagen: "https://artworks.thetvdb.com/banners/v4/movie/519/posters/638a0cfcb3528.jpg",
      trailer: "https://www.youtube.com/watch?v=0ZoOWMn2wJE",
      categoria: "Aventura",
      edadMinima: 13, // Acción aventurera, algunas escenas intensas
    ),
    Pelicula(
      titulo: "El Conjuro",
      descripcion: "Investigadores paranormales enfrentan una presencia demoníaca.",
      imagen: "https://m.media-amazon.com/images/M/MV5BMTM3NjA1NDMyMV5BMl5BanBnXkFtZTcwMDQzNDMzOQ@@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=k10ETZ41q5o",
      categoria: "Terror",
      edadMinima: 16, // Terror psicológico, escenas perturbadoras
    ),
    Pelicula(
      titulo: "Los Increíbles",
      descripcion: "Familia de superhéroes debe salvar el mundo.",
      imagen: "https://m.media-amazon.com/images/M/MV5BMTY5OTU0OTc2NV5BMl5BanBnXkFtZTcwMzU4MDcyMQ@@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=eZbzbC9285I",
      categoria: "Infantiles",
      edadMinima: 0, // Apto para toda la familia
    ),
    Pelicula(
      titulo: "Matrix",
      descripcion: "Programador descubre que la realidad es una simulación.",
      imagen: "https://m.media-amazon.com/images/M/MV5BNzQzOTk3OTAtNDQ0Zi00ZTVkLWI0MTEtMDllZjNkYzNjNTc4L2ltYWdlXkEyXkFqcGdeQXVyNjU0OTQ0OTY@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=vKQi3bBA1y8",
      categoria: "Ciencia Ficción",
      edadMinima: 13, // Violencia de ciencia ficción, conceptos complejos
    ),
    Pelicula(
      titulo: "Shrek",
      descripcion: "Un ogro verde emprende una aventura para rescatar a la princesa.",
      imagen: "https://m.media-amazon.com/images/M/MV5BOGZhM2FhNTItODAzNi00YjA0LWEyN2UtNjJlYWQzYzU1MDg5L2ltYWdlL2ltYWdlXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=CwXOrWvPBPk",
      categoria: "Infantiles",
      edadMinima: 0, // Para toda la familia
    ),
    Pelicula(
      titulo: "Deadpool",
      descripcion: "Antihéroe mercenario con humor negro y violencia extrema.",
      imagen: "https://m.media-amazon.com/images/M/MV5BYzE5MjY1ZDgtMTkyNC00MTMyLThhMjAtZGI5OTE1NzFlZGJjXkEyXkFqcGdeQXVyNjU0OTQ0OTY@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=9vN6DHB6bJc",
      categoria: "Acción",
      edadMinima: 18, // Violencia extrema, lenguaje fuerte, humor sexual
    ),
    Pelicula(
      titulo: "Coco",
      descripcion: "Niño viaja al mundo de los muertos para conocer su familia.",
      imagen: "https://m.media-amazon.com/images/M/MV5BYjQ5NjM0Y2YtNjZkNC00ZDhkLWJjMWItN2QyNzFkMDE3ZjAxXkEyXkFqcGdeQXVyODIxMzk5NjA@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=Rvr68u6k5sI",
      categoria: "Infantiles",
      edadMinima: 0, // Familiar, temas de muerte tratados de forma apropiada
    ),
    Pelicula(
      titulo: "Venom",
      descripcion: "Periodista se fusiona con un simbionte alienígena.",
      imagen: "https://m.media-amazon.com/images/M/MV5BNzAwNzUzNjY4MV5BMl5BanBnXkFtZTgwMTQ5MzM0NjM@._V1_.jpg",
      trailer: "https://www.youtube.com/watch?v=u9Mv98Gr5pY",
      categoria: "Acción",
      edadMinima: 16, // Violencia, escenas intensas, horror leve
    ),
  ];
}

// Funciones adicionales para filtrado
List<Pelicula> obtenerPeliculasPorEdad(int edadUsuario) {
  return obtenerPeliculas().where((pelicula) {
    return pelicula.esApropiadaParaEdad(edadUsuario);
  }).toList();
}

List<Pelicula> obtenerPeliculasPorCategoriaYEdad(String categoria, int edadUsuario) {
  return obtenerPeliculas().where((pelicula) {
    return pelicula.categoria.toLowerCase() == categoria.toLowerCase() && 
           pelicula.esApropiadaParaEdad(edadUsuario);
  }).toList();
}