class UserModel {
  final String id;
  final String phoneNumber;
  final String fullName;
  final String pseudo;
  final int auraScore;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.pseudo,
    this.auraScore = 100,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    String? pseudo,
    int? auraScore,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      pseudo: pseudo ?? this.pseudo,
      auraScore: auraScore ?? this.auraScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'pseudo': pseudo,
        'auraScore': auraScore,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        fullName: json['fullName'] ?? '',
        pseudo: json['pseudo'] ?? '',
        auraScore: json['auraScore'] ?? 100,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}
