import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final int? id;
  
  @HiveField(1)
  final String nom;
  
  @HiveField(2)
  final String prenom;
  
  @HiveField(3)
  final String email;
  
  @HiveField(4)
  final String telephone;
  
  @HiveField(5)
  final String password;
  
  @HiveField(6)
  final DateTime? createdAt;

  User({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.password,
    this.createdAt,
  });

  String get fullName => '$prenom $nom';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'password': password,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      prenom: map['prenom'] as String,
      email: map['email'] as String,
      telephone: map['telephone'] as String,
      password: map['password'] as String,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  User copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? password,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}