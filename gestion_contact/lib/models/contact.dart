import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 1)
class Contact {
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