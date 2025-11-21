import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 1)
class Contact extends HiveObject {
  @HiveField(0)
  final int? id;
  
  @HiveField(1)
  final int userId;
  
  @HiveField(2)
  final String nom;
  
  @HiveField(3)
  final String prenom;
  
  @HiveField(4)
  final String? email;
  
  @HiveField(5)
  final String telephone;
  
  @HiveField(6)
  final String? adresse;
  
  @HiveField(7)
  final String? photoPath;
  
  @HiveField(8)
  final bool isFavorite;
  
  @HiveField(9)
  final DateTime? createdAt;

  Contact({
    this.id,
    required this.userId,
    required this.nom,
    required this.prenom,
    this.email,
    required this.telephone,
    this.adresse,
    this.photoPath,
    this.isFavorite = false,
    this.createdAt,
  });

  String get fullName => '$prenom $nom';

  String get initials {
    String prenomInitial = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    String nomInitial = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return prenomInitial + nomInitial;
  }

  String get firstLetter => nom.isNotEmpty ? nom[0].toUpperCase() : '#';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'photo_path': photoPath,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      nom: map['nom'] as String,
      prenom: map['prenom'] as String,
      email: map['email'] as String?,
      telephone: map['telephone'] as String,
      adresse: map['adresse'] as String?,
      photoPath: map['photo_path'] as String?,
      isFavorite: (map['is_favorite'] as int) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Contact copyWith({
    int? id,
    int? userId,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? adresse,
    String? photoPath,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      photoPath: photoPath ?? this.photoPath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}