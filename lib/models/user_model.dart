class UserModel {
  final String id;
  final String email;
  final bool isLoggedIn;

  UserModel({
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
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      isLoggedIn: map['isLoggedIn'] ?? false,
    );
  }
}