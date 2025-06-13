// models/user_model.dart
class UserModel {
  final String username;
  final String email;
  final int age;
  final String favoriteGenre;
  final DateTime createdAt;

  UserModel({
    required this.username,
    required this.email,
    required this.age,
    required this.favoriteGenre,
    required this.createdAt,
  });

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'age': age,
      'favoriteGenre': favoriteGenre,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Crear desde Map de Firebase
  factory UserModel.fromMap(Map<String, dynamic> map, String username) {
    return UserModel(
      username: username,
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      favoriteGenre: map['favoriteGenre'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}