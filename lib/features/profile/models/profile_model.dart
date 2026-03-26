class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isPremium;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.isPremium,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      isPremium: map['is_premium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'is_premium': isPremium,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isPremium,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
