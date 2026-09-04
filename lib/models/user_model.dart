class UserModel {
  final String id;
  final String email;
  final bool isLoggedIn;

  const UserModel({
    required this.id,
    required this.email,
    required this.isLoggedIn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'isLoggedIn': isLoggedIn,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      isLoggedIn: map['isLoggedIn'] as bool? ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    bool? isLoggedIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.isLoggedIn == isLoggedIn;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ isLoggedIn.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, isLoggedIn: $isLoggedIn)';
  }
}