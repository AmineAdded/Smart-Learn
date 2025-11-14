/// Modèle représentant le profil d'un utilisateur
/// Ce modèle permet de convertir les données JSON en objet Dart et vice-versa
class ProfileModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String niveau;
  final String role;
  final String createdAt;

  ProfileModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.niveau,
    required this.role,
    required this.createdAt,
  });

  /// Factory : Méthode qui crée un ProfileModel à partir d'un JSON
  /// Exemple : ProfileModel.fromJson({'id': 1, 'nom': 'Dupont', ...})
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      niveau: json['niveau'] as String,
      role: json['role'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Méthode qui convertit le ProfileModel en JSON
  /// Utile pour envoyer les données au serveur
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'niveau': niveau,
      'role': role,
      'createdAt': createdAt,
    };
  }

  /// Méthode pour créer une copie du profil avec des modifications
  /// Très utile pour la mise à jour
  ProfileModel copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? niveau,
    String? role,
    String? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      niveau: niveau ?? this.niveau,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Méthode pour obtenir le nom complet
  String get fullName => '$prenom $nom';

  @override
  String toString() {
    return 'ProfileModel(id: $id, nom: $nom, prenom: $prenom, email: $email, niveau: $niveau)';
  }
}